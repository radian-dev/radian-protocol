// SPDX-License-Identifier: GPL-3.0
pragma solidity >=0.8.0 <0.9.0;

import "../core/admin/IAdminUpgradeable.sol";
import "../core/asset/creator/ICreator.sol";
import "./dapp/IDappUpgradeable.sol";
import "../library/Data.sol";

contract Interaction {
    
    /*
     * The Interaction contract contains function that invokes multiple smaller functions from the core modules.
     * The purpose of using the interaction contract is to simple the core login to make them more modularized.
     */

    address private immutable adminContract;

    constructor(
        address _adminContract
    ) {
        adminContract = _adminContract;
    }
    
    // Creator Contract Functions

    // TODO

}