// SPDX-License-Identifier: GPL-3.0
pragma solidity >=0.8.0 <0.9.0;

import "../../admin/IAdminUpgradeable.sol";

import "../base/RNFT.sol";
import "../../rules/base/ICopyRule.sol";
import "../../rules/base/IReferenceRule.sol";
import "./ICreator.sol";
import "../../../library/Data.sol";

contract Creator is RNFT, ICreator {
    
    // Events
    event CreateContent(uint256 profileId, Data.ContentCreationData data, uint256 appId);
    event UpdateContent(uint256 pubId, string contentUri, uint256 appId);

    event SetCopyRule(uint256 pubId, address copyRule, bytes copyRuleInitData, uint256 appId);
    event RemoveCopyRule(uint256 pubId, address copyRule, uint256 appId);

    event SetReferenceRule(uint256 pubId, address referenceRule, bytes referenceRuleInitData, uint256 appId);
    event RemoveReferenceRule(uint256 pubId, address referenceRule, uint256 appId);

    // Error
    string private constant CREATOR_ERR = "Not Creator";

    // pub list (excludes the comments)
    uint256[] private pubIds;

    // mapping child pubId => parent pubId
    mapping(uint256 => uint256) private _pubChildRef;

    // mapping parent pubId => no. of referenced pub
    mapping(uint256 => uint256) private _pubRefCount;

    // mapping parent pubId => reference index => child pubId
    mapping(uint256 => mapping(uint256 => uint256)) private _pubParentRef;

    // mapping parent pubId => path to the node pub
    mapping(uint256 => uint256) private _pubRefDepth;

    // copyright mapping
    mapping(uint256 => address) private _copyRule;
    mapping(uint256 => address) private _referenceRule;

    constructor(
        string memory tokenName, 
        string memory symbol,
        address _adminContract
    ) ERC721(tokenName, symbol) RNFT(_adminContract) {}

    // reference and copyright design referece lens reference and collect modules
    function createContent(
        uint256 profileId,
        // string memory contentUri,
        // bytes calldata referenceRuleData,
        // address referenceRule,
        // bytes calldata referenceRuleInitData,
        // address copyRule,
        // bytes calldata copyRuleInitData,
        // uint256 refId,
        // bool isShare,
        Data.ContentCreationData memory data,
        uint256 appId
    ) external override returns (uint256) {
        // [1] mint token (from entity and to entity are the same)
        uint256 pubId = mintTokenWithEntity(profileId, profileId, data.contentUri, false);
        
        // [2] Set pub reference if its comment else updaate pubList
        if ( data.refId > 0 ) {
            // check reference rules
            if (_referenceRule[data.refId] != address(0)) {
                IReferenceRule(_referenceRule[data.refId]).executeReferenceRule(msg.sender, profileId, data.refId, data.isShare, data.referenceRuleData);
            }
            _setPubReference(pubId, data.refId);
            _pubRefDepth[pubId] = _pubRefDepth[pubId] + 1;
        }

        if ( data.refId == 0 || data.isShare ) {
            pubIds.push(pubId);
        }

        // [3] set copy right rules
        if (data.copyRule != address(0)) {
            _copyRule[pubId] = data.copyRule;
            ICopyRule(data.copyRule).setupRule(pubId, data.copyRuleInitData);
        }

        // [4] set referece rules
        if (data.referenceRule != address(0)) {
            _referenceRule[pubId] = data.referenceRule;
            IReferenceRule(data.referenceRule).setupRule(pubId, data.referenceRuleInitData);
        }

        // emit event to notify graph / server on transaction refId = 0
        emit CreateContent(profileId, data, appId);

        return pubId;
    }

    /**
     * @dev method to update contentUri of profiles
     * See {BaseNFTContract.updateTokenWithTags}
     */
    function updateContent(
        uint256 pubId,
        string memory contentUri,
        uint256 appId
    )
    external override tokenOwner(pubId)
    {
        updateTokenUri(pubId, contentUri);
        emit UpdateContent(pubId, contentUri, appId);
    }

    function setCopyRule(
        uint256 pubId,
        address copyRule, 
        bytes calldata copyRuleInitData,
        uint256 appId
    ) external tokenOwner(pubId) override {
        _copyRule[pubId] = copyRule;
        ICopyRule(copyRule).setupRule(pubId, copyRuleInitData);  
        emit SetCopyRule(pubId, copyRule, copyRuleInitData, appId);
    }
    
    function removeCopyRule(
        uint256 pubId,
        uint256 appId
    ) external tokenOwner(pubId) override {
        address copyRule = _copyRule[pubId];
        _copyRule[pubId] = address(0);
        emit RemoveCopyRule(pubId, copyRule, appId);
    }

    function setReferenceRule(
        uint256 pubId,
        address referenceRule,
        bytes calldata referenceRuleInitData,
        uint256 appId
    ) external tokenOwner(pubId) override {
        _referenceRule[pubId] = referenceRule;
        IReferenceRule(referenceRule).setupRule(pubId, referenceRuleInitData);
        emit SetReferenceRule(pubId, referenceRule, referenceRuleInitData, appId);
    }
    
    function removeReferenceRule(
        uint256 pubId,
        uint256 appId
    ) external tokenOwner(pubId) override {
        address referenceRule = _referenceRule[pubId];
        _referenceRule[pubId] = address(0);
        emit RemoveReferenceRule(pubId, referenceRule, appId);
    }

    /**
     * internal method to create pub reference (comment etc.)
     * 
     */
    function _setPubReference(
        uint256 childId,
        uint256 parentId
    ) 
    internal 
    {
        uint256 _refCount = _pubRefCount[parentId];
        _refCount++;
        _pubRefCount[parentId] = _refCount;
        _pubParentRef[parentId][_refCount] = childId;
        _pubChildRef[childId] = parentId;
    }
    

    // internal read function

    function getPostCount() external override view returns (uint256 count) {
        return pubIds.length;
    }

    function getPostByIndex(uint256 index) external override view returns (uint256 pubId) {
        return pubIds[index];
    }
    
    function getPostReferenceCount(uint256 pubId) external override view returns (uint256 count) {
        return _pubRefCount[pubId];
    }

    function getCopyRule(uint256 pubId) external override view returns (address rule ) {
        return _copyRule[pubId];
    }

}
