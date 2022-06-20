// SPDX-License-Identifier: GPL-3.0
pragma solidity >=0.8.0 <0.9.0;

import "../../admin/IAdminUpgradeable.sol";

import "../base/RNFT.sol";
import "./ICertificate.sol";

contract Cetificate is RNFT, ICertificate {
    
    event CreateCert(uint256 fromprofileId, uint256 toProfileId, string contentUri, uint256 appId);
    event UpdateCert(uint256 certId, string contentUri, uint256 appId);
    event RevokeCert(uint256 ertId, uint256 appId);

    constructor(
        string memory tokenName, 
        string memory symbol,
        address _adminContract
    ) ERC721(tokenName, symbol) RNFT(_adminContract) {}
    
    // issue certificate
    function issueCertificate(
        uint256 fromProfileId,
        uint256 toProfileId,
        string memory contentUri,
        uint256 appId
    ) external override returns (uint256) {
        uint256 certId = mintTokenWithEntity(fromProfileId, toProfileId, contentUri, false);
        emit CreateCert(fromProfileId, toProfileId, contentUri, appId);
        return certId;
    }
    
    // update certificate
    function updateCert(
        uint256 certId,
        string memory contentUri,
        uint256 appId
    )
    external override tokenCreator(certId)
    {
        updateTokenUri(certId, contentUri); // implicit token creator
        emit UpdateCert(certId, contentUri, appId);
    }

    // revoke cert
    function revokeCert(
        uint256 certId,
        uint256 appId
    )
    external override tokenCreator(certId)
    {
        burnToken(certId);
        emit RevokeCert(certId, appId);
    }

    // Read functions

}