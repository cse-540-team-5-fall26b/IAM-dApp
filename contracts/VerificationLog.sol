// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import {IVerificationLog} from "./interfaces/IVerificationLog.sol";

/// @title Verification Log
/// @notice Stores an immutable audit trail of credential verification events.
/// @dev This contract does not store full credential contents. It records only lightweight verification metadata.
contract VerificationLog is IVerificationLog {
    address public owner;
    mapping(address => bool) private approvedVerifiers;

    VerificationEntry[] private verificationHistory;

    modifier onlyOwner() {
        require(msg.sender == owner, "Caller is not owner");
        _;
    }

    modifier onlyApprovedVerifier() {
        require(approvedVerifiers[msg.sender], "Caller is not an approved verifier");
        _;
    }

    constructor() {
        owner = msg.sender;
        approvedVerifiers[msg.sender] = true;

        emit VerifierApproved(msg.sender);
    }

    function approveVerifier(address verifier) external override onlyOwner {
        require(verifier != address(0), "Invalid verifier address");

        approvedVerifiers[verifier] = true;

        emit VerifierApproved(verifier);
    }

    function removeVerifier(address verifier) external override onlyOwner {
        require(verifier != address(0), "Invalid verifier address");

        approvedVerifiers[verifier] = false;

        emit VerifierRemoved(verifier);
    }

    function isApprovedVerifier(address verifier) external view override returns (bool) {
        return approvedVerifiers[verifier];
    }

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

        emit VerificationLogged(credentialId, msg.sender, holder, result, block.timestamp);
    }

    function getVerification(uint256 index)
        external
        view
        override
        returns (VerificationEntry memory entry)
    {
        require(index < verificationHistory.length, "Verification index out of bounds");
        return verificationHistory[index];
    }

    function getVerificationCount() external view override returns (uint256) {
        return verificationHistory.length;
    }
}
