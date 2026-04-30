# Final Demo Testing Guide

This guide gives the exact local flow to use before recording the final CSE 540 project demo.

## 1. Start Local Blockchain

Terminal 1:

```bash
npx hardhat node
```

Keep this terminal open.

## 2. Deploy Contracts

Terminal 2:

```bash
npx hardhat compile
npx hardhat run scripts/deploy.js --network localhost
```

Copy the deployed addresses for:

- DIDRegistry
- AcademicCredentialRegistry
- VerificationLog

## 3. Start Frontend

Terminal 3:

```bash
cd frontend_1
npx live-server
```

Open the local page in the browser.

## 4. Connect MetaMask

Use the Hardhat Local network:

```text
RPC URL: http://127.0.0.1:8545
Chain ID: 31337
Currency: ETH
```

Import a Hardhat account using one of the private keys printed by `npx hardhat node`.

## 5. Load Contracts

Paste all three deployed contract addresses into the frontend and click **Load Contracts**.

Expected log:

```text
Contracts Loaded Successfully
```

## 6. Test DID Registry

Use:

```text
DID: did:student:100
Public Key: pubKey100
Service Endpoint: http://student100.com
Document Hash: 0xaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa
```

Click **Register**.

Then resolve:

```text
DID: did:student:100
```

Expected:

```text
active: true
controller: connected MetaMask account
```

Check controller using the connected account address.

Expected:

```text
Is Controller: true
```

## 7. Test Academic Credential Registry

Approve the issuer first.

```text
Approve Issuer Address: connected MetaMask account
```

Click **Approve Issuer**.

Then check issuer:

```text
Issuer Address: connected MetaMask account
```

Expected:

```text
Is Approved Issuer: true
```

Issue credential:

```text
Credential ID: cred500
Holder DID: did:student:100
Credential Hash: 0xbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb
Metadata URI: ipfs://metadata500
Expires At: 1893456000
```

Expected:

```text
Credential Issued Successfully
```

Get credential:

```text
Credential ID: cred500
```

Expected:

```text
issuer: connected MetaMask account
holderDID: did:student:100
status: 0
```

Check validity:

```text
Credential ID: cred500
```

Expected:

```text
Is Credential Valid: true
```

## 8. Test Verification Log

Log verification:

```text
Credential ID: cred500
Holder Address: connected MetaMask account or another Hardhat account
Result: Valid
```

Expected:

```text
Verification Logged Successfully
```

Get verification:

```text
Index: 0
```

Expected:

```text
credentialId: cred500
result: true
```

Get count.

Expected:

```text
Total Verifications: 1
```

## 9. Final Recording Checklist

- Show the GitHub repo structure.
- Show contracts folder and explain the three contracts.
- Run `npx hardhat test` and show passing tests.
- Start local Hardhat node.
- Deploy contracts.
- Use frontend to demonstrate DID registration, credential issuance, credential validity check, and verification logging.
- Briefly discuss privacy, gas/scalability tradeoffs, and future work.
