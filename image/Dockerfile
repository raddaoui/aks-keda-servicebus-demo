FROM python:3.6

# Create app directory
WORKDIR /app

# Bundle app source
COPY src .

RUN pip install -r requirements.txt

# -u     : force the stdout and stderr streams to be unbuffered;
CMD [ "python", "process_servicebus_messages.py" ]