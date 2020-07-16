FROM ubuntu:18.04
LABEL Maintainer = "Nicolas MICHEL <nicolas@vpackets.net>"

# Variable Definition
ENV ANSIBLE_VERSION "2.9.10"
ENV DEBIAN_FRONTEND=noninteractive
ENV PACKER_VERSION "1.6.0"
ENV TERRAFORM_VERSION "0.12.28"
ENV POWERSHELL_VERSION "7.0.2"

# Creating Home Directory
WORKDIR /home/nmichel
RUN mkdir -p /home/nmichel/ansible
RUN mkdir -p /home/nmichel/code
RUN mkdir -p /home/nmichel/lab-images

# Copy requirement file (PIP Libraries)
COPY requirements.txt /home/nmichel/requirements.txt

# Copy Ansible Config 
COPY Ansible/ansible.cfg /etc/ansible/ansible.cfg

# Fix bad proxy issue
COPY system/99fixbadproxy /etc/apt/apt.conf.d/99fixbadproxy

# Clear previous sources
RUN rm /var/lib/apt/lists/* -vf

#install and source ansible
RUN  apt-get -y update && \
 apt-get -y dist-upgrade && \
 apt-get -y --force-yes install \
  apt-utils \
  build-essential \
  ca-certificates \
  curl \
  dnsutils \
  fping \
  git \
  hping3 \ 
  htop \
  httpie \
  iftop \
  # need to expose Port
  iperf \
  iperf3 \ 
  iproute2 \
  iputils-arping \
  iputils-clockdiff \
  iputils-ping \
  iputils-tracepath \
  libfontconfig \
  liblttng-ust0 \
  man \ 
  mtr \
  mysql-client \
  mysql-server \
  nano \
  net-tools \
  #net-snmp \
  netcat \
  netperf \
  ngrep \
  nload \
  nmap \
  openssh-client \
  openssh-server \
  openssl \
  packer \
  p0f \
  python-pip \
  python-scapy \
  python3-dev \
  python3-distutils \
  python3-pip \
  python3-scapy \
  python3.7 \
  python3.8 \
  rsync \
  snmp \ 
  snmp-mibs-downloader \
  snmpd \
  socat \
  software-properties-common \
  speedtest-cli \
  #sysctl \
  openssh-server \
  sshpass \
  supervisor \
  sudo \
  tcpdump \
  tcptraceroute \
  telnet \
  traceroute \
  tshark \ 
  unzip \
  wget \
  vim \
  wget \
  tree \
  zsh \
  zsh-syntax-highlighting

# Install Powershell
RUN wget https://github.com/PowerShell/PowerShell/releases/download/v${POWERSHELL_VERSION}/powershell_${POWERSHELL_VERSION}-1.ubuntu.18.04_amd64.deb
RUN dpkg -i powershell_${POWERSHELL_VERSION}-1.ubuntu.18.04_amd64.deb
RUN rm powershell_${POWERSHELL_VERSION}-1.ubuntu.18.04_amd64.deb

# Install PowerCLI
RUN pwsh -Command Install-Module VMware.PowerCLI -Force -Verbose

# Install Oh-My-ZSH
RUN wget https://github.com/robbyrussell/oh-my-zsh/raw/master/tools/install.sh -O - | zsh || true  

# Install Packer
RUN wget https://releases.hashicorp.com/packer/${PACKER_VERSION}/packer_${PACKER_VERSION}_linux_amd64.zip
RUN unzip packer_${PACKER_VERSION}_linux_amd64.zip
RUN mv packer /usr/local/bin

# Install Terraform
RUN wget https://releases.hashicorp.com/terraform/${TERRAFORM_VERSION}/terraform_${TERRAFORM_VERSION}_linux_amd64.zip
RUN unzip terraform_${TERRAFORM_VERSION}_linux_amd64.zip -d /usr/local/bin/

# Install Pip requirements
RUN pip3 install -q --upgrade pip
RUN pip3 install --upgrade setuptools
RUN pip3 install -q ansible==$ANSIBLE_VERSION
RUN pip3 install -r requirements.txt
RUN pip3 install pyATS[library]

# Add user nmichel
RUN useradd -ms /bin/zsh nmichel
RUN usermod -a -G sudo,nmichel nmichel

# Copy Oh-My_ZSH Setting 
COPY .zshrc /home/nmichel/.zshrc
ADD .oh-my-zsh /home/nmichel/.oh-my-zsh
RUN  chown -R nmichel:nmichel /home/nmichel
#RUN git clone https://github.com/zsh-users/zsh-autosuggestions.git $ZSH_CUSTOM/plugins/zsh-autosuggestions
#RUN git clone https://github.com/zsh-users/zsh-syntax-highlighting.git $ZSH_CUSTOM/plugins/zsh-syntax-highlighting

# Install OVF Tools
COPY system/ovftools/VMware-ovftool-4.4.0-16360108-lin.x86_64.bundle /home/nmichel/VMware-ovftool-4.4.0-16360108-lin.x86_64.bundle
RUN /bin/bash /home/nmichel/VMware-ovftool-4.4.0-16360108-lin.x86_64.bundle --eulas-agreed --required --console

# Cleanup
RUN apt-get clean && \
 rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*
RUN rm -rf requirements.txt 
RUN rm packer_${PACKER_VERSION}_linux_amd64.zip
RUN rm terraform_${TERRAFORM_VERSION}_linux_amd64.zip
RUN rm VMware-ovftool-4.4.0-16360108-lin.x86_64.bundle