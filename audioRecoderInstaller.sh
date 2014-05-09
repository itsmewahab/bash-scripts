#!/bin/bash

echo "\n" | sudo apt-add-repository ppa:osmoma/audio-recorder
sudo apt-get update
sudo apt-get install audio-recorder
