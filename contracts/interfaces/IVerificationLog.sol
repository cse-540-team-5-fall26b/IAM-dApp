// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

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
    function getVerification(uint256 index)
        external
        view
        returns (VerificationEntry memory entry);

    /// @notice Returns the total number of verification events stored.
    function getVerificationCount() external view returns (uint256);
}
