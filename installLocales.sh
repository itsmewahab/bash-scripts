#!/bin/bash

############################################################################
#
# Author: Nil Portugués Calderó <contact@nilportugues.com>
#
# For the full copyright and license information, please view the LICENSE
# file that was distributed with this source code.
#
############################################################################
 
sudo cp /usr/share/i18n/SUPPORTED /var/lib/locales/supported.d/local
sudo locale-gen
