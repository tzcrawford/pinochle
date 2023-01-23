#!/usr/bin/env python
import socket
import threading
import json

HEADER_SIZE = 64 # Length of metadata message we will accept from client tellling us more about the incoming message such as its size
DISCONNECT_MESSGAGE = "DISCONNECT"

PORT = 5050
#server_ip = "192.168.0.188"
SERVER_IP = socket.gethostbyname(socket.gethostname()) #127.0.1.1 right now
#print(server_ip)
ADDR = (SERVER_IP, PORT)

# Here we handle the connection from an individual client
def handle_client(conn, addr):
    print(f"[NEW CONNECTION] {addr} connected.")

    connected = True
    while connected:
        # First collect the message header
        msg_header = json.loads(conn.recv(HEADER_SIZE))
        msg_header['IncomingSize'] = int(msg_header['IncomingSize'])

        # Using information from the header, we collect the actual message
        msg = json.loads(conn.recv(msg_header['IncomingSize']))

        print(f"[{addr}]: {msg['Message_Text']}")

        if msg == DISCONNECT_MESSGAGE:
            connected = False

    conn.close()



# Here we listen for connections from new clients.
def start():
    server_socket.listen()
    while True:
        print(f"[LISTENING] Server is listening on {SERVER_IP}")
        client_conn, client_addr = server_socet.accept()
        thread = threading.Thread(target=handle_client, args=(client_conn, client_addr) )
        print("Starting new thread for client at addr: ", addr)
        thread.start()
        print("Number of active connections: {}".format(threading.activeCount() - 1) )


if __name__ == '__main__':
    server_socket = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
    server_socket.bind(ADDR)

    print("Starting Server...")
    start()

