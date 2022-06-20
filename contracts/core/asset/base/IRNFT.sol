// SPDX-License-Identifier: GPL-3.0
pragma solidity >=0.8.0 <0.9.0;

interface IRNFT {

    function addressOwnerOfEntity(uint256 entityId) external view returns (address);

    function getTokenCountofEntity(uint256 entityId) external view returns (uint256 count);
    function getTokenofEntityByIndex(uint256 entityId, uint256 index) external view returns (uint256 postId);

    function getTokenCreator(uint256 tokenId) external view returns (uint256 entityId);
}