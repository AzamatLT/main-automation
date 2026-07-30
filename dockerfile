FROM jenkins/jenkins:lts-jdk11

USER root

# Установка дополнительных инструментов для автоматизации
RUN apt-get update && apt-get install -y \
    curl \
    wget \
    git \
    vim \
    nano \
    jq \
    python3 \
    python3-pip \
    nodejs \
    npm \
    groovy \
    maven \
    ansible \
    unzip \
    && rm -rf /var/lib/apt/lists/*

# Установка Docker CLI (для работы с Docker из Jenkins)
RUN curl -fsSL https://get.docker.com -o get-docker.sh && \
    sh get-docker.sh && \
    rm get-docker.sh

# Установка kubectl
RUN curl -LO "https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl" && \
    chmod +x kubectl && \
    mv kubectl /usr/local/bin/

# Установка Terraform
RUN wget -q https://releases.hashicorp.com/terraform/1.5.7/terraform_1.5.7_linux_amd64.zip && \
    unzip terraform_1.5.7_linux_amd64.zip && \
    mv terraform /usr/local/bin/ && \
    rm terraform_1.5.7_linux_amd64.zip

# Установка Helm
RUN curl https://raw.githubusercontent.com/helm/helm/master/scripts/get-helm-3 | bash

# Создание директории для дополнительных инструментов
RUN mkdir -p /opt/automation-tools

# Установка Python пакетов
RUN pip3 install --no-cache-dir \
    ansible-lint \
    yamllint \
    pytest \
    requests

# Копирование файла с плагинами
COPY plugins.txt /usr/share/jenkins/ref/plugins.txt

# Предварительная установка плагинов
RUN jenkins-plugin-cli --plugin-file /usr/share/jenkins/ref/plugins.txt

# Копирование скриптов инициализации
COPY init.groovy.d/ /usr/share/jenkins/ref/init.groovy.d/

USER jenkins

# Установка переменных окружения для Jenkins
ENV JAVA_OPTS="-Djenkins.install.runSetupWizard=false -Xmx2048m"
ENV JENKINS_OPTS="--prefix=/jenkins"
ENV CASC_JENKINS_CONFIG="/var/jenkins_home/casc_configs"

EXPOSE 8080 50000