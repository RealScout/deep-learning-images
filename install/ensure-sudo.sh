#!/bin/bash

# docker image comes without sudo but we're root
test -e /usr/bin/sudo || (apt update && apt install sudo)
