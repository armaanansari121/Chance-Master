import { RpcProvider, Contract, Account, hash } from "starknet";
import fs from "fs";


// === CONFIG ===
const CONTRACT_ADDRESS =
  "0x073c14fb2490b66fac2bbdf2936e4773d40b49a5a9286279924ad1f8d5bd3b40";
const CALLDATA_PATH = "./circuits/build/proof_calldata.txt"; // or your garaga calldata file
const RPC_URL = "https://starknet-sepolia.public.blastapi.io/rpc/v0_8";

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

  const { abi: testAbi } = await provider.getClassAt(CONTRACT_ADDRESS);
  if (testAbi == undefined) {
    throw new Error('no abi')
  }
  const contract = new Contract(testAbi, CONTRACT_ADDRESS, provider);

  const res = await contract.verify_groth16_proof_bn254(calldata);
  // Send transaction directly
  console.log(res)
}

main().catch((err) => console.error("🔥 Script failed:", err));


