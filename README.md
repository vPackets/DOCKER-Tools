# vPackets Tools 

Gathered some code here and there on the web to create a single container that would allow me to have my own dev and tools environment no matter the platform I am working on.

vPackets Tools is a collection of 3 containers that owns different applications that I use in my day to day work when I work on a customer network or in my lab. It provides me a consistent experience and easy to setup / tear down environment.
It consists of the following:

*   Ubuntu 18.04 container with the following applications:
    *   Python2
    *   Python3
    *   Python libraries (see requirements.txt)
    *   Powershell
    *   Pip
    *   Ansible
    *   fping / hping           
    *   git
    *   curl
    *   htop
    *   iperf - iperf3
    *   network tools           https://launchpad.net/ubuntu/+source/iputils and https://launchpad.net/ubuntu/+source/net-tools
    *   mysql
    *   netcat
    *   nmap
    *   openssh-client
    *   snmp-walker
    *   speedtest-cli
    *   supervisor
    *   tcpdump
    *   tshark
    *   telnet (!)
    *   wget
    *   vim
    *   zsh
*   Nginx official docker image: https://hub.docker.com/_/nginx
*   sftp custom image by atmoz: https://hub.docker.com/r/atmoz/sftp

## Generalities

### Devops Container

This container will use the customized Dockerfile to build the first container. it has a policy to always restart itself in case of failure.
We will map the laptop folder of /Users/nic/code/ to the container folder of /home/nic/devops/code/ so that all the code I edit on my laptop using visual studio is accessible by the container so we can run/test/delete it.

An interactive shell using zsh is configured in this container so we can access it using the docker exec command

### NGINX Container

Official docker container from nginx https://hub.docker.com/_/nginx
Port redirection : 8080 to 80.
Volume mapped: /Users/nic/code/DOCKER - Tools/www to /usr/share/nginx/html

An interactive shell is configured in this container so we can access it using the docker exec command


### SFTP Container

Custom docker container from atmoz https://hub.docker.com/r/atmoz/sftp
Port redirection : 2222 to 22.
Volume mapped: /Users/nic/code/DOCKER - Tools to /home/nic/sftp

You can create users but here I have just myself as an user, the password is easily changeable in order to meet the security best practices in place.
An interactive shell is configured in this container so we can access it using the docker exec command



# Installation

## Full Devops Suite (3 containers - DevOps - NGINX - SFTP)

This container is customized to match my laptop's folder so you might want to change a few lines of code in order to match your own environment.

You would need to pull the entire code and once you have done your modifications, you should build the containers and start them.

I suggest you import your own public key into the container, otherwise you would have to login with a password. Here in the docker-compose, I copy my laptop  public key to the container. (/Users/nic/.ssh/id_rsa.pub:/home/nic/.ssh/keys/id_rsa.pub)

```sh
docker-compose up --build
```
The 3 containers will be build and ready to be used.

```sh
docker exec -it --user nic docker-tools_devops_1 /bin/zsh
```

## DevOps Container Only

You also have the ability to just use the DevOps container.

Build the image:
```sh
docker build -t vpackets/tools .
```

Run the container: 

```sh
docker run -dit --name vpackets-tools -h vpackets-tools -v /Users/nic/Code/:/home/nic/code vpackets/tools
```

or a more explicit command:

```
docker run -dit --name vpackets-tools \                                                                     
        -h vpackets-container \
        -v /Users/nic/Code/:/home/nic/code \
        -v "/Users/nic/Code/DOCKER - Tools/Ansible/Ansible_variables":/home/nic/ansible \
        vpackets/tools:latest
```
Access the container (of course, change the user/folder in your Dockerfile):

```sh
docker exec -it --user nic vpackets-tools /bin/zsh
```


# Bring down the environment.

## Full Devops Suite (3 containers - DevOps - NGINX - SFTP)

In order to bring down the environment once you have finished your work, you can just control - C from the terminal (from the terminal you have previously done docker-compose up) or type the following command:

```sh
docker-compose down
```

## DevOps Container Only

```sh
docker stop vpackets-tools
```
