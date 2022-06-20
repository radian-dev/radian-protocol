// SPDX-License-Identifier: GPL-3.0
pragma solidity >=0.8.0 <0.9.0;

import "@openzeppelin/contracts/token/ERC721/IERC721.sol";
import "@openzeppelin/contracts-upgradeable/proxy/utils/Initializable.sol";
import "@openzeppelin/contracts-upgradeable/utils/math/SafeMathUpgradeable.sol";
import "hardhat/console.sol";

import "../../core/admin/IAdminUpgradeable.sol";
import "../../application/dapp/IDappUpgradeable.sol";

import "../../core/asset/creator/ICreator.sol";
import "../../core/asset/base/IRNFT.sol";
import "../../library/Data.sol";
import "./ITip.sol";


contract TipUpgradeable is Initializable, ITip {
    // Contract for fee and royalty calculation

    using SafeMathUpgradeable for uint256;

    address private adminContract;
    
    event TipPublication(uint256 pubId, uint256 fromProfileId, uint256 toProfileId, uint256 infraFee, uint256 appFee, uint256 ownerFee, uint256 appId);
    event TipProfile(uint256 toProfileId, uint256 fromProfileId, uint256 netValue, uint256 infraFee, uint256 appFee, uint256 appId);

    string private constant FEE_ERR = "Fee Insufficient or Incorrect";
    string private constant OWNER_ERR = "Invalid Owner";
    string private constant VALUE_ERR = "Insuffiicent Tip";
    
    function initialize(
        address _adminContract
    ) public initializer{
        adminContract = _adminContract;
    }

    function _getPubOwner(
        uint256 toPostId
    ) internal view returns (address) {
        uint256 toProfileId = _ownerOfPub(toPostId);
        return _ownerOfProfile(toProfileId);
    }


    function tipPublication(
        uint256 fromProfileId,
        uint256 pubId,
        uint256 appId
    ) external payable override {
        
        if ( fromProfileId > 0) {
            require(_ownerOfProfile(fromProfileId) == msg.sender, OWNER_ERR);
        }
        
        address appContract = IAdminUpgradeable(adminContract).getContract(Data.Modules.APP);
        uint256 infraFee =  msg.value.mul(IAdminUpgradeable(adminContract).getTipFee()).div(10000);
        uint256 appFee = msg.value.mul(IDappUpgradeable(appContract).getTipFee(appId)).div(10000);  
        uint256 ownerFee = msg.value - infraFee - appFee;
        require(ownerFee > 0, VALUE_ERR);

        // transfer the value to the admin and app address (Wallet)
        IAdminUpgradeable(adminContract).getReceiverAddress().transfer(infraFee);
        IDappUpgradeable(appContract).getReceiverAddress(appId).transfer(appFee);
        uint256 toProfileId = _ownerOfPub(pubId);
        address pubOwner =  _ownerOfProfile(toProfileId);
        payable(pubOwner).transfer(ownerFee);

        // emit event
        emit TipPublication(pubId, fromProfileId, toProfileId, infraFee, appFee, ownerFee, appId);
    }

    function tipProfile(
        uint256 toProfileId,
        uint256 fromProfileId,
        uint256 appId
    ) external payable override {
        // check profile
        if (fromProfileId > 0) {
            require(_ownerOfProfile(fromProfileId) == msg.sender, OWNER_ERR);
        }

        address appContract = IAdminUpgradeable(adminContract).getContract(Data.Modules.APP);
        uint256 infraFee =  msg.value.mul(IAdminUpgradeable(adminContract).getTipFee()).div(10000);
        uint256 appFee = msg.value.mul(IDappUpgradeable(appContract).getTipFee(appId)).div(10000);
        uint256 totalFee =  infraFee + appFee;
        uint256 netValue = msg.value - totalFee;
        require(msg.value >= totalFee, FEE_ERR);
        // transfer the value to the admin and app address (Wallet)
        IAdminUpgradeable(adminContract).getReceiverAddress().transfer(infraFee);
        IDappUpgradeable(appContract).getReceiverAddress(appId).transfer(appFee);
        // transfer the remaining value to the address that holds the profile
        address payable profileOwner = payable(_ownerOfProfile(toProfileId));
        profileOwner.transfer(netValue);

        emit TipProfile(toProfileId, fromProfileId, netValue, infraFee, appFee, appId);
    }

    // read
    function _ownerOfPub(uint256 pubId) internal view returns (uint256 profileId) {
        address creatorContract = IAdminUpgradeable(adminContract).getContract(Data.Modules.CREATOR);
        return IRNFT(creatorContract).getTokenCreator(pubId);
    }
    
    function _ownerOfProfile(uint256 tokenId) internal view returns(address) {
        address profileContract = IAdminUpgradeable(adminContract).getContract(Data.Modules.PROFILE);
        return IERC721(profileContract).ownerOf(tokenId);
    }

}