# apps/web/Dockerfile (or keep it at repo root; adjust COPY paths accordingly)
FROM node:22-bullseye AS base

# Enable Corepack (ships with Node 16.19+), which provides pnpm
ENV PNPM_HOME="/pnpm"
ENV PATH="$PNPM_HOME:$PATH"
RUN corepack enable

# Use a consistent workdir
WORKDIR /app

# Dev env flags (hot reload over Docker)
ENV NODE_ENV=development
ENV WATCHPACK_POLLING=true
ENV CHOKIDAR_USEPOLLING=true
ENV HOSTNAME=0.0.0.0
ENV PORT=3000

# 1) Copy only metadata first for better caching
#    - workspace file (required for -w / filtered installs)
#    - root package.json + lockfile (pnpm lockfile recommended)
COPY pnpm-workspace.yaml ./
COPY package.json pnpm-lock.yaml ./

#    - web workspace manifest (so filtered installs cache when it changes)
COPY apps/web/package.json apps/web/package.json
#    - if web depends on local packages, copy their manifests too:
# COPY packages/*/package.json packages/*/package.json

# 2) Pre-fetch deps into the content-addressable store
#    This caches extremely well because it's keyed only by pnpm-lock.yaml
RUN pnpm fetch

# 3) Now copy the whole repo
COPY . .

# 4) Install workspace deps from the fetched store (no network)
#    Limit install to the web workspace for speed.
#    You can filter by dir or by package name if you have "name" in package.json.
RUN pnpm -w install --offline --frozen-lockfile --filter ./apps/web --include-workspace-root=false

# 5) Run the dev server from the web workspace
WORKDIR /app/apps/web
# Tip: Next.js accepts -H and -p; pnpm passes args after --
CMD ["pnpm", "dev", "--", "-H", "0.0.0.0", "-p", "3000"]

