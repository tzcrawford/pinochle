#!/usr/bin/env python
import socket
import threading
import json

CHARSET='utf-8'
PORT = 5050
#SERVER_IP = "192.168.0.188"
SERVER_IP = socket.gethostbyname(socket.gethostname()) #127.0.1.1 right now
#print(server_ip)
SERVER_ADDR = (SERVER_IP, PORT)

HEADER_SIZE = 64 # Length of metadata message we will accept from client tellling us more about the incoming message such as its size
DISCONNECT_MESSAGE = "DISCONNECT"

# Here we handle the connection from an individual client
def handle_client(conn, addr):
    print(f"[NEW CONNECTION] {addr} connected.")

    connected = True
    while connected:
        # First collect the message header
        try:
            msg_header = json.loads(conn.recv(HEADER_SIZE).decode(CHARSET))
            msg_header['size'] = int(msg_header['size'])
            
            try: 
                # Using information from the header, we collect the actual message
                msg = json.loads(conn.recv(msg_header['size']).decode(CHARSET))

                print(f"[{addr}]: {msg['text']}")

                if msg['text'] == DISCONNECT_MESSAGE:
                    connected = False

            except Exception as e_msg:
                print(f"Invalid Message from {addr}: ",e_msg)
                connected = False
        except Exception as e_header:
            print(f"Invalid Message Header from {addr}:",e_header)
            connected = False

    conn.close()



# Here we listen for connections from new clients.
def start():
    # Set up the socket
    server_socket = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
    server_socket.bind(SERVER_ADDR)
    # Start listening for connections
    server_socket.listen()
    print(f"[LISTENING] Server is listening on {SERVER_IP}")
    # Handle those connections as we listen
    while True:
        client_conn, client_addr = server_socket.accept()
        thread = threading.Thread(target=handle_client, args=(client_conn, client_addr) )
        print("Starting new thread for client at addr: ", client_addr)
        thread.start()
        print("Number of active connections: {}".format(threading.active_count() - 1) )


if __name__ == '__main__':
    print("Starting Server...")
    start()

