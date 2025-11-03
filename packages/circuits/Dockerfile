FROM debian:bullseye-slim

RUN apt-get update && apt-get install -y \
    ca-certificates curl jq coreutils bash \
 && rm -rf /var/lib/apt/lists/*

WORKDIR /work
COPY publish-artifacts.sh /usr/local/bin/publish-artifacts.sh
RUN chmod +x /usr/local/bin/publish-artifacts.sh

# run with bash so brace groups and other bash-isms work
CMD ["/bin/bash","-lc","/usr/local/bin/publish-artifacts.sh"]

