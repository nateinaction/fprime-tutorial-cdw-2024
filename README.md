# led-blinker F' project

This project follows the [LED Blinker tutorial](https://fprime-community.github.io/fprime-workshop-led-blinker/). During the 2024 [CubeSat Developer Workshop](https://www.cubesatdw.org/) we built this tutorial and then deployed to an Arm based ODRIOD. The existing [cross-complilation tutorial for F Prime](https://nasa.github.io/fprime/v3.4.2/Tutorials/CrossCompilationSetup/CrossCompilationTutorial.html) describes how to compile an Arm binary for x86 Windows, Linux, and MacOS machines but does not yet describe a process for "Apple Silicon" (arm64) based MacOS users.

For Apple Silicon users you can build the arm64 linux binary by:
1. Copy the `Dockerfile` and `.dockerignore` files from this repo to the root of your LED tutorial projects
1. Run `docker build --output=. build-artifacts-docker`
