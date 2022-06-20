// SPDX-License-Identifier: GPL-3.0
pragma solidity >=0.8.0 <0.9.0;

import "../base/RNFT.sol";
import "../base/IRNFT.sol";
import "../base/IBaseNFT.sol";

import "../../admin/IAdminUpgradeable.sol";
import "../../rules/base/ICopyRule.sol";
import "../creator/ICreator.sol";


contract Copy is RNFT {

    // Events
    event CreateCopy(uint256 fromProfileId, uint256 toProfileId, uint256 pubId,  bool isLocked, string statement, bytes copyRuleData, uint256 appId);
    event BurnCopy(uint256 copyId, uint256 appId);

    // error 
    string private constant NO_RULE_ERR = "NO RULE";
    string private constant OWNER_ERR = "NOT OWNER";
    
    // copyId => pubId
    mapping(uint256 => uint256) private _copyOf;
    // pubId => index => copyId
    mapping(uint256 => mapping( uint256 => uint256 )) private _copys;
    // pubId => copy_count 
    mapping(uint256 => uint256) private _copyCount;

    // copyright license copyId => licenseType
    mapping(uint256=>string) private _statement;

    constructor(
        string memory tokenName, 
        string memory symbol,
        address _adminContract
    ) ERC721(tokenName, symbol) RNFT(_adminContract) {}

    // original function

    function createCopy(
        uint256 fromProfileId,
        uint256 toProfileId,
        uint256 pubId,
        bool isLocked,
        string memory statement,
        bytes calldata copyRuleData,
        uint256 appId
    )
    external returns (uint256)
    {
        // check rules
        address creatorContract = IAdminUpgradeable(adminContract).getContract(Data.Modules.CREATOR);
        address copyRule = ICreator(creatorContract).getCopyRule(pubId);
        require(copyRule != address(0), NO_RULE_ERR);
        
        ICopyRule(copyRule).executeCopyRule(msg.sender, fromProfileId, toProfileId, pubId, isLocked, statement, copyRuleData);

        // get contentUri
        string memory contentUri = IBaseNFT(creatorContract).getTokenURIs(pubId);
        
        // mint token with the params
        uint256 copyId = mintTokenWithEntity(fromProfileId, toProfileId, contentUri, isLocked);

        // register copy Statement
        if (keccak256(bytes(statement)).length > 0) {
            _statement[copyId] = statement;
        }
        
        // emit event to notify graph / server on transaction refId = 0
        emit CreateCopy(fromProfileId, toProfileId, pubId, isLocked, statement, copyRuleData, appId);

        return copyId;
    }

    // destroy a copy token
    function burnCopy(
        uint256 copyId,
        uint256 appId
    ) external tokenOwner(copyId) {
        burnToken(copyId);
        emit BurnCopy(copyId, appId);
    }

    function _registerCopy(
        uint256 copyId,
        uint256 pubId
    ) internal {
        _copyOf[copyId] = pubId;
        _copyCount[pubId] += 1;
        _copys[pubId][_copyCount[pubId]] = copyId;
    }

    // READ functoins

}
