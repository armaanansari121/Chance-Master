import fs from "fs";
import path from "path";
import { groth16 } from "snarkjs";

async function main() {
  const base = "circuits/build";
  const inputPath = "circuits/inputs/input.json";

  const wasm = path.join(base, "Orchestrator_js/Orchestrator.wasm");
  const zkey = path.join(base, "Orchestrator_final.zkey");
  const vkPath = path.join(base, "verification_key.json");

  const input = JSON.parse(fs.readFileSync(inputPath, "utf8"));
  const vk = JSON.parse(fs.readFileSync(vkPath, "utf8"));

  const { proof, publicSignals } = await groth16.fullProve(input, wasm, zkey);
  fs.writeFileSync(path.join(base, "proof.json"), JSON.stringify(proof, null, 2));
  fs.writeFileSync(path.join(base, "public.json"), JSON.stringify(publicSignals, null, 2));

  const ok = await groth16.verify(vk, publicSignals, proof);
  console.log("verify:", ok ? "OK" : "FAIL");
  console.log("proof.json and public.json written under circuits/build/");
}

main().catch(e => {
  console.error(e);
  process.exit(1);
});

