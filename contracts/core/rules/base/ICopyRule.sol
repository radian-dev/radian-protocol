// SPDX-License-Identifier: GPL-3.0
pragma solidity >=0.8.0 <0.9.0;

interface ICopyRule {

    function setupRule(uint256 pubId, bytes calldata ruleData) external;

    function executeCopyRule(
        address sender, 
        uint256 fromProfileId,
        uint256 toProfileId,
        uint256 pubId,
        bool isLocked,
        string memory statement,
        bytes calldata copyRightRuleData
    ) external view;

}