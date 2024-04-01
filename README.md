# Dart Server -> Fuchsia

An experiment to create a fuchsia server and run it on Google Cloud

_Related: Fuchsia + Dart, Fuchsia Components_

## Goal

1. Create a development environment to build a Fuchsia component with dart.
2. Package the component and deploy it to a package server.
3. Run the package on a real host with Fuchsia OS.
4. Deploy the a container with Fuchsia as the container OS to GCP Cloud Run with the server component.

## About

Regardless of your dev machine, you can run this project if you have Docker installed.

The container OS uses ubuntu, see: [`asapelkin/fuchsia:latest`](https://github.com/asapelkin/fuchsia-docker/blob/main/Dockerfile).

How to build
`docker build . -t fuchsia-server`

See what's in the container
`docker build -it fuchsia-server /bin/bash`

## Notes

- Dart runtime for Fuchsia was removed in 2021. So, the Dockerfile compiles the dart server as an executable and injects the executable into the development container. The Fuchsia component runtime can use the ELF runner to run the server.

- The project uses the SDK, it does not build the Fuchsia project from source. _Use the SDK documentation! If the docs don't work, then run the examples under src/ in the container_
