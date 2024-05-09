FROM ubuntu:20.04 AS builder

ENV DEBIAN_FRONTEND=noninteractive
RUN apt update && \
	apt install -y --no-install-recommends \
		build-essential \
		cmake\
		default-jre \
		python \
		python3.8-venv && \
	apt-get clean && \
	rm -rf /var/lib/apt/lists/*

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
	fprime-util generate && \
	fprime-util build

FROM scratch

COPY --from=builder /workspace/build-artifacts/Linux/LedBlinker/bin/LedBlinker /LedBlinker
