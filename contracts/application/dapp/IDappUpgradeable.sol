// SPDX-License-Identifier: GPL-3.0
pragma solidity >=0.8.0 <0.9.0;

interface IDappUpgradeable {

    // for read
    struct ContentUri {
        string contentUri;
        bool permission;
    }

    struct PermSig {
        bool permission;
        uint256 deadline;
        uint8 v;
        bytes32 r;
        bytes32 s;
    }

    // using a signature of the tag provider on the permission, cid and deadline to set permission
    function setPermissionWithSig(
        bool permission,
        string memory contentUri,
        uint256 deadline,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) external;

    // get the receiver address
    function getReceiverAddress(uint256 appId) external returns (address payable);

    // get fee
    function getFixedFee(uint256 appId) external view returns (uint256);
    function getTipFee(uint256 appId) external view returns (uint16);
    function getTradeFee(uint256 appId) external view returns (uint16);

    function getProviderCount() external view returns (uint256);
    function getProviderAddressByIndex(uint256 index) external view returns (address);
    
    function providerExists(uint256 appId) external view returns (bool);
    function contentUriExist(string memory contentUri) external view returns(bool);

}