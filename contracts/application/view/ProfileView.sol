// SPDX-License-Identifier: GPL-3.0
pragma solidity >=0.8.0 <0.9.0;

import "@openzeppelin/contracts/token/ERC721/extensions/IERC721Enumerable.sol";
import "@openzeppelin/contracts/token/ERC721/IERC721.sol";

import "../../library/Data.sol";
import "../../library/Pagination.sol";
import "../../core/admin/IAdminUpgradeable.sol";
import "../../core/asset/base/IBaseNFT.sol";

contract ProfileView   {
    
    struct Profile {
        uint256 tokenId;
        string contentUri;
    }

    struct ProfilePaginationView {
        Profile[] results;
        Pagination.PaginationMetaView meta;
    }
    
    address public adminContractAddress;

    constructor(address _adminContractAddress) {
        adminContractAddress = _adminContractAddress;
    }

    function getProfileList(
        address owner
    )
    public view
    returns (uint256[] memory)
    {
        address profileContract = IAdminUpgradeable(adminContractAddress).getContract(Data.Modules.PROFILE);
        uint256 balance = IERC721(profileContract).balanceOf(owner);
        uint256[] memory tokens = new uint256[](balance); 
        for ( uint256 i = 0 ; i < balance ; i++ ) {
            uint256 _token = IERC721Enumerable(profileContract).tokenOfOwnerByIndex(owner, i);
            tokens[i] = _token;
        }
        return tokens;
    }

    function getProfilePaginatedList(
        address owner,
        uint256 offset,
        uint256 limit
    ) 
    public
    view
    returns (ProfilePaginationView memory)
    {
        address profileContract = IAdminUpgradeable(adminContractAddress).getContract(Data.Modules.PROFILE);
        uint256 count = IERC721(profileContract).balanceOf(owner);
        ( uint256 last, uint256 _limit ) = Pagination._paginationHandler(offset, limit, count);
        
        Profile[] memory profiles = new Profile[](_limit);

        for (uint256 i = offset; i < last; i++) {
            uint256 tokenId = IERC721Enumerable(profileContract).tokenOfOwnerByIndex(owner, i);
            Profile memory profile = _serialiseProfileById(tokenId);
            profiles[i - offset] = profile;
        }

        ProfilePaginationView memory _profilePaginationView = ProfilePaginationView(
            profiles,
            Pagination._paginationResponseHandler(offset, limit, count)
        );
        
        return _profilePaginationView;
    }
    
    function _serialiseProfileById(
        uint256 tokenId
    )
    internal
    view
    returns (Profile memory)
    {
        address profileContract = IAdminUpgradeable(adminContractAddress).getContract(Data.Modules.PROFILE);
        string memory tokenUri = IBaseNFT(profileContract).getTokenURIs(tokenId);
        Profile memory profile = Profile(tokenId, tokenUri);
        return profile;
    }

}