// SPDX-License-Identifier: GPL-3.0
pragma solidity >=0.8.0 <0.9.0;

interface IReferenceRule {

    function setupRule(uint256 pubId, bytes calldata ruleData) external;

    function executeReferenceRule(
        address sender,
        uint256 profileId,
        uint256 refId,
        bool isShare,
        bytes calldata referenceRuleData
    ) external view;

}