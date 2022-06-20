// SPDX-License-Identifier: GPL-3.0
pragma solidity >=0.8.0 <0.9.0;

import "./BaseNFT.sol";
import "./IRNFT.sol";
import "../../admin/IAdminUpgradeable.sol";
import "../../../library/Data.sol";

abstract contract RNFT is BaseNFT, IRNFT {
    
    // The outer layer that supports SBT, NTT
    // the Token in the SBT format is bound to an entity, which is expected to be a smart contract with the function for checking entityID ownership
    
    // Error
    string private constant SIGNER_NOT_ENTITY_OWNER_ERR = "Signer Not Entity Owner";
    string private constant CREATOR_ERR = "Not Creator";
    string private constant OWNER_ERR = "Invalid Owner";

    // entity contract: the address to the entity contract
    address internal immutable adminContract;

    // mapping of entityId => index => tokenId
    mapping(uint256 => mapping(uint256 => uint256)) internal _createdToken;

    // mapping of entityId => total no. of token
    mapping(uint256 => uint256) internal _tokenBalance;

    // mapping of tokenId to entityId
    mapping(uint256 => uint256) internal _tokenCreator;

    modifier tokenCreator(
        uint256 tokenId
    ) {
        require(addressOwnerOfEntity(_tokenCreator[tokenId]) == msg.sender && msg.sender == ownerOf(tokenId), CREATOR_ERR);
        _;
    }

    modifier tokenOwner(
        uint256 tokenId
    ) {
        require(msg.sender == ownerOf(tokenId), OWNER_ERR);
        _;
    }

    modifier entityOwner(
        uint256 entityId
    ) {
        require(addressOwnerOfEntity(entityId) == msg.sender, SIGNER_NOT_ENTITY_OWNER_ERR);   
        _;
    }
    
    constructor (address _adminContract) {
        adminContract = _adminContract;
    }

    // function
    function mintTokenWithEntity(
        uint256 fromEntityId,
        uint256 toEntityId,
        string memory contentUri,
        bool isLocked
    )
    internal entityOwner(fromEntityId)
    returns (uint256)
    {
        // get addres of to Entity
        address toEntityAddress = addressOwnerOfEntity(toEntityId);

        // [1] set the contract as the owner of the nft
        uint256 tokenId = mintToken(toEntityAddress, contentUri, isLocked);

        // [2] create a mapping of Profile owner to tokenId {_createdToken}
        _registerCreator(tokenId, fromEntityId);

        return tokenId;
    }

    function updateTokenUri(
        uint256 tokenId,
        string memory contentUri
    )
    internal
    {
       BaseNFT.updateToken(tokenId, contentUri);
    }

    function burnToken(
        uint256 tokenId
    )
    internal
    {
       BaseNFT._burn(tokenId);
    }

    function _registerCreator(
        uint256 tokenId,
        uint256 entityId
    ) internal {
       // create a mapping of Token creator to entity
        _createdToken[entityId][++_tokenBalance[entityId]] = tokenId;
        // create a mapping of tokenId to entityId
        _tokenCreator[tokenId] = entityId;
    }
    
    // read function

    // return the true owner of the token, if contract owned, it will look up address from the entity contract
    function getEntityContract() public view returns (address) {
        return IAdminUpgradeable(adminContract).getContract(Data.Modules.PROFILE);
    }

    function addressOwnerOfEntity(uint256 entityId) public view override returns (address) {
        return IERC721(getEntityContract()).ownerOf(entityId);
    }

    function getTokenCountofEntity(uint256 entityId) external override view returns (uint256 count) {
        return _tokenBalance[entityId];
    }

    function getTokenofEntityByIndex(uint256 entityId, uint256 index) external override view returns (uint256 tokenId) {
        return _createdToken[entityId][index];
    }

    function getTokenCreator(uint256 tokenId) public override view returns (uint256 count) {
        return _tokenCreator[tokenId];
    }

}
