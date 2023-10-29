#!/usr/bin/env python
import socket
import server
import json
from warnings import warn

class Client:

    def __init__(self):

        # Declare default attributes needed to run server so we can build it with connect()
        self.CHARSET = server.DEFAULT_CHARSET
        self.PORT = server.DEFAULT_PORT
        self.SERVER_IP = server.DEFAULT_SERVER_IP # This line will need to change
        self.HEADER_SIZE = server.DEFAULT_HEADER_SIZE
        self.DISCONNECT_MESSAGE = server.DEFAULT_DISCONNECT_MESSAGE
        self.connected = False

    # Build the client object
    def connect(self):
        try:
            self.SERVER_ADDR = (self.SERVER_IP, self.PORT)
            self.socket = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
            self.socket.connect(self.SERVER_ADDR)
            self.connected = True
        except Exception as e:
            self.SERVER_ADDR = False
            self.connected = False
            warn(f"[CONNECTION FAILED]: {e}")
        return
    
    
    def send(self, message_text):
        
        try:
            assert self.connected == True

            # We send communications as JSON, as converted from dictionary obj
            msg = dict() ; msg_header = dict() 
    
            # Declare what the message is
            msg['text'] = message_text
            msg = json.dumps(msg)
            msg = msg.encode(self.CHARSET)
            
            # Collect metadata on the message
            msg_header['size'] = str(len(msg)) # Get the length of the main message JSON in bytes
            msg_header = json.dumps(msg_header) # Convert that dictionary to JSON string
            msg_header = msg_header.encode(self.CHARSET) # Convert that string to bytes
            msg_header += ' '.encode(self.CHARSET) * (self.HEADER_SIZE - len(msg_header)) # Pad the header so it matches expected HEADER_SIZE
    
            # Send the message metadata to the server as a header with expected size
            self.socket.send(msg_header)
            # Send the message to the server
            self.socket.send(msg)

            return True
        
        except Exception as e:
            warn(f"Failed to send message: {e}")
            return False

    def disconnect(self):
        self.send(self.DISCONNECT_MESSAGE)


if __name__ == '__main__':
    client = Client()
    client.connect()
    client.send("This is a test message")
    client.send("This is a second test message")
    client.disconnect()
