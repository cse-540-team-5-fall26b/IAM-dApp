// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import {IAcademicCredentialRegistry} from "./IAcademicCredentialRegistry.sol";

interface IVerificationLog {
    struct VerificationEntry {
        string credentialId;
        address verifier;
        address holder;
        bool result;
        uint256 timestamp;
    }

    event VerificationLogged(
        string credentialId,
        address indexed verifier,
        address indexed holder,
        bool result,
        uint256 timestamp
    );

    event VerifierApproved(address indexed verifier);
    event VerifierRemoved(address indexed verifier);

    /// @notice Approves an address as a trusted verifier.
    /// @param verifier The address to be approved as a verifier.
    function approveVerifier(address verifier) external;

    /// @notice Removes an address from the list of approved verifiers.
    /// @param verifier The address to be removed.
    function removeVerifier(address verifier) external;

    /// @notice Checks whether an address is an approved verifier.
    /// @param verifier The address to check.
    /// @return True if the address is an approved verifier, otherwise false.
    function isApprovedVerifier(address verifier) external view returns (bool);

    /// @notice Sets the address of the AcademicCredentialRegistry contract.
    /// @dev Required before performing on-chain verification. Only callable by the owner.
    /// @param registryAddress The deployed address of the AcademicCredentialRegistry contract.
    function setAcademicCredentialRegistry(address registryAddress) external;

    /// @notice Verifies a credential against the AcademicCredentialRegistry and logs the result.
    /// @dev This function performs on-chain validation of the credential before logging.
    /// @param credentialId The credential to verify.
    /// @param holder The address of the credential holder.
    /// @return result True if the credential is valid, otherwise false.
    function verifyAndLogCredential(
        string calldata credentialId,
        address holder
    ) external returns (bool);

    /// @notice Records that a verifier checked a credential.
    /// @param credentialId The credential that was verified.
    /// @param holder The holder address associated with the verification event.
    /// @param result The result of the verification process.
    function logVerification(
        string calldata credentialId,
        address holder,
        bool result
    ) external;

    /// @notice Returns a verification log entry by index.
    /// @param index The index in the verification history array.
    /// @return entry The stored verification entry.
    function getVerification(
        uint256 index
    ) external view returns (VerificationEntry memory entry);

    /// @notice Returns the total number of verification events stored.
    function getVerificationCount() external view returns (uint256);
}
