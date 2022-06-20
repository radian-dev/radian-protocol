// SPDX-License-Identifier: GPL-3.0
pragma solidity >=0.8.0 <0.9.0;

interface IBaseNFT {

    function getTokenURIs(uint256 tokenId) external view returns (string memory);
}