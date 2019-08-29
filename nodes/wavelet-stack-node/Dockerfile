FROM ${REGISTRY}/wavelet
RUN apk add --no-cache curl bash jq
ADD bin /opt/perlin/bin
ADD etc /opt/perlin/etc
ENTRYPOINT ["/opt/perlin/bin/init"]
