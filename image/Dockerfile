FROM ubuntu:20.04

# Create app directory
WORKDIR /app

# Bundle app source
COPY src .
RUN apt update && apt install -y \
    software-properties-common
RUN apt -y install python3-pip
RUN pip install -r requirements.txt

# -u     : force the stdout and stderr streams to be unbuffered;
CMD [ "python3", "-u", "process_servicebus_messages.py" ]