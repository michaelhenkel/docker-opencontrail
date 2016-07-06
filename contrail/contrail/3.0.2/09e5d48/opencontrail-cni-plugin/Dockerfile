FROM golang:1.6.2-alpine
RUN apk update
RUN apk add git gcc linux-headers musl-dev
#RUN ln -s /usr/include/asm/errno.h /usr/include/errno.h
RUN go get github.com/michaelhenkel/opencontrail-cni-plugin/opencontrail
#RUN go get github.com/michaelhenkel/contrail-go-api
#RUN go get github.com/satori/go.uuid
#RUN go get github.com/pborman/uuid
RUN mkdir -p /etc/cni/net.d
COPY entrypoint.sh /
#ENTRYPOINT ["/entrypoint.sh"]
CMD ["/go/bin/opencontrail"]
