#!/bin/sh
# Access the dev server
xdg-open http://localhost:5000/ 
    #Note this uses port 5000, not 8080
    # 5000 is the flask server
    # 8080 is the svelte server
    # If we access the svelte server, it cannot communicate to flask. But flask can redirect to svelte which in turn can access the flask functions.
