#!/bin/bash

sudo cp /usr/share/i18n/SUPPORTED /var/lib/locales/supported.d/local
sudo locale-gen
