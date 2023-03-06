#!/bin/sh

cd ${WORKDIR}/downloader
if [ "${AUTO_UPDATE}" = "true" ]; then
    if [ ! -s /tmp/requirements.txt.sha256sum ]; then
        sha256sum requirements.txt > /tmp/requirements.txt.sha256sum
    fi
    echo "更新程序..."
    git remote set-url origin "${REPO_URL}" &> /dev/null
    branch="master"
    git clean -dffx
    git fetch --depth 1 origin ${branch}
    git reset --hard origin/${branch}
    if [ $? -eq 0 ]; then
        echo "更新成功..."
        # Python依赖包更新
        hash_old=$(cat /tmp/requirements.txt.sha256sum)
        hash_new=$(sha256sum requirements.txt)
        if [ "${hash_old}" != "${hash_new}" ]; then
            echo "检测到requirements.txt有变化，重新安装依赖..."
            if [ "${CN_UPDATE}" = "true" ]; then
                pip install --upgrade pip setuptools wheel -i "${PYPI_MIRROR}"
                pip install -r requirements.txt -i "${PYPI_MIRROR}"
            else
                pip install --upgrade pip setuptools wheel
                pip install -r requirements.txt
            fi
            if [ $? -ne 0 ]; then
                echo "无法安装依赖，请更新镜像..."
            else
                echo "依赖安装成功..."
            fi
        fi
        # 系统软件包更新
    else
        echo "更新失败，继续使用旧的程序来启动..."
    fi
else
    echo "程序自动升级已关闭，如需自动升级请在创建容器时设置环境变量：AUTO_UPDATE=true"
fi

echo "以PUID=${PUID}，PGID=${PGID}的身份启动程序..."
mkdir -p /.pm2
chown -R "${PUID}":"${PGID}" "${WORKDIR}" /.pm2
umask "${UMASK}"
exec su-exec "${PUID}":"${PGID}" "$(which dumb-init)" "$(which pm2-runtime)" start daemon.py -n webvideo-downloader --interpreter python3
