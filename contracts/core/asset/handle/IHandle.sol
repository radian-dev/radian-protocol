// SPDX-License-Identifier: GPL-3.0
pragma solidity >=0.8.0 <0.9.0;

interface IHandle {

    function registerProfileHandle(uint256 profileId, string memory handle, string memory domain) external;

    function getProfileFullHandle(uint256 profileId) external view returns (string memory);

}   