FROM jenkins/jenkins:lts-jdk11

USER root

# Установка базовых инструментов
RUN apt-get update && apt-get install -y \
    curl \
    wget \
    git \
    vim \
    nano \
    jq \
    python3 \
    python3-pip \
    maven \
    unzip \
    groovy \
    software-properties-common \
    apt-transport-https \
    ca-certificates \
    gnupg \
    lsb-release \
    && rm -rf /var/lib/apt/lists/*

# Установка Docker CLI
RUN curl -fsSL https://get.docker.com -o get-docker.sh && \
    sh get-docker.sh && \
    rm get-docker.sh && \
    usermod -aG docker jenkins

# Установка kubectl
RUN curl -fsSL https://pkgs.k8s.io/core:/stable:/v1.28/deb/Release.key | gpg --dearmor -o /etc/apt/keyrings/kubernetes-apt-keyring.gpg && \
    echo 'deb [signed-by=/etc/apt/keyrings/kubernetes-apt-keyring.gpg] https://pkgs.k8s.io/core:/stable:/v1.28/deb/ /' | tee /etc/apt/sources.list.d/kubernetes.list && \
    apt-get update && \
    apt-get install -y kubectl && \
    kubectl version --client

# Установка Helm
RUN curl https://baltocdn.com/helm/signing.asc | gpg --dearmor | tee /usr/share/keyrings/helm.gpg > /dev/null && \
    echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/helm.gpg] https://baltocdn.com/helm/stable/debian/ all main" | tee /etc/apt/sources.list.d/helm-stable-debian.list && \
    apt-get update && \
    apt-get install -y helm && \
    helm version

# Установка Ansible и Python пакетов
RUN pip3 install --no-cache-dir \
    ansible \
    ansible-lint \
    yamllint \
    pytest \
    requests \
    boto3 \
    docker

# Установка Node.js и npm пакетов
RUN npm install -g yarn grunt-cli gulp-cli

# Дополнительные инструменты
RUN apt-get update && apt-get install -y \
    yamllint \
    shellcheck \
    && rm -rf /var/lib/apt/lists/*

# Создание рабочих директорий
RUN mkdir -p /opt/automation-tools && \
    chown -R jenkins:jenkins /opt/automation-tools

# Копирование и установка плагинов Jenkins
COPY --chown=jenkins:jenkins plugins.txt /usr/share/jenkins/ref/plugins.txt
RUN jenkins-plugin-cli --plugin-file /usr/share/jenkins/ref/plugins.txt

# Копирование init скриптов
COPY --chown=jenkins:jenkins init.groovy.d/ /usr/share/jenkins/ref/init.groovy.d/

# Очистка
RUN apt-get clean && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

USER jenkins

ENV JAVA_OPTS="-Djenkins.install.runSetupWizard=false -Xmx2048m"
ENV JENKINS_OPTS="--prefix=/jenkins"

EXPOSE 8080 50000