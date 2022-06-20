// SPDX-License-Identifier: GPL-3.0
pragma solidity >=0.8.0 <0.9.0;

import "../../../library/Data.sol";

interface ICreator {
    
    function createContent(
        uint256 profileId,
        Data.ContentCreationData memory data,
        uint256 appId
    )
    external returns (uint256);

    function updateContent(
        uint256 pubId,
        string memory contentUri,
        uint256 appID
    ) external;

    function setCopyRule(
        uint256 pubId,
        address copyRule, 
        bytes calldata copyRuleInitData,
        uint256 appId
    ) external;

    function removeCopyRule(
        uint256 pubId,
        uint256 appId
    ) external;

    function removeReferenceRule(
        uint256 pubId,
        uint256 appId
    ) external;

    function setReferenceRule(
        uint256 pubId,
        address referenceRule, 
        bytes calldata referenceRuleInitData,
        uint256 appId
    ) external;

    function getPostCount() external view returns (uint256 count);
    function getPostByIndex(uint256 index) external view returns (uint256 postId);
    function getPostReferenceCount(uint256 postId) external view returns (uint256 count);
    function getCopyRule(uint256 pubId) external view returns (address rule); 
      
}