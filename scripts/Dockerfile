# 名称：apipark通用镜像
FROM alpine:latest

# RUN sed -i 's|https://dl-cdn.alpinelinux.org/alpine|https://mirrors.aliyun.com/alpine|g' /etc/apk/repositories  \
#     && apk update \
#     && apk add --no-cache curl tzdata bind-tools
RUN apk update \
    && apk add --no-cache curl tzdata bind-tools

ENV TZ=Asia/Taipei

RUN ln -sf /usr/share/zoneinfo/${TZ} /etc/localtime \
    && echo "Asia/Taipei" > /etc/timezone

ARG APP

ENV NSQ_ADDR=${APP}-nsq:4150
ENV NSQ_TOPIC_PREFIX=${APP}

RUN mkdir -p /${APP}

COPY cmd/* /${APP}/
COPY resource/* /${APP}/

WORKDIR /$APP
ENV ADMIN_PASSWORD=12345678

RUN chmod +x ./apipark*
RUN chmod +x ./*.sh
CMD ./docker_run.sh
