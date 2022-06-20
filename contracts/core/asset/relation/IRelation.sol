// SPDX-License-Identifier: GPL-3.0
pragma solidity >=0.8.0 <0.9.0;

interface IRelation {
    
    struct NftToken {
        address nftContract;
        uint256 nftToken;
    }

    function createRelation(
        uint256 fromProfileId,
        uint256 toProfileId, // to profile Id
        string memory contentUri, // relation info
        address bindingNftContract,
        uint256 bindingNftTokenId,
        bool isLocked,
        uint256 appId
    ) external returns (uint256 relationId);

    function updateRelation(
        uint256 relationId, // to profile Id
        string memory contentUri, // relation info
        uint256 appId
    ) external returns (uint256);


    function isBinded(uint256 relationId) external view returns (bool);
    function bindedNftTokenOwner(uint256 relationId) external view returns (address);
    function getBindedNft(uint256 relationId) external view returns (NftToken memory);
}
