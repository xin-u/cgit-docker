FROM nginx:1.23-alpine

# CGit default options
ENV CGIT_TITLE="CGit"
ENV CGIT_DESC="The hyperfast web frontend for Git repositories"
ENV CGIT_VROOT="/"
ENV CGIT_SECTION_FROM_STARTPATH=0
ENV CGIT_MAX_REPO_COUNT=50

RUN set -eux \
    && sed -i 's/dl-cdn.alpinelinux.org/mirrors.tuna.tsinghua.edu.cn/g' /etc/apk/repositories \
    && apk add --no-cache \
        ca-certificates \
        cgit \
        fcgiwrap \
        git \
        git-daemon \
        lua5.3-libs \
        py3-markdown \
        py3-pygments \
        python3 \
        spawn-fcgi \
        tzdata \
        xz \
        zlib \
    && rm -rf /var/cache/apk/* \
    && rm -rf /tmp/* \
    && true

COPY cgit/cgit.conf /tmp/cgitrc.tmpl
COPY docker-entrypoint.sh /
COPY nginx/nginx.conf /etc/nginx/nginx.conf
COPY nginx/conf.d/default.conf /etc/nginx/conf.d/default.conf

RUN set -eux \
    && echo "Creating application directories..." \
    && mkdir -p /var/cache/cgit \
    && mkdir -p /srv/git \
    && echo "Testing Nginx server configuration files..." \
    && nginx -c /etc/nginx/nginx.conf -t \
    && echo "Add git group and add nginx user to git group..." \
    && addgroup -S -g 1000 git \
    && adduser -S -D -H -h /var/lib/git -s /sbin/nologin -u 1000 -G git -g git git \
    && addgroup nginx git \
    && true

ENTRYPOINT [ "/docker-entrypoint.sh" ]

EXPOSE 80

STOPSIGNAL SIGQUIT

CMD [ "nginx", "-g", "daemon off;" ]