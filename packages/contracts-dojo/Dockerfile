FROM ubuntu:24.04

ARG DEBIAN_FRONTEND=noninteractive
RUN apt-get update && apt-get install -y \
    bash curl git ca-certificates procps \
 && rm -rf /var/lib/apt/lists/*

# asdf
ENV ASDF_DIR=/root/.asdf
RUN git clone https://github.com/asdf-vm/asdf.git $ASDF_DIR --branch v0.14.0
ENV PATH="$ASDF_DIR/bin:$ASDF_DIR/shims:$PATH"

# plugins
RUN asdf plugin add katana https://github.com/dojoengine/asdf-katana.git || true \
 && asdf plugin add torii  https://github.com/dojoengine/asdf-torii.git  || true \
 && asdf plugin add sozo   https://github.com/dojoengine/asdf-sozo.git   || true

# pinned versions
ENV KATANA_VER=1.7.0
ENV TORII_VER=1.8.4
ENV SOZO_VER=1.7.0
RUN asdf install katana $KATANA_VER && asdf global katana $KATANA_VER \
 && asdf install torii  $TORII_VER && asdf global torii  $TORII_VER \
 && asdf install sozo   $SOZO_VER && asdf global sozo   $SOZO_VER

CMD ["/bin/bash"]

