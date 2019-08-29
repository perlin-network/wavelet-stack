# Use the official HAProxy image
FROM haproxy:latest

# Install additional packages
RUN apt update && \
        DEBIAN_FRONTEND=noninteractive apt upgrade -yq && \
        DEBIAN_FRONTEND=noninteractive apt install -yq bash curl jq procps && \
        apt clean

# Patch the entrypoint to run our re-configuration script
RUN awk '/^exec /{ print "if [ \"$1\" = \"haproxy\" ]; then /usr/local/bin/create-haproxy-cfg; fi" } { print }' < /docker-entrypoint.sh > /docker-entrypoint.sh.new && \
	cat /docker-entrypoint.sh.new > /docker-entrypoint.sh && \
	rm -f /docker-entrypoint.sh.new

# Install our configuration
COPY bin/* /usr/local/bin/
COPY etc/haproxy.cfg.in /usr/local/etc/haproxy/haproxy.cfg.in
