FROM jenkins/jenkins:lts-jdk11

USER root

# Только необходимые инструменты
RUN apt-get update && apt-get install -y \
    curl \
    wget \
    git \
    vim \
    python3 \
    python3-pip \
    maven \
    unzip \
    && rm -rf /var/lib/apt/lists/*

# Docker CLI
RUN curl -fsSL https://get.docker.com -o get-docker.sh && \
    sh get-docker.sh && \
    rm get-docker.sh

# Terraform - прямая загрузка
RUN cd /tmp && \
    curl -L -o terraform.zip https://releases.hashicorp.com/terraform/1.5.7/terraform_1.5.7_linux_amd64.zip && \
    unzip terraform.zip && \
    mv terraform /usr/local/bin/ && \
    rm terraform.zip

# kubectl
RUN curl -L -o /usr/local/bin/kubectl https://dl.k8s.io/release/v1.28.0/bin/linux/amd64/kubectl && \
    chmod +x /usr/local/bin/kubectl

# Ansible через pip
RUN pip3 install ansible

# Создание директории
RUN mkdir -p /opt/automation-tools

# Плагины
COPY plugins.txt /usr/share/jenkins/ref/plugins.txt
RUN jenkins-plugin-cli --plugin-file /usr/share/jenkins/ref/plugins.txt

# Init скрипты
COPY init.groovy.d/ /usr/share/jenkins/ref/init.groovy.d/

USER jenkins

ENV JAVA_OPTS="-Djenkins.install.runSetupWizard=false -Xmx2048m"
ENV JENKINS_OPTS="--prefix=/jenkins"

EXPOSE 8080 50000