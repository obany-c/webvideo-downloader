FROM alpine
RUN apk add --no-cache ffmpeg \
    && apk add --no-cache git \
    && apk add --no-cache dumb-init \
    && apk add --no-cache su-exec \
    && apk add --no-cache npm \
    && apk add --no-cache py3-pip \
    && ln -sf /usr/share/zoneinfo/${TZ} /etc/localtime \
    && echo "${TZ}" > /etc/timezone \
    && ln -sf /usr/bin/python3 /usr/bin/python \
    && pip install --upgrade pip setuptools wheel \
    && pip install -r https://raw.githubusercontent.com/obany-c/webvideo-downloader/master/downloader/requirements.txt \
    && npm install pm2 -g \
    && rm -rf /tmp/* /root/.cache /var/cache/apk/*
ENV LANG="C.UTF-8" \
    TZ="Asia/Shanghai" \
    REPO_URL="https://github.com/obany-c/webvideo-downloader.git" \
    PYPI_MIRROR="https://pypi.tuna.tsinghua.edu.cn/simple" \
    ALPINE_MIRROR="mirrors.ustc.edu.cn" \
    WORKDIR="/vd" \
    AUTO_UPDATE=true \
    CN_UPDATE=true \
    PUID=0 \
    PGID=0 \
    UMASK=000
WORKDIR ${WORKDIR}
RUN python_ver=$(python3 -V | awk '{print $2}') \
    && echo "${WORKDIR}/" > /usr/lib/python${python_ver%.*}/site-packages/webvideo-downloader.pth \
    && git clone -b master ${REPO_URL} ${WORKDIR} --depth=1 --recurse-submodule \
    && git config --global --add safe.directory ${WORKDIR}
EXPOSE 18888
VOLUME ["/vd/temp"]
VOLUME ["/vd/videos"]
VOLUME ["/vd/logs"]
ENTRYPOINT ["/webvideo-downloader/docker/entrypoint.sh"]