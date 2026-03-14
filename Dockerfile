ARG BASE_VERSION=3.12-alpine
FROM ghcr.io/linuxserver/unrar:latest AS unrar
FROM python:${BASE_VERSION}

# set version label
ARG MYLAR_COMMIT=build
ARG ORG=jramboz
LABEL version=${BASE_VERSION}_${MYLAR_COMMIT}

# Set environment variable for unbuffered output
ENV PYTHONUNBUFFERED=1

RUN \
echo "**** install system packages ****" && \
 apk add --no-cache \
 git \
 # cfscrape dependecies
 nodejs \
 # unrar-cffi & Pillow dependencies
 build-base \
 # unar-cffi dependencies
 libffi-dev \
 # Pillow dependencies
 zlib-dev \
 jpeg-dev

# It might be better to check out release tags than python3-dev HEAD.
# For development work I reccomend mounting a full git repo from the
# docker host over /app/mylar.
RUN echo "**** install app ****" && \
 git config --global advice.detachedHead false && \
 git clone https://github.com/${ORG}/mylar3.git --depth 1 --branch ${MYLAR_COMMIT} --single-branch /app/mylar

RUN echo "**** install requirements ****" && \
 pip3 install --no-cache-dir -U -r /app/mylar/requirements.txt && \
 rm -rf ~/.cache/pip/*

# add unrar
COPY --from=unrar /usr/bin/unrar-ubuntu /usr/bin/unrar

# TODO image could be further slimmed by moving python wheel building into a
# build image and copying the results to the final image.

# ports and volumes
# VOLUME /config /comics /downloads
EXPOSE 8090
CMD ["python3", "/app/mylar/Mylar.py", "--nolaunch", "--datadir", "/config/mylar"]
