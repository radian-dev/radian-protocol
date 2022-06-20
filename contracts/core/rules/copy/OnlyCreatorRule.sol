// SPDX-License-Identifier: GPL-3.0
pragma solidity >=0.8.0 <0.9.0;

import "../base/BaseCopyRule.sol";

import "@openzeppelin/contracts/token/ERC721/IERC721.sol";

contract OnlyCreatorRule is BaseCopyRule {

    string private constant CREATOR_ERR = "Not Pub Creator";
    
    constructor(address _adminContract) BaseCopyRule(_adminContract) {}
    
    function setupRule(uint256 pubId, bytes calldata ruleData) onlyCreator external override {return;}

    function executeCopyRule(
        address sender,
        uint256 fromProfileId,
        uint256 toProfileId,
        uint256 pubId,
        bool isLocked,
        string memory statement,
        bytes calldata copyRuleData
    ) onlyCopy external view override {
        _executeRule(sender, pubId, copyRuleData);
    }
    
    function _executeRule(address sender, uint256 pubId, bytes calldata data) internal view {
        address creatorContract = IAdminUpgradeable(adminContract).getContract(Data.Modules.CREATOR);
        uint256 creatorProfileId = IRNFT(creatorContract).getTokenCreator(pubId);
        require( sender == IRNFT(creatorContract).addressOwnerOfEntity(creatorProfileId), CREATOR_ERR);
    }

}