# pinochle
NOTE: This application is not complete and a work in progress.

## Introduction
[Pinochle](https://en.wikipedia.org/wiki/Pinochle) is a card game with a special 48-card deck ranked A,10,K,Q,J,9 among the four standard suits. Players score points by taking 'tricks' and forming combinations of characters into 'melds'. The game is played with three or four players with partners sitting on opposite sides of a table. Each hand is played in three phases:
1. An auction phase for betting on the score your team will make in that hand
    - The winning bidder will declare a 'trump' suit which will rank and score higher than the other suits.
    - The winning team of the auction subsequently exchange three cards
2. A melding phase where teams score on sets of cards in their hand.
3. A trick-taking phase where teams score by playing individual cards in sequence and 'taking the trick' by playing the highest ranked card.

This project will make this multiplayer game playable over the internet within a web browser.
The interface is a "lobby style" implementation where anyone can make a game lobby joinable by other players.
The finished project will have additional features like statistics tracking for users.
The project takes inspiration from [SecretHitler.io](https://github.com/cozuya/secret-hitler/)


## Construction

The software stack includes:
1. A [svelte](https://github.com/sveltejs/svelte) frontend. I chose this javascript compiler over React as to simplify the process of creating reactive elements, reducing the amount of javascript written, and improve readability.
2. A flask web server middle-man which handles communication from users running the frontend in their browser and requests which otherwise would go to the game or SQL database servers. This allows for reduction in the likelihood of cheating among other things.
3. A python [socket](https://docs.python.org/3/library/socket.html)-based game server which handles game logic abstracted from the flask elements.
4. A PostgreSQL server for maintaining information like user statistics, game history, and user authentication.
5. Linux machine(s) running the servers (svelte, flask, game, SQL), with network routing via NGINX, probably using a reverse proxy to make flask accessible.

## How to use this software

### Install

1. Install python3 and pip on a Linux system.
2. Create a directory to host these files.
3. Run `python -m venv venv && source ./venv/bin/activate` to create and enter a python virtual environment where python packages can be installed without affecting your system configuration.
4. Clone and navigate into this repository.
5. Install node.js to compile the svelte packages if you want make any frontend modifications.
6. Copy `config.json.template` onto `config.json` and make any necessary modifications, especially if you want to run outside your local network.
7. Install PostgreSQL
8. Run the `./setup.sh` wizard to set up the app for running.
    - Runs `pip install -r requirements.txt` to install the necessary python requirements.
    - Configures PostgreSQL for the app.
9. Run `./run-svelte.sh` at least once to compile the frontend code.

### Running the server

1. Ensure the postgres service is enabled and running.
2. Run `./flask_server.py` to start hosting the web server, navigate to http://localhost:5000 to load the client on your own machine.
3. Run the `./game_server.py` (Currently incomplete!) so that flask can query other threads for game logic.
4. Optionally, run `./run-svelte.sh` to activate the automatic svelte compiler on file save.

## License and Attribution

The code written for and committed to this repository is distributed under a GPLv3 license. My intention is for the project to primarily serve as a source for learning (if only for me alone).
