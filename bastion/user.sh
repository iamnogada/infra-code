#!/bin/bash

while read u; do
    echo "$u"
    sudo userdel $u --remove
done < $1


while read u; do
    echo "$u"
    sudo useradd -m $u
    sudo mkdir /home/$u/.ssh
    sudo chown -R $u:$u /home/$u/.ssh
    sudo chmod 700 /home/$u/.ssh
    sudo cp ~/.ssh/authorized_keys /home/$u/.ssh/
    sudo chown -R $u:$u /home/$u/.ssh/authorized_keys
done < $1
