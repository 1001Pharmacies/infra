FROM mysql:5.6.44 as dist
ARG DOCKER_BUILD_DIR

LABEL maintainer 1001Pharmacies <technique+docker@1001pharmacies.com>

# config
COPY ${DOCKER_BUILD_DIR}/conf.d/all.cnf /etc/mysql/conf.d/

# install goss
ADD https://github.com/aelsabbahy/goss/releases/latest/download/goss-linux-amd64 /usr/bin/goss
RUN chmod +rx /usr/bin/goss
COPY ${DOCKER_BUILD_DIR}/goss.yml /tests/goss.yml

HEALTHCHECK CMD goss -g /tests/goss.yml validate --format tap

FROM dist as local
ARG DOCKER_BUILD_DIR

# config
COPY ${DOCKER_BUILD_DIR}/conf.d/local.cnf /etc/mysql/conf.d/

FROM local as debug
ARG DOCKER_BUILD_DIR

FROM local as tests
ARG DOCKER_BUILD_DIR

FROM tests as preprod
ARG DOCKER_BUILD_DIR

FROM preprod as prod
ARG DOCKER_BUILD_DIR
