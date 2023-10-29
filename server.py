#!/usr/bin/env python
import socket
import threading
import json
from warnings import warn

DEFAULT_CHARSET='utf-8'
DEFAULT_PORT = 5050
#DEFAULT_SERVER_IP = "192.168.0.188"
DEFAULT_SERVER_IP = socket.gethostbyname(socket.gethostname()) #127.0.1.1 right now
DEFAULT_HEADER_SIZE = 64 # Length of metadata message we will accept from client tellling us more about the incoming message such as its size
DEFAULT_DISCONNECT_MESSAGE = "DISCONNECT"

class Server():
    def __init__(self):

        # Set base/default attributes needed to run server so we can build it with start()
        self.CHARSET=DEFAULT_CHARSET
        self.PORT = DEFAULT_PORT
        self.SERVER_IP = DEFAULT_SERVER_IP
        self.SERVER_ADDR = (self.SERVER_IP, self.PORT)
        self.HEADER_SIZE = DEFAULT_HEADER_SIZE
        self.DISCONNECT_MESSAGE = DEFAULT_DISCONNECT_MESSAGE


    # Here we listen for connections from new clients.
    def start(self):
        # Set up the socket
        server_socket = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
        server_socket.setsockopt(socket.SOL_SOCKET, socket.SO_REUSEADDR, 1) # Prevent the server crashing from restarts accessing the socket
        server_socket.bind(self.SERVER_ADDR)
        # Start listening for connections
        server_socket.listen()
        print(f"[LISTENING] Server is listening on {self.SERVER_IP}")
        # Handle those connections as we listen
        while True:
            client_conn, client_addr = server_socket.accept()
            thread = threading.Thread(target=self.handle_client, args=(client_conn, client_addr) )
            print("Starting new thread for client at addr: ", client_addr)
            thread.start()
            print(f"Number of active connections: {threading.active_count() - 1}" )
    
    # Here we handle messages from the connection with an individual client
    def handle_client(self, conn, addr):
        print(f"[NEW CONNECTION] {addr} connected.")
    
        connected = True
        while connected:
            # First collect the message header
            try:
                msg_header = json.loads(conn.recv(self.HEADER_SIZE).decode(self.CHARSET))
                msg_header['size'] = int(msg_header['size'])
                
                try: 
                    # Using information from the header, we collect the actual message
                    msg = json.loads(conn.recv(msg_header['size']).decode(self.CHARSET))
    
                    print(f"[{addr}]: {msg['text']}")
    
                    if msg['text'] == self.DISCONNECT_MESSAGE:
                        connected = False
    
                except Exception as e_msg:
                    warn(f"Invalid Message from {addr}: ",e_msg)
                    continue
            except Exception as e_header:
                #warn(f"Invalid Message Header from {addr}:",e_header) # This line should not be enabled
                    # This is expected to happen if the payload is not a header but rather the subsequent message
                    # In other words, the contents of the loop will run for every client message sent, even if it is the actual message after the header. 
                    # We should just ignore messages if they are not a header as they will be processed correctly if 
                continue
    
        conn.close()




if __name__ == '__main__':
    print("Starting Server...")
    server = Server()
    server.start()

