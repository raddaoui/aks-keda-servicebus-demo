from azure.servicebus import ServiceBusClient, ServiceBusMessage
import sys
import time

CONNECTION_STR = "Endpoint=sb://myaks-sb-27.servicebus.windows.net/;SharedAccessKeyName=RootManageSharedAccessKey;SharedAccessKey=kYY8m4mULTEAO4hzEeFMinx5zpXPPM+g+U1V/0Ck2fA="
TOPIC_NAME = "mytopic"
SUBSCRIPTION_NAME = "s1"

servicebus_client = ServiceBusClient.from_connection_string(conn_str=CONNECTION_STR, logging_enable=True)

with servicebus_client:
    receiver = servicebus_client.get_subscription_receiver(topic_name=TOPIC_NAME, subscription_name=SUBSCRIPTION_NAME, max_wait_time=20)
    with receiver:
        for msg in receiver:
            sys.stdout.write("Received: " + str(msg) + "\n")
            time.sleep(5)
            receiver.complete_message(msg)