async function main() {
  const DIDRegistry = await ethers.getContractFactory("DIDRegistry");
  const didRegistry = await DIDRegistry.deploy();
  await didRegistry.waitForDeployment();

  const AcademicCredentialRegistry = await ethers.getContractFactory("AcademicCredentialRegistry");
  const academicCredentialRegistry = await AcademicCredentialRegistry.deploy();
  await academicCredentialRegistry.waitForDeployment();

  const VerificationLog = await ethers.getContractFactory("VerificationLog");
  const verificationLog = await VerificationLog.deploy();
  await verificationLog.waitForDeployment();

  console.log("DIDRegistry deployed to:", await didRegistry.getAddress());
  console.log("AcademicCredentialRegistry deployed to:", await academicCredentialRegistry.getAddress());
  console.log("VerificationLog deployed to:", await verificationLog.getAddress());
}

main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});
