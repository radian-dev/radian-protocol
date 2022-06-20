// SPDX-License-Identifier: GPL-3.0
pragma solidity >=0.8.0 <0.9.0;

import "../../../core/admin/IAdminUpgradeable.sol";
import "../../../core/asset/base/IRNFT.sol";
import "../../../library/Data.sol";
import "./ICopyRule.sol";

// Design reference Lens Protocol (Collect Module)

abstract contract BaseCopyRule is ICopyRule {

    address internal immutable adminContract;

    string private constant CONTRACT_ERR = "Origin Not from Correct Contract";

    constructor(
        address _adminContract
    ) {
        adminContract = _adminContract;
    }

    modifier onlyCreator() {
        require(msg.sender == IAdminUpgradeable(adminContract).getContract(Data.Modules.CREATOR), CONTRACT_ERR);
        _;
    }

    modifier onlyCopy() {
        require(msg.sender == IAdminUpgradeable(adminContract).getContract(Data.Modules.COPY), CONTRACT_ERR);
        _;
    }

}