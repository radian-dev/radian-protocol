// SPDX-License-Identifier: GPL-3.0
pragma solidity >=0.8.0 <0.9.0;

interface ICertificate {

    function issueCertificate(
        uint256 fromProfileId,
        uint256 toProfileId,
        string memory contentUri,
        uint256 appId
    ) external returns (uint256);

    function updateCert(
        uint256 certId,
        string memory contentUri,
        uint256 appId
    )
    external;
     
    function revokeCert(
        uint256 certId,
        uint256 appId
    )
    external;

}