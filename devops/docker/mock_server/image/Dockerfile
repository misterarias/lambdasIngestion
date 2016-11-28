FROM ubuntu:wily

ENV DEBIAN_FRONTEND noninteractive

RUN apt-get update  -y
RUN apt-get install -y python-pip python-dev build-essential

COPY requirements.txt .
COPY start.sh .

RUN pip install -r requirements.txt

ENTRYPOINT "./start.sh"
