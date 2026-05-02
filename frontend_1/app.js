let web3;
let account;
let didRegistry;
let academicRegistry;
let verificationLog;
let isConnected = false;

// ================= HELPERS =================
function log(message) {
    const box = document.getElementById("logBox");
    const time = new Date().toLocaleTimeString();
    box.innerHTML += `[${time}] ${message}<br>`;
    box.scrollTop = box.scrollHeight;
}

function getValue(id) {
    return document.getElementById(id).value.trim();
}

function setText(id, value) {
    document.getElementById(id).innerText = value;
}

function formatError(error) {
    if (!error) return "Unknown error";
    if (error?.data?.message) return error.data.message;
    if (error?.message) return error.message;
    return String(error);
}

function ensureLoaded(contract, contractName) {
    if (!isConnected) {
        log("Connect MetaMask first");
        return false;
    }

    if (!contract) {
        log(`${contractName} is not loaded yet. Paste contract addresses and click Load Contracts.`);
        return false;
    }

    return true;
}

function useConnectedAccount(inputId) {
    if (!account) {
        log("Connect MetaMask first");
        return;
    }

    document.getElementById(inputId).value = account;
    log(`Filled ${inputId} with connected account`);
}

// ================= CONNECT =================
async function connectWallet() {
    try {
        if (!window.ethereum) {
            log("MetaMask not installed");
            return;
        }

        web3 = new Web3(window.ethereum);
        await window.ethereum.request({ method: "eth_requestAccounts" });

        const accounts = await web3.eth.getAccounts();
        account = accounts[0];

        const networkId = await web3.eth.net.getId();
        const networkType = await web3.eth.net.getNetworkType();

        isConnected = true;

        setText("web3Status", "Connected");
        document.getElementById("web3Status").className = "connected";
        setText("accountNumber", account);
        setText("networkName", `${networkType} (ID: ${networkId})`);

        log(`Wallet Connected: ${account}`);

        window.ethereum.on("accountsChanged", function (accounts) {
            account = accounts[0];
            setText("accountNumber", account || "-");
            log(`Account changed: ${account}`);
        });

        window.ethereum.on("chainChanged", function () {
            window.location.reload();
        });
    } catch (error) {
        log(`Connection Failed: ${formatError(error)}`);
    }
}

//================== VERIFY INPUTS ==================
function highlightError(id) {
    const el = document.getElementById(id);
    el.style.border = "2px solid red";
    setTimeout(() => el.style.border = "", 2000);
}

function requireField(id, label, mlbl = null) {
    const value = getValue(id);

    if (!value) {
        if (mlbl !== null) {
            setText(mlbl, `${label} is required`);
        }
        log(`${label} is required`);
        highlightError(id)
        return null;
    }

    return value;
}

function requireAddress(id, label) {
    const value = getValue(id);

    if (!value) {
        log(`${label} is required`);
        return null;
    }

    if (!web3.utils.isAddress(value)) {
        log(`${label} must be a valid address`);
        return null;
    }

    return value;
}

function requireBytes32(id, label) {
    const value = getValue(id);

    if (!value) {
        log(`${label} is required`);
        return null;
    }

    if (!/^0x[a-fA-F0-9]{64}$/.test(value)) {
        log(`${label} must be a valid bytes32 (0x + 64 hex chars)`);
        return null;
    }

    return value;
}


// ================= LOAD CONTRACTS =================
async function loadContracts() {
    if (!isConnected) {
        log("Connect wallet first");
        return;
    }

    try {
        const didAddress = getValue("didAddressInput");
        const academicAddress = getValue("academicAddressInput");
        const verificationAddress = getValue("verificationAddressInput");

        if (!web3.utils.isAddress(didAddress) || !web3.utils.isAddress(academicAddress) || !web3.utils.isAddress(verificationAddress)) {
            log("Contract Loading Failed: one or more contract addresses are invalid");
            return;
        }

        const didABI = await fetch("./abi/DIDRegistry.json").then(r => r.json());
        const academicABI = await fetch("./abi/AcademicCredentialRegistry.json").then(r => r.json());
        const verificationABI = await fetch("./abi/VerificationLog.json").then(r => r.json());

        didRegistry = new web3.eth.Contract(didABI, didAddress);
        academicRegistry = new web3.eth.Contract(academicABI, academicAddress);
        verificationLog = new web3.eth.Contract(verificationABI, verificationAddress);

        log("Contracts Loaded Successfully");
    } catch (error) {
        log(`Contract Loading Failed: ${formatError(error)}`);
    }
}

// ================= SECTION =================
function openSection() {
    const selected = document.getElementById("sectionSelector").value;
    const sections = ["didSection", "credentialSection", "verificationSection"];
    sections.forEach(id => document.getElementById(id).style.display = "none");
    if (selected) document.getElementById(selected).style.display = "block";
}

// ================= DID =================
async function registerDID() {
    if (!ensureLoaded(didRegistry, "DID Registry")) return;

    const did = requireField("did", "DID");
    const publicKey = requireField("publicKey", "Public Key");
    const serviceEndpoint = requireField("serviceEndpoint", "Service Endpoint");
    const docHash = requireBytes32("docHash", "Document Hash");

    if (!did || !publicKey || !serviceEndpoint || !docHash) return;

    try {
        await didRegistry.methods.registerDID(
            getValue("did"),
            getValue("publicKey"),
            getValue("serviceEndpoint"),
            getValue("docHash")
        ).send({ from: account });
        log("DID Registered Successfully");
    } catch (error) {
        log(`DID Register Failed: ${formatError(error)}`);
    }
}

async function updateDID() {
    if (!ensureLoaded(didRegistry, "DID Registry")) return;

    try {
        await didRegistry.methods.updateDID(
            getValue("updateDid"),
            getValue("updatePublicKey"),
            getValue("updateServiceEndpoint"),
            getValue("updateDocHash")
        ).send({ from: account });
        log("DID Updated Successfully");
    } catch (error) {
        log(`Update Failed: ${formatError(error)}`);
    }
}

async function deactivateDID() {
    if (!ensureLoaded(didRegistry, "DID Registry")) return;

    const did = requireField("deactivateDid", "DID");
    if (!did) return;

    try {
        await didRegistry.methods.deactivateDID(getValue("deactivateDid")).send({ from: account });
        log("DID Deactivated Successfully");
    } catch (error) {
        log(`Deactivate Failed: ${formatError(error)}`);
    }
}

async function resolveDID() {
    if (!ensureLoaded(didRegistry, "DID Registry")) return;

    const did = requireField("resolveDid", "DID", "resolveResult");
    if (!did) return;

    try {
        const record = await didRegistry.methods.resolveDID(getValue("resolveDid")).call();
        setText("resolveResult", JSON.stringify(record, null, 2));
        log("DID Resolved Successfully");
    } catch (error) {
        log(`Resolve Failed: ${formatError(error)}`);
    }
}

async function checkController() {
    if (!ensureLoaded(didRegistry, "DID Registry")) return;

    try {
        const result = await didRegistry.methods.isController(
            getValue("controllerDid"),
            getValue("controllerAddress")
        ).call();
        setText("controllerResult", `Is Controller: ${result}`);
        log(`Controller Checked: ${result}`);
    } catch (error) {
        log(`Controller Check Failed: ${formatError(error)}`);
    }
}

// ================= CREDENTIAL =================
async function approveIssuer() {
    if (!ensureLoaded(academicRegistry, "Academic Credential Registry")) return;

    try {
        const issuerAddress = getValue("approveIssuerAddress");

        if (!web3.utils.isAddress(issuerAddress)) {
            log("Approve Issuer Failed: invalid issuer address");
            return;
        }

        await academicRegistry.methods.approveIssuer(issuerAddress).send({ from: account });
        log(`Issuer Approved Successfully: ${issuerAddress}`);
    } catch (error) {
        log(`Approve Issuer Failed: ${formatError(error)}`);
    }
}

async function checkIssuer() {
    if (!ensureLoaded(academicRegistry, "Academic Credential Registry")) return;

    try {
        const issuerAddress = getValue("checkIssuerAddress");

        if (!web3.utils.isAddress(issuerAddress)) {
            log("Issuer Check Failed: invalid issuer address");
            return;
        }

        const result = await academicRegistry.methods.isApprovedIssuer(issuerAddress).call();
        setText("issuerResult", `Is Approved Issuer: ${result}`);
        log(`Issuer Checked: ${result}`);
    } catch (error) {
        log(`Issuer Check Failed: ${formatError(error)}`);
    }
}

async function issueCredential() {
    if (!ensureLoaded(academicRegistry, "Academic Credential Registry")) return;

    try {
        const expiry = getValue("expiresAt") || "0";

        await academicRegistry.methods.issueCredential(
            getValue("credentialId"),
            getValue("holderDID"),
            getValue("credentialHash"),
            getValue("metadataURI"),
            expiry
        ).send({ from: account });
        log("Credential Issued Successfully");
    } catch (error) {
        log(`Issue Failed: ${formatError(error)}`);
    }
}

async function revokeCredential() {
    if (!ensureLoaded(academicRegistry, "Academic Credential Registry")) return;

    const credentialId = requireField("revokeCredentialId", "Credential ID");
    if (!credentialId) return;

    try {
        await academicRegistry.methods.revokeCredential(getValue("revokeCredentialId")).send({ from: account });
        log("Credential Revoked Successfully");
    } catch (error) {
        log(`Revoke Failed: ${formatError(error)}`);
    }
}

async function expireCredential() {
    if (!ensureLoaded(academicRegistry, "Academic Credential Registry")) return;

    const credentialId = requireField("expireCredentialId", "Credential ID");
    if (!credentialId) return;

    try {
        await academicRegistry.methods.markCredentialExpired(getValue("expireCredentialId")).send({ from: account });
        log("Credential Expired Successfully");
    } catch (error) {
        log(`Expire Failed: ${formatError(error)}`);
    }
}

async function getCredential() {
    if (!ensureLoaded(academicRegistry, "Academic Credential Registry")) return;

    const credentialId = requireField("getCredentialId", "Credential ID", "credentialDetails");
    if (!credentialId) return;

    try {
        const record = await academicRegistry.methods.getCredential(getValue("getCredentialId")).call();
        setText("credentialDetails", JSON.stringify(record, null, 2));
        log("Credential Retrieved Successfully");
    } catch (error) {
        log(`Get Failed: ${formatError(error)}`);
    }
}

async function checkCredentialValidity() {
    if (!ensureLoaded(academicRegistry, "Academic Credential Registry")) return;

    const credentialId = requireField("checkCredentialId", "Credential ID", "validityResult");
    if (!credentialId) return;

    try {
        const result = await academicRegistry.methods.isCredentialValid(getValue("checkCredentialId")).call();
        setText("validityResult", `Is Credential Valid: ${result}`);
        log(`Validity Checked: ${result}`);
    } catch (error) {
        log(`Validity Failed: ${formatError(error)}`);
    }
}

// ================= VERIFICATION =================
async function logVerification() {
    if (!ensureLoaded(verificationLog, "Verification Log")) return;

    try {
        const holder = getValue("holderAddress");

        if (!web3.utils.isAddress(holder)) {
            log("Log Verification Failed: invalid holder address");
            return;
        }

        await verificationLog.methods.logVerification(
            getValue("verifyCredentialId"),
            holder,
            getValue("verifyResult") === "true"
        ).send({ from: account });
        log("Verification Logged Successfully");
    } catch (error) {
        log(`Log Verification Failed: ${formatError(error)}`);
    }
}

async function getVerification() {
    if (!ensureLoaded(verificationLog, "Verification Log")) return;

    try {
        const record = await verificationLog.methods.getVerification(getValue("verificationIndex")).call();
        setText("verificationDetails", JSON.stringify(record, null, 2));
        log("Verification Retrieved Successfully");
    } catch (error) {
        log(`Get Verification Failed: ${formatError(error)}`);
    }
}

async function getVerificationCount() {
    if (!ensureLoaded(verificationLog, "Verification Log")) return;

    try {
        const count = await verificationLog.methods.getVerificationCount().call();
        setText("verificationCount", `Total Verifications: ${count}`);
        log(`Verification Count Retrieved: ${count}`);
    } catch (error) {
        log(`Count Failed: ${formatError(error)}`);
    }
}
