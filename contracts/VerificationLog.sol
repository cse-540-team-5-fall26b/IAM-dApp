// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import {IVerificationLog} from "./interfaces/IVerificationLog.sol";

/// @title Verification Log
/// @notice Stores an immutable audit trail of credential verification events.
/// @dev This contract does not store full credential contents. It records only lightweight verification metadata.
contract VerificationLog is IVerificationLog {
    VerificationEntry[] private verificationHistory;

    function logVerification(
        string calldata credentialId,
        address holder,
        bool result
    ) external override {
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
