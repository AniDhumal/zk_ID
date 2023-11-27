const hre = require("hardhat");
const ethers = require("ethers");
const circomlibjs = require("circomlibjs");
const snarkjs = require("snarkjs");
const fs = require("fs");

// Deploy the contracts
async function deploy() {
    const dIdentityContract = await hre.ethers.deployContract("DIdentity");
    await dIdentityContract.waitForDeployment();
    console.log("DIdentity deployed to:", dIdentityContract.target);
    return dIdentityContract;
}

// Mint an Identity
async function mintIdentity(signer, name, DoB, dIdentityContract) {
    const UID = ethers.sha256(ethers.toUtf8Bytes(signer.address + name + DoB));
    const nameHash = ethers.sha256(ethers.toUtf8Bytes(signer.address + name));
    const DoBHash = await poseidonHash([signer.address, DoB]);

    const identity = {
        UID: UID,
        nameHash: nameHash,
        dobHash: DoBHash,
    }

    const tx = await dIdentityContract.mint(signer.address, identity);
    await tx.wait();
}

async function createAgeProof(signer, doBTimestamp, currentTimestamp, ageThreshold) {
    const hash = await poseidonHash([signer.address, doBTimestamp]);
    const { proof, publicSignals } = await snarkjs.groth16.fullProve(
        { doBTimestamp: doBTimestamp, address: signer.address, currentTimestamp: currentTimestamp, ageThreshold: ageThreshold, hash: hash },
        "build/age_proof_js/age_proof.wasm",
        "circuit_age.zkey");
    return { proof, publicSignals };
}

async function verifyAgeProof(address, proof, publicSignals, dIdentityContract) {
    const id = await dIdentityContract.getID(address);
    const vkey = JSON.parse(fs.readFileSync("verification_key_age.json"));
    const res = await snarkjs.groth16.verify(vkey, publicSignals, proof);
    return (res && (id.dobHash == publicSignals[3]));
}

// Poseidon Hash
async function poseidonHash(inputs) {
    const poseidon = await circomlibjs.buildPoseidon();
    const poseidonHash = poseidon.F.toString(poseidon(inputs));
    return poseidonHash;
}