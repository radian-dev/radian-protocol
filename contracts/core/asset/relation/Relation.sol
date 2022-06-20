// SPDX-License-Identifier: GPL-3.0
pragma solidity >=0.8.0 <0.9.0;

import "../../admin/IAdminUpgradeable.sol";

import "./IRelation.sol";
import "../base/RNFT.sol";

contract Relation is RNFT, IRelation {

    // event
    event CreateRelation(uint256 fromProfileId, uint256 toProfileId, uint256 relationId, string contentUri, bool isLocked, uint256 appId);
    event UpdateRelation(uint256 relationId, string contentUri, uint256 appId);
    
    // error
    string private constant OWNER_ERR = "NOT NFT OWNER";

    mapping(uint256=>NftToken) private _nftBinding;
    // mapping(address=>mapping(uint256=>mapping(uint256=>uint256))) private _BindedRelations;

    constructor(
        string memory tokenName, 
        string memory symbol,
        address _adminContract
    ) ERC721(tokenName, symbol) RNFT(_adminContract) {}
    
    function createRelation(
        uint256 fromProfileId,
        uint256 toProfileId, // to profile Id
        string memory contentUri, // relation info
        address bindingNftContract,
        uint256 bindingNftTokenId,
        bool isLocked,
        uint256 appId
    ) external override returns (uint256) {
        
        uint256 relationId = mintTokenWithEntity(fromProfileId, toProfileId, contentUri, isLocked);

        // bind to particular NFT token
        if ( bindingNftContract != address(0) ) {
            require(_nftTokenOwner(bindingNftContract, bindingNftTokenId) == msg.sender, OWNER_ERR);
            _nftBinding[relationId] = NftToken(bindingNftContract, bindingNftTokenId);
        }

        emit CreateRelation(fromProfileId, toProfileId, relationId, contentUri, isLocked, appId);
        return relationId;
    }

    function updateRelation(
        uint256 relationId, // to profile Id
        string memory contentUri, // relation info
        uint256 appId
    ) external override returns (uint256) {
        
        updateTokenUri(relationId, contentUri);
        emit UpdateRelation(relationId, contentUri, appId);
        
        return relationId;
    }

    // check binding
    function isBinded(
        uint256 relationId
    ) public view override returns (bool) {
        return bindedNftTokenOwner(relationId) == msg.sender;
    }

    function bindedNftTokenOwner(
        uint256 relationId
    ) public view override returns (address) {
        return _nftTokenOwner(_nftBinding[relationId].nftContract, _nftBinding[relationId].nftToken);
    }

    function _nftTokenOwner(
        address bindingNftContract,
        uint256 bindingNftTokenId
    ) internal view returns (address) {
        return IERC721(bindingNftContract).ownerOf(bindingNftTokenId);
    } 

    // transfer relation if the underlying nft owner has change. can be invoked by the msg sender
    function claimRelation(
        uint256 relationId
    ) external {
        ERC721.transferFrom(ERC721.ownerOf(relationId), msg.sender, relationId);
    }

    // TODO check approach valid
    // override the approved or Owner function to include NFT binding as a acceptable condition
    function _isApprovedOrOwner(address spender, uint256 tokenId) internal view override returns (bool) {
        require(_exists(tokenId), "ERC721: operator query for nonexistent token");
        address owner = ERC721.ownerOf(tokenId);
        return (spender == owner || isApprovedForAll(owner, spender) || getApproved(tokenId) == spender) || isBinded(tokenId);
    }

    // READ ONLY FUNCTION
    function getBindedNft(
        uint256 relationId
    ) external view override returns (NftToken memory) {
        return _nftBinding[relationId];
    }


}
