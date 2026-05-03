// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import {IVerificationLog} from "./interfaces/IVerificationLog.sol";
import {IAcademicCredentialRegistry} from "./interfaces/IAcademicCredentialRegistry.sol";

/// @title Verification Log
/// @notice Stores an immutable audit trail of credential verification events.
/// @dev This contract does not store full credential contents. It records only lightweight verification metadata.
contract VerificationLog is IVerificationLog {
    address public owner;
    mapping(address => bool) private approvedVerifiers;
    IAcademicCredentialRegistry public academicCredentialRegistry;

    VerificationEntry[] private verificationHistory;

    modifier onlyOwner() {
        require(msg.sender == owner, "Caller is not owner");
        _;
    }

    modifier onlyApprovedVerifier() {
        require(
            approvedVerifiers[msg.sender],
            "Caller is not an approved verifier"
        );
        _;
    }

    constructor() {
        owner = msg.sender;
        approvedVerifiers[msg.sender] = true;

        emit VerifierApproved(msg.sender);
    }

    /// @notice Approves an address as a trusted verifier.
    /// @param verifier The address to approve.
    function approveVerifier(address verifier) external override onlyOwner {
        require(verifier != address(0), "Invalid verifier address");

        approvedVerifiers[verifier] = true;

        emit VerifierApproved(verifier);
    }

    /// @notice Removes a verifier from the approved list.
    /// @dev Prevents the address from performing or logging verifications.
    /// @param verifier The address to remove.
    function removeVerifier(address verifier) external override onlyOwner {
        require(verifier != address(0), "Invalid verifier address");

        approvedVerifiers[verifier] = false;

        emit VerifierRemoved(verifier);
    }

    /// @notice Checks if an address is an approved verifier.
    /// @param verifier The address to check.
    /// @return True if approved, false otherwise.
    function isApprovedVerifier(
        address verifier
    ) external view override returns (bool) {
        return approvedVerifiers[verifier];
    }

    /// @notice Sets the AcademicCredentialRegistry contract used for validation.
    /// @dev Must be set before calling verifyAndLogCredential. Only owner can call.
    /// @param registryAddress The address of the credential registry contract.
    function setAcademicCredentialRegistry(
        address registryAddress
    ) external override onlyOwner {
        require(registryAddress != address(0), "Invalid registry address");

        academicCredentialRegistry = IAcademicCredentialRegistry(
            registryAddress
        );
    }

    /// @notice Verifies a credential on-chain and logs the result.
    /// @dev Calls AcademicCredentialRegistry to check credential validity.
    ///      The verification result is then recorded immutably.
    ///      Only approved verifiers can call this function.
    /// @param credentialId The credential to verify.
    /// @param holder The address of the credential holder.
    /// @return result True if the credential is valid, false otherwise.
    function verifyAndLogCredential(
        string calldata credentialId,
        address holder
    ) external override onlyApprovedVerifier returns (bool) {
        require(
            address(academicCredentialRegistry) != address(0),
            "Credential registry not set"
        );
        require(bytes(credentialId).length > 0, "Credential ID is required");
        require(holder != address(0), "Invalid holder address");

        bool result = academicCredentialRegistry.isCredentialValid(
            credentialId
        );

        verificationHistory.push(
            VerificationEntry({
                credentialId: credentialId,
                verifier: msg.sender,
                holder: holder,
                result: result,
                timestamp: block.timestamp
            })
        );

        emit VerificationLogged(
            credentialId,
            msg.sender,
            holder,
            result,
            block.timestamp
        );

        return result;
    }

    /// @dev This function does NOT validate credentials. Use verifyAndLogCredential for on-chain verification.
    function logVerification(
        string calldata credentialId,
        address holder,
        bool result
    ) external override onlyApprovedVerifier {
        require(bytes(credentialId).length > 0, "Credential ID is required");
        require(holder != address(0), "Invalid holder address");

        verificationHistory.push(
            VerificationEntry({
                credentialId: credentialId,
                verifier: msg.sender,
                holder: holder,
                result: result,
                timestamp: block.timestamp
            })
        );

        emit VerificationLogged(
            credentialId,
            msg.sender,
            holder,
            result,
            block.timestamp
        );
    }

    /// @notice Retrieves a verification record by index.
    /// @param index The index of the verification entry.
    /// @return entry The verification entry.
    function getVerification(
        uint256 index
    ) external view override returns (VerificationEntry memory entry) {
        require(
            index < verificationHistory.length,
            "Verification index out of bounds"
        );
        return verificationHistory[index];
    }

    /// @notice Returns the total number of verification records.
    /// @return The number of stored verification entries.
    function getVerificationCount() external view override returns (uint256) {
        return verificationHistory.length;
    }
}
