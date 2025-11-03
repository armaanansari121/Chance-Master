#!/usr/bin/env bash
set -euo pipefail

REPO_BUILD="/work/packages/circuits/build"
OUT_DIR="${OUT_DIR:-/out}"

die() {
  printf '%s\n' "$*" >&2
  exit 1
}

need() {
  for f in "$@"; do
    [ -f "${REPO_BUILD}/${f}" ] || die "Missing ${REPO_BUILD}/${f} (commit your artifacts)"
  done
}

hash_file() { sha256sum "$1" | awk '{print $1}'; }

mkdir -p "${OUT_DIR}"

# exact set we expect to exist in the repo (already committed)
need Main_0000.zkey verification_key.json Main_js/Main.wasm Main_js/generate_witness.js Main_js/witness_calculator.js

# If OUT already has artifacts, ensure they are byte-for-byte the same (no drift)
if [ -f "${OUT_DIR}/Main_0000.zkey" ] || [ -f "${OUT_DIR}/verification_key.json" ]; then
  echo "==> OUT already contains artifacts. Verifying byte-level equality…"
  for f in Main_0000.zkey verification_key.json Main_js/Main.wasm Main_js/generate_witness.js Main_js/witness_calculator.js; do
    src="${REPO_BUILD}/${f}"
    dst="${OUT_DIR}/${f}"
    [ -f "${dst}" ] || die "OUT missing ${f}. Cowardly refusing to patch. Nuke the volume if you intend to rotate."
    hs="$(hash_file "${src}")"
    hd="$(hash_file "${dst}")"
    [ "${hs}" = "${hd}" ] || die "VK/ZKey/WASM drift detected for ${f}.
Refusing to overwrite. Delete the 'circuits_build' volume if you intend a rotation."
  done
  # ✅ Ready for dependents
  touch "${OUT_DIR}/.ready"
  echo "✅ OUT artifacts match repo exactly. Nothing to do."
  exec tail -f /dev/null
fi

echo "==> Publishing committed artifacts from repo -> ${OUT_DIR}"
install -m 0644 "${REPO_BUILD}/Main_0000.zkey" "${OUT_DIR}/Main_0000.zkey"
install -m 0644 "${REPO_BUILD}/verification_key.json" "${OUT_DIR}/verification_key.json"
mkdir -p "${OUT_DIR}/Main_js"
install -m 0644 "${REPO_BUILD}/Main_js/Main.wasm" "${OUT_DIR}/Main_js/Main.wasm"
install -m 0755 "${REPO_BUILD}/Main_js/generate_witness.js" "${OUT_DIR}/Main_js/generate_witness.js"
install -m 0644 "${REPO_BUILD}/Main_js/witness_calculator.js" "${OUT_DIR}/Main_js/witness_calculator.js"

# ✅ Ready for dependents
touch "${OUT_DIR}/.ready"

echo "✅ Published. Idling."
exec tail -f /dev/null
