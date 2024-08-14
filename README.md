# led-blinker F' project

This project follows the [LED Blinker tutorial](https://fprime-community.github.io/fprime-workshop-led-blinker/). During the 2024 [CubeSat Developer Workshop](https://www.cubesatdw.org/) we built this tutorial and then deployed to an Arm based ODRIOD. The existing [cross-complilation tutorial for F Prime](https://nasa.github.io/fprime/v3.4.2/Tutorials/CrossCompilationSetup/CrossCompilationTutorial.html) describes how to compile an Arm binary for x86 Windows, Linux, and MacOS machines but does not yet describe a process for "Apple Silicon" (arm64) based MacOS users.

This repository contains a [Dockerfile](Dockerfile) that can build linux arm and arm64 binaries. The Dockerfile will build on any Windows, Mac, or Linux host machine with either an x86 or arm (Apple Silicon) processor.

## Getting started

### Dependencies first

1. Clone the repo
1. Pull the fprime submodule `git submodule update --init --recursive`
1. Create a python venv `python3 -m venv fprime-venv`
1. Activate the venv `. fprime-venv/bin/activate`
1. Install required packages `pip install -r fprime/requirements.txt`

### Building the linux/arm or linux/arm64 binary

1. Run `docker build --platform=linux/arm64 --output=build-artifacts-docker .`

You can now SCP the binary over to your linux/arm machine and run it:
```sh
$ scp -r build-artifacts-docker/Linux/LedBlinker/bin/LedBlinker ngay@arm-testbed.local:~
$ ssh ngay@arm-testbed.local
ngay@arm-testbed:~# sudo ./LedBlinker
...
EVENT: (1280) (2:1722300778,53836) DIAGNOSTIC: (cmdDisp) OpCodeRegistered : Opcode 0x500 registered to port 0 slot 0
...
```

### Building and running the GDS on the host machine

1. Run `fprime-generate`
1. Run `fprime-build`

You can now run the GDS:
```sh
$ fprime-gds -n --dictionary build-artifacts/Darwin/LedBlinker/dict/LedBlinkerTopologyAppDictionary.xml --ip-client --ip-address 100.79.223.82
...
[INFO] Ensuring TCP Server is stable for at least 5 seconds
...
```

## Using this in your own project

1. Copy the `Dockerfile` and `.dockerignore` files from this repo to the root of your F' project
1. Run `docker build --platform=linux/arm64 --output=build-artifacts-docker .`
