FROM alpine:latest as dist
ARG DOCKER_BUILD_DIR

LABEL maintainer 1001Pharmacies <technique+docker@1001pharmacies.com>

arg GIT_AUTHOR_NAME
arg GIT_AUTHOR_EMAIL

env GIT_AUTHOR_NAME=${GIT_AUTHOR_NAME:-1001Pharmacies}
env GIT_AUTHOR_EMAIL=${GIT_AUTHOR_EMAIL:-technique+docker@1001pharmacies.com}
env GIT_COMMITTER_NAME=${GIT_AUTHOR_NAME}
env GIT_COMMITTER_EMAIL=${GIT_AUTHOR_EMAIL}

RUN apk upgrade --no-cache \
 && apk add --no-cache \
        bash \
        docker \
        gettext \
        git \
        make \
        mysql-client \
        openssh \
        sudo \
        zsh

RUN git clone https://github.com/ingydotnet/git-subrepo \
 && cd git-subrepo \
 && git fetch origin +refs/heads/release/0.4.0: \
 && git checkout release/0.4.0 \
 && git fetch origin pull/314/head \
 && git rebase 9cbe7ba2f61552ce97fb312c8133813f970ab4a5 \
 && sed -i 's/install -C/install/' Makefile \
 && make install \
 && cd .. \
 && rm -rf git-subrepo

CMD ["bash"]

FROM dist as local
ARG DOCKER_BUILD_DIR
ARG DOCKER_GID
ARG SHELL=/bin/bash
ARG UID
ARG USER
ENV UID=${UID}
ENV GID=${UID}
ENV USER=${USER}
LABEL com.1001pharmacies.uid=${UID}
LABEL com.1001pharmacies.user=${USER}

# If we provide a numeric UID
RUN [ "$UID" -eq "$UID" ] 2>/dev/null \
# Remove user with $UID if it is not our $USER
 && if [ "$(getent passwd $UID |awk -F: '{print $1}')" != "$USER" ]; then \
      sed -i '/^'$(getent passwd $UID |awk -F: '{print $1}')':x:'$UID':/d' /etc/passwd; \
      sed -i '/^'$(getent group $GID |awk -F: '{print $1}')':x:'$GID':/d' /etc/group; \
    fi \
# Force $UID if our $USER already exists
 && sed -i 's/^'$USER':x:[0-9]\+:[0-9]\+:/'$USER':x:'$UID':'$GID':/' /etc/passwd \
 && sed -i 's/^'$USER':x:[0-9]\+:/'$USER':x:'$GID':/' /etc/group \
# Create $USER if it does not exist
 && if [ "$(getent passwd $UID)" = "" ]; then \
      echo "$USER:x:$UID:$GID::/home/$USER:$SHELL" >> /etc/passwd; \
      echo "$USER:\!:$(($(date +%s) / 60 / 60 / 24)):0:99999:7:::" >> /etc/shadow; \
      echo "$USER:x:$GID:" >> /etc/group; \
    fi \
 && mkdir -p /home/$USER \
 && chown $UID:$GID /home/$USER \
 || true

# If we provide a numeric DOCKER_GID
RUN [ "$DOCKER_GID" -eq "$DOCKER_GID" ] 2>/dev/null \
 && if [ "$(getent group docker |awk -F: '{print $3}')" != "$DOCKER_GID" ]; then \
      sed -i 's/^docker:x:[0-9]\+:/docker:x:'$DOCKER_GID':/' /etc/group; \
    fi \
|| true

## User groups
RUN adduser $USER docker \
 && adduser $USER wheel \
 && echo '%wheel ALL=(ALL) NOPASSWD:ALL' >> /etc/sudoers

RUN echo -e "\n\
Host *\n\
  LogLevel quiet\n\
  Compression yes\n\
## AWS ##\n\
Host 10.131.*\n\
  ProxyCommand ssh -q aws-deploy nc -q0 %h 22\n\
  HostName %h\n\
  StrictHostKeyChecking no\n\
  UserKnownHostsFile /dev/null\n\
Host aws-deploy\n\
  HostName 52.50.10.235\n\
  User sshuser\n\
" >> /etc/ssh/ssh_config

USER $USER
ENV SHELL=${SHELL}
WORKDIR /home/$USER

# git config
RUN mkdir -p ~/.ssh ~/.config/git \
 && ssh-keyscan -t rsa -H github.com >> ~/.ssh/known_hosts \
 && ssh-keyscan -t rsa -H 52.31.228.112 >> ~/.ssh/known_hosts \
 && ssh-keyscan -t rsa -H 52.50.10.235 >> ~/.ssh/known_hosts \
 && echo -e "\
.DS_Store\n\
.idea/\n\
.nfs*\n\
.theia/settings.json\n\
*~\n\
*.log\n\
*.swp\n\
Thumbs.db\n\
" > ~/.config/git/ignore