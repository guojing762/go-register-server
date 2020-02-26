FROM dockerhub.azk8s.cn/library/golang:1.13-alpine3.11 as builder
WORKDIR /go/src/github.com/choerodon/go-register-server
COPY . .
RUN GOOS=linux GOARCH=amd64 CGO_ENABLED=0 GO111MODULE=on go build -mod=vendor

FROM dockerhub.azk8s.cn/library/alpine:3.11
# Add mirror source
RUN cp /etc/apk/repositories /etc/apk/repositories.bak && \
    sed -i 's dl-cdn.alpinelinux.org mirrors.aliyun.com g' /etc/apk/repositories
RUN apk --no-cache add \
    tini \
    curl \
    bash \
    tzdata
WORKDIR /go-register-server
COPY --from=builder /go/src/github.com/choerodon/go-register-server/templates templates
COPY --from=builder /go/src/github.com/choerodon/go-register-server/static static
COPY --from=builder /go/src/github.com/choerodon/go-register-server/go-register-server /usr/bin

RUN chown -R nobody:nobody /go-register-server /usr/bin/go-register-server
USER nobody

ENTRYPOINT ["tini", "--"]
CMD ["go-register-server"]