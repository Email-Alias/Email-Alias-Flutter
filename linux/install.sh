#!/bin/bash

sudo cp -r build/linux/x64/release/bundle/* /etc/email_alias
sudo cp linux/Icon.svg /etc/email_alias
sudo ln -s /etc/email_alias/email_alias /usr/local/bin/email_alias
sudo cp linux/email_alias.desktop /usr/share/applications