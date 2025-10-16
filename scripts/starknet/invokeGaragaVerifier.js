import { RpcProvider, Contract, Account, hash, CallData } from "starknet";
import fs from "fs";


// === CONFIG ===
const CONTRACT_ADDRESS =
  "0x061b11332aec63419e264c23ebfc4e2005ea70d2cceefdeea83b867798b0cba5";
const CALLDATA_PATH = "./circuits/build/proof_calldata.txt"; // or your garaga calldata file
const RPC_URL = "http://localhost:5050";
const FORK_BLOCK = "latest"
// === MAIN ===
async function main() {
  console.log("🚀 Invoking verifier contract on Starknet...");

  const provider = new RpcProvider({ nodeUrl: RPC_URL });

  // Read and parse calldata
  const calldataRaw = fs.readFileSync(CALLDATA_PATH, "utf8").trim();
  const calldata = calldataRaw.split(/\s+/); // split by whitespace
  console.log(calldata)
  // Optionally try adding length if needed
  const calldataWithLen = [calldata.length.toString(), ...calldata];

  const blockId = { blockNumber: FORK_BLOCK };
  const { abi } = await provider.getClassAt(CONTRACT_ADDRESS, FORK_BLOCK);
  if (abi == undefined) {
    throw new Error('no abi')
  }
  const contract = new Contract(abi, CONTRACT_ADDRESS, provider);

  const cd = CallData.compile(
    {
      "full_proof_with_hints": calldata
    }
  )
  const res = await contract.call("verify_groth16_proof_bn254", cd, {
    blockIdentifier: FORK_BLOCK
  });
  // Send transaction directly
  console.log(res)
}

main().catch((err) => console.error("🔥 Script failed:", err));


