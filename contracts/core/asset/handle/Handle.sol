// SPDX-License-Identifier: GPL-3.0
pragma solidity >=0.8.0 <0.9.0;

import "@openzeppelin/contracts/token/ERC721/IERC721.sol";
import "@openzeppelin/contracts/utils/Base64.sol";

import "./IHandle.sol";
import "../../admin/IAdminUpgradeable.sol";
import "../../../library/Data.sol";

contract Handle is IHandle {

    string private constant CONTRACT_ERR = "NOT PERMITTED CONTRACT";
    string private constant DOMAIN_ERR = "NOT PERMITTED DOMAIN";
    string private constant PROFILE_HANDLE_ERR = "HANDLE TAKEN BY PROFILE";
    string private constant DAO_HANDLE_ERR = "HANDLE TAKEN BY DAO";
    string private constant CHARATER_INVAID_ERR = "CHARACTER INVALID";
    string private constant HANDLE_LENGTH_ERR = "HANDLE LENGTH INVALID";
    uint8 private constant MIN_HANDLE_LENGTH = 2;
    uint8 private constant MAX_HANDLE_LENGTH = 12;

    address immutable private adminContract;

    mapping(bytes32 => string) private _stringOfHandleHash;

    mapping(bytes32 => uint256) private _profileOfHandleHash;
    mapping(uint256 => bytes32) private _handleHashOfProfile;
    
    mapping(bytes32 => uint256) private _daoOfHandleHash;
    mapping(uint256 => bytes32) private _handleHashOfDao;

    constructor(address _adminContract){
        adminContract = _adminContract;
    }

    modifier onlyProfile {
        require(IAdminUpgradeable(adminContract).getContract(Data.Modules.PROFILE) == msg.sender, CONTRACT_ERR);
        _;
    }    


    function registerProfileHandle(uint256 profileId, string memory handle, string memory domain) external override onlyProfile {
        (string memory handleString, bytes32 handleHash) = _getValidHandleHash(handle, domain);

        // register to profile
        _profileOfHandleHash[handleHash] = profileId;
        _handleHashOfProfile[profileId] = handleHash;
        _stringOfHandleHash[handleHash] = handleString;
    }


    // Reference from Lens Protocol
    // source https://github.com/aave/lens-protocol
    function _getValidHandleHash(string memory handle, string memory domain) internal view returns (string memory, bytes32) {
        
        require(IAdminUpgradeable(adminContract).isDomainWhitelisted( keccak256(bytes(domain)) ), DOMAIN_ERR); // valid domain
        
        _validateHandle(handle);
        handle = string(abi.encodePacked(handle, ".", domain));
        bytes32 handleHash = keccak256(bytes(handle));

        require(_profileOfHandleHash[handleHash] == 0, PROFILE_HANDLE_ERR);
        require(_daoOfHandleHash[handleHash] == 0, DAO_HANDLE_ERR);

        return (handle, handleHash);
    }

    // Reference from Lens Protocol
    // source https://github.com/aave/lens-protocol
    function _validateHandle(string memory handle) private pure {
        bytes memory byteHandle = bytes(handle);
        require(byteHandle.length >= MIN_HANDLE_LENGTH && byteHandle.length <= MAX_HANDLE_LENGTH, HANDLE_LENGTH_ERR);

        uint256 byteHandleLength = byteHandle.length;
        for (uint256 i = 0; i < byteHandleLength; ) {
            bool characterInvalid = (
                (byteHandle[i] < "0" ||
                    byteHandle[i] > "z" ||
                    (byteHandle[i] > "9" && byteHandle[i] < "a")) &&
                byteHandle[i] != "." &&
                byteHandle[i] != "-" &&
                byteHandle[i] != "_"
            );
            require(!characterInvalid, CHARATER_INVAID_ERR);
            unchecked {
                ++i;
            }
        }
    }

    // READ FUNCTION
    function getProfileFullHandle(uint256 profileId) external view override returns (string memory) {
        return _stringOfHandleHash[_handleHashOfProfile[profileId]];
    }


}