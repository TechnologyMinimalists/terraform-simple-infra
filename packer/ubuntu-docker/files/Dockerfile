FROM jenkins/jenkins:lts-alpine

USER root

RUN apk update && apk add --no-cache python3 python2 py3-virtualenv py2-virtualenv && \
 python3 -m ensurepip && \
 python2 -m ensurepip && \
 pip3 install --upgrade pip setuptools && \
 if [ ! -e /usr/bin/pip ]; then ln -s pip3 /usr/bin/pip ; fi && \
 if [[ ! -e /usr/bin/python ]]; then ln -sf /usr/bin/python3 /usr/bin/python; fi
RUN apk add --no-cache pkgconf build-base \
 python3-dev python2-dev libressl-dev musl-dev \
 libffi-dev && \
 rm -r /root/.cache
