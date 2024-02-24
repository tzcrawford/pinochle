#!/bin/sh

# Install python packages
pip install -r requirements.txt || exit 1

# Set up SQL tables for app
./sql_scripts/sql_setup.sh || exit 1

echo "Install and configuration complete, please re-source your venv before proceeding."
