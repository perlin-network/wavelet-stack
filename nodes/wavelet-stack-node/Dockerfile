FROM golang:1.13-alpine AS golang
RUN apk update && apk add git
RUN go get -u github.com/go-delve/delve/cmd/dlv

FROM ${REGISTRY}/wavelet:${WAVELET_TAG}
COPY --from=golang /go/bin/dlv /opt/perlin/bin/
RUN apk add --no-cache curl bash jq
ADD bin /opt/perlin/bin
ADD etc /opt/perlin/etc
ENTRYPOINT ["/opt/perlin/bin/init"]
