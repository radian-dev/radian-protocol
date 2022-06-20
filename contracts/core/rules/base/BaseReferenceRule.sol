// SPDX-License-Identifier: GPL-3.0
pragma solidity >=0.8.0 <0.9.0;

import "../../../core/admin/IAdminUpgradeable.sol";
import "../../../library/Data.sol";
import "../../asset/base/IRNFT.sol";
import "./IReferenceRule.sol";

import "@openzeppelin/contracts/token/ERC721/IERC721.sol";

// Design reference Lens Protocol (Reference Module)

abstract contract BaseReferenceRule is IReferenceRule {

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

}