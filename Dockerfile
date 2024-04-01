# Start by building the server
FROM dart:stable AS build

WORKDIR /app

# Resolve app dependencies.
COPY pubspec.* ./
RUN dart pub get

# Copy app source code and AOT compile it.
COPY . .

# Generate a production build.
RUN dart pub global activate dart_frog_cli
RUN dart pub global run dart_frog_cli:dart_frog build

# Ensure packages are still up-to-date if anything has changed.
RUN dart pub get --offline
RUN dart compile exe build/bin/server.dart -o build/bin/server

# Use Fuchsia OS as the base image
FROM asapelkin/fuchsia:latest

USER root

# Install prerequisites and Dart
RUN apt-get update && \
  apt-get install -y apt-transport-https && \
  wget -qO- https://dl-ssl.google.com/linux/linux_signing_key.pub | gpg --dearmor -o /usr/share/keyrings/dart-archive-keyring.gpg && \
  echo "deb [signed-by=/usr/share/keyrings/dart-archive-keyring.gpg] https://storage.googleapis.com/download.dartlang.org/linux/debian stable main" | tee /etc/apt/sources.list.d/dart.list && \
  sudo apt-get update && \
  sudo apt-get install -y dart

# Set environment variables for Dart
ENV PATH="/usr/lib/dart/bin:${PATH}"
ENV PATH="/usr/lib/dart/bin:/home/user/fuchsia-getting-started/tools:${PATH}"

COPY --from=build /app/build/bin/server /home/user/fuchsia-getting-started/src/server/bin/server
COPY --from=build /app/build/fuchsia/server.cmx /home/user/fuchsia-getting-started/src/server/meta/
COPY --from=build /app/build/BUILD.bazel /home/user/fuchsia-getting-started/src/server/

RUN scripts/bootstrap.sh

RUN tools/bazel build @fuchsia_sdk//:fuchsia_toolchain_sdk

RUN bazel build //src/server:package
