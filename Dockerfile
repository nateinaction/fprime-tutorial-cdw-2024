FROM --platform=$BUILDPLATFORM ubuntu:20.04 AS builder

ENV DEBIAN_FRONTEND=noninteractive
RUN apt update && \
	apt install -y --no-install-recommends \
		build-essential \
		cmake\
		curl \
		default-jre \
		python \
		python3.8-venv && \
	apt-get clean && \
	rm -rf /var/lib/apt/lists/*

# download the arm toolchains
ENV ARM_TOOLS_VERSION=11.2-2022.02
RUN mkdir -p /opt/toolchains/x86_64-to-arm64 && \
	curl -Ls https://developer.arm.com/-/media/Files/downloads/gnu-a/$ARM_TOOLS_VERSION/binrel/gcc-arm-$ARM_TOOLS_VERSION-x86_64-aarch64-none-linux-gnu.tar.xz | tar -JC /opt/toolchains/amd64-to-arm64 --strip-components=1 -x && \
	mkdir -p /opt/toolchains/x86_64-to-arm && \
	curl -Ls https://developer.arm.com/-/media/Files/downloads/gnu-a/$ARM_TOOLS_VERSION/binrel/gcc-arm-$ARM_TOOLS_VERSION-x86_64-arm-none-linux-gnueabihf.tar.xz | tar -JC /opt/toolchains/amd64-to-arm --strip-components=1 -x && \
	mkdir -p /opt/toolchains/arm64-to-arm && \
	curl -Ls https://developer.arm.com/-/media/Files/downloads/gnu/$ARM_TOOLS_VERSION/binrel/gcc-arm-$ARM_TOOLS_VERSION-aarch64-arm-none-linux-gnueabihf.tar.xz | tar -JC /opt/toolchains/arm64-to-arm --strip-components=1 -x

# download the arm toolchain if necessary
ENV ARM_TOOLS_VERSION=11.2-2022.02
RUN if [[ ! -v TARGETARCH ]] && [ "$(dpkg --print-architecture)" != "$TARGETARCH" ]; then \
		mkdir -p /opt/toolchains && \
		if [ "$(dpkg --print-architecture)" = "amd64" ] && [ $TARGETARCH = "arm64"]; then \
			# if we're building on x86_64 and cross compiling to arm64
			curl -Ls https://developer.arm.com/-/media/Files/downloads/gnu-a/$ARM_TOOLS_VERSION/binrel/gcc-arm-$ARM_TOOLS_VERSION-x86_64-aarch64-none-linux-gnu.tar.xz | tar -JC /opt/toolchains --strip-components=1 -x; \
		elif [ "$(dpkg --print-architecture)" = "amd64" ] && [ $TARGETARCH = "arm"]; then \
			# if we're building on x86_64 and cross compiling to arm32
			curl -Ls https://developer.arm.com/-/media/Files/downloads/gnu-a/$ARM_TOOLS_VERSION/binrel/gcc-arm-$ARM_TOOLS_VERSION-x86_64-arm-none-linux-gnueabihf.tar.xz | tar -JC /opt/toolchains --strip-components=1 -x; \
		elif [ "$(dpkg --print-architecture)" = "arm64" ] && [ $TARGETARCH = "arm"]; then \
			# if we're building on arm64 and cross compiling to arm32
			curl -Ls https://developer.arm.com/-/media/Files/downloads/gnu/$ARM_TOOLS_VERSION/binrel/gcc-arm-$ARM_TOOLS_VERSION-aarch64-arm-none-linux-gnueabihf.tar.xz | tar -JC /opt/toolchains --strip-components=1 -x; \
		else \
			echo "Unsupported target architecture combination: $(dpkg --print-architecture) to $TARGETARCH" && \
			exit 1; \
		fi \
	fi

# create the virtual environment
RUN python3 -m venv /opt/venv

# install the requirements
COPY fprime/requirements.txt /
RUN . /opt/venv/bin/activate && \
	pip install -r requirements.txt
	
# build the project
COPY . /workspace
WORKDIR /workspace
RUN . /opt/venv/bin/activate && \
	if [ "$(dpkg --print-architecture)" != "$TARGETARCH" ]; then \
		export ARM_TOOLS_PATH="/opt/toolchains/$(dpkg --print-architecture)-to-$TARGETARCH"; \
		if [ $TARGETARCH = "arm64"]; then \
			export FPRIME_BUILD_TARGET=aarch64-linux; \
		elif [ $TARGETARCH = "arm"]; then \
			export FPRIME_BUILD_TARGET=arm-hf-linux; \
		fi; \
	fi && \
	fprime-util generate $FPRIME_BUILD_TARGET && \
	fprime-util build $FPRIME_BUILD_TARGET 

FROM scratch

COPY --from=builder /workspace/build-artifacts/ .
