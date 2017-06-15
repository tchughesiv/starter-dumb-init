### docker build --pull -t acme/starter-dumb-init:centos7 -f Dockerfile.centos7 .
FROM docker.io/centos:7
MAINTAINER Red Hat Systems Engineering <refarch-feedback@redhat.com>

### Atomic/OpenShift Labels - https://github.com/projectatomic/ContainerApplicationGenericLabels
LABEL name="acme/starter-dumb-init" \
      vendor="Acme Corp" \
      version="3.2" \
      release="1" \
### Required labels above - recommended below
      url="https://www.acme.io" \
      summary="Acme Corp's Starter app" \
      description="Starter app will do ....." \
      run='docker run -tdi --name ${NAME} ${IMAGE}' \
      io.k8s.description="Starter app will do ....." \
      io.k8s.display-name="Starter app" \
      io.openshift.expose-services="" \
      io.openshift.tags="acme,starter-dumb-init"

COPY user_setup /tmp/

RUN yum -y install centos-release-scl && \
### add your package needs to this installation line
    yum -y install --setopt=tsflags=nodocs rh-python35-python-pip && \
### install dumb-init
    source scl_source enable rh-python35 && \
    pip install --upgrade pip && \
    pip install --no-cache-dir dumb-init && \
    python -m pip uninstall -y pip setuptools && \
    yum clean all

### Setup user for build execution and application runtime
ENV APP_ROOT=/opt/app-root \
    USER_NAME=default \
    USER_UID=10001
ENV APP_HOME=${APP_ROOT}/src PATH=$PATH:${APP_ROOT}/bin
RUN mkdir -p ${APP_HOME}
COPY bin/ ${APP_ROOT}/bin/
RUN chmod -R ug+x ${APP_ROOT}/bin /tmp/user_setup && sync && \
    /tmp/user_setup

####### Add app-specific needs below. #######
### Containers should NOT run as root as a good practice
USER 10001
WORKDIR ${APP_ROOT}

ENTRYPOINT ["entrypoint"]
CMD ["run"]