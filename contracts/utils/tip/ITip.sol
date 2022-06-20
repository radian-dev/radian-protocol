// SPDX-License-Identifier: GPL-3.0
pragma solidity >=0.8.0 <0.9.0;

interface ITip {

    function tipPublication(uint256 fromProfileId, uint256 pubId, uint256 appId) external payable;

    function tipProfile(uint256 toProfileId, uint256 fromProfileId, uint256 appId) external payable;

}