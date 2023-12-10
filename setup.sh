#!/bin/sh

# Install python packages
pip install -r requirements.txt

# Set up SQL tables for app
./sql_scripts/sql_setup.sh
