// SPDX-License-Identifier: GPL-3.0
pragma solidity >=0.8.0 <0.9.0;

import "../base/BaseCopyRule.sol";
import "@openzeppelin/contracts/token/ERC721/IERC721.sol";

struct CopyType {
    string statement;
    bool isLocked;
}

contract UnLimitedMintRule is BaseCopyRule {

    string private constant TYPE_ERR = "COPY TYPE NOT MATCH";

    // pubId => RuleData
    mapping(uint256=>CopyType) private _copyRule;

    constructor(address _adminContract) BaseCopyRule(_adminContract){}

    function setupRule(uint256 pubId, bytes calldata ruleData) onlyCreator external override {
        (string memory statement, bool isLocked) = abi.decode(ruleData,(string, bool));
        CopyType memory copyType = CopyType(statement, isLocked);
        _copyRule[pubId] = copyType;
    }

    function executeCopyRule(
        address sender, 
        uint256 fromProfileId,
        uint256 toProfileId,
        uint256 pubId,
        bool isLocked,
        string memory statement,
        bytes calldata copyRuleData
    ) external view onlyCopy override {
        require(keccak256(bytes(_copyRule[pubId].statement)) == keccak256(bytes(statement)) && _copyRule[pubId].isLocked == isLocked, TYPE_ERR);
    }

}