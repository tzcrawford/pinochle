#!/usr/bin/env python
import socket
import server
import json

CHARSET = server.CHARSET
PORT = server.PORT
SERVER_IP = server.SERVER_IP # This line will need to change
SERVER_ADDR = server.SERVER_ADDR
HEADER_SIZE = server.HEADER_SIZE
DISCONNECT_MESSAGE = server.DISCONNECT_MESSAGE

def start():
    client_socket = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
    client_socket.connect(SERVER_ADDR)

    return client_socket

def send(message_text, client_socket):
    msg = dict() ; msg_header = dict() # We send communications as JSON, as converted from dictionary obj

    # Declare what the message is
    msg['text'] = message_text
    msg = json.dumps(msg)
    msg = msg.encode(CHARSET)
    
    # Collect metadata on the message
    msg_header['size'] = str(len(msg)) # Get the length of the main message JSON in bytes
    msg_header = json.dumps(msg_header) # Convert that dictionary to JSON string
    msg_header = msg_header.encode(CHARSET) # Convert that string to bytes
    msg_header += ' '.encode(CHARSET) * (HEADER_SIZE - len(msg_header)) # Pad the header so it matches expected HEADER_SIZE

    # Send the message metadata to the server as a header with expected size
    client_socket.send(msg_header)
    # Send the message to the server
    client_socket.send(msg)


if __name__ == '__main__':
    client_socket = start()
    send("This is a test message", client_socket)
