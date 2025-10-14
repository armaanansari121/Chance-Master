# --- Stage 1: build circom binary from source ---
FROM rust:1.74-bullseye AS circom-builder

RUN apt-get update && apt-get install -y --no-install-recommends \
    build-essential git ca-certificates \
 && rm -rf /var/lib/apt/lists/*

# Build circom v2.1.9 from source
RUN git clone --depth 1 --branch v2.1.9 https://github.com/iden3/circom.git /src/circom \
 && cd /src/circom \
 && cargo build --release \
 && strip target/release/circom

# --- Stage 2: app + snarkjs + compiled artifacts + static server ---
FROM node:18-bullseye

# Minimal OS deps
RUN apt-get update && apt-get install -y --no-install-recommends \
    ca-certificates \
 && rm -rf /var/lib/apt/lists/*

# Circom binary
COPY --from=circom-builder /src/circom/target/release/circom /usr/local/bin/circom

# JS CLIs
RUN npm i -g snarkjs@0.7.5 http-server

WORKDIR /app

# Install app deps (if you have any)
COPY package*.json ./
RUN npm ci || npm i

# Project files
COPY . .

# Build artifacts once at image build time
# NOTE: requires your `setup/pot17_final.ptau` (already in your tree)
RUN mkdir -p circuits/build public/circom \
 && circom circuits/rules/Orchestrator.circom \
      --r1cs --wasm --sym \
      -o circuits/build \
      -l node_modules -l circuits/rules \
 && snarkjs groth16 setup \
      circuits/build/Orchestrator.r1cs \
      setup/pot17_final.ptau \
      circuits/build/Orchestrator_0000.zkey \
 && snarkjs zkey contribute \
      circuits/build/Orchestrator_0000.zkey \
      circuits/build/Orchestrator_final.zkey \
      --name="docker-contrib" \
      -e="docker-seed" \
 && snarkjs zkey export verificationkey \
      circuits/build/Orchestrator_final.zkey \
      circuits/build/verification_key.json \
 && cp circuits/build/Orchestrator_js/Orchestrator.wasm public/circom/Orchestrator.wasm \
 && cp circuits/build/Orchestrator_final.zkey              public/circom/Orchestrator_final.zkey \
 && cp circuits/build/verification_key.json                public/circom/verification_key.json \
 && cp circuits/inputs/input_valid.json                    public/circom/input_valid.json

EXPOSE 8080
CMD ["http-server", "-p", "8080", "public"]

