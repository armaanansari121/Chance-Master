// next.config.ts
import type { NextConfig } from "next";

const nextConfig: NextConfig = {
  webpack: (config) => {
    // enable async WebAssembly in webpack (required for torii-wasm)
    config.experiments = {
      ...(config.experiments || {}),
      asyncWebAssembly: true,
      // topLevelAwait is already on by default in recent webpack,
      // but keeping it explicit is harmless if you need it:
      topLevelAwait: true,
    };

    // ensure .wasm files are treated as async wasm modules
    config.module.rules.push({
      test: /\.wasm$/,
      type: "webassembly/async",
    });

    return config;
  },
};

export default nextConfig;

