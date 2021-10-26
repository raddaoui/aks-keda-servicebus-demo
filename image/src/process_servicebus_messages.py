from azure.servicebus import ServiceBusClient, ServiceBusMessage
import sys
import time
from config.config import *
import os

sys.stdout.write("TOPIC_NAME: " + str(TOPIC_NAME) + "\n")
sys.stdout.write("SUBSCRIPTION_NAM: " + str(SUBSCRIPTION_NAME) + "\n")
sys.stdout.write("max_wait_time: " + str(max_wait_time) + "\n")

try:
  if os.environ["CONNECTION_STR"]:
    print("The value of", "CONNECTION_STR", " is ", os.environ["CONNECTION_STR"])
    CONNECTION_STR = os.environ["CONNECTION_STR"]
except KeyError:
  print("CONNECTION_STR", 'environment variable is not set.')
  sys.exit(1)

servicebus_client = ServiceBusClient.from_connection_string(conn_str=CONNECTION_STR, logging_enable=True)

with servicebus_client:
    receiver = servicebus_client.get_subscription_receiver(topic_name=TOPIC_NAME, subscription_name=SUBSCRIPTION_NAME, max_wait_time=max_wait_time)
    with receiver:
        for msg in receiver:
            sys.stdout.write("Received: " + str(msg) + "\n")
            time.sleep(5)
            receiver.complete_message(msg)