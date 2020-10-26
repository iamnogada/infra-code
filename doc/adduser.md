# add user on linux

## prepare user list
> create file as txt
```
in03936
in03934
in03935
in03990
in03926
in03922
in30928
in03930
in03924
in03921
in03962
ia01953
```

## run shell
> create user and share the authorized ssh key
> 
```sh
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
```