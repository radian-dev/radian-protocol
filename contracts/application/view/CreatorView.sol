// SPDX-License-Identifier: GPL-3.0
pragma solidity >=0.8.0 <0.9.0;

import "../../library/Data.sol";
import "../../library/Pagination.sol";
import "../../core/asset/base/IRNFT.sol";
import "../../core/asset/base/IBaseNFT.sol";
import "../../core/asset/creator/ICreator.sol";
import "../../core/admin/IAdminUpgradeable.sol";

contract CreatorNFTView {
    
    struct Post {
        uint256 tokenId;
        string contentUri;
        uint256 creator;
        uint256 noOfComments;
    }

    struct PostPaginationView {
        Post[] results;
        Pagination.PaginationMetaView meta;
    }

    address public adminContractAddress;

    constructor(address _adminContractAddress) {
        adminContractAddress = _adminContractAddress;
    }

    function getAllPostPaginatedList(
        uint256 offset,
        uint256 limit
    ) 
    public
    view
    returns (PostPaginationView memory)
    {
        address postContract = IAdminUpgradeable(adminContractAddress).getContract(Data.Modules.CREATOR);
        uint256 count = ICreator(postContract).getPostCount();
        ( uint256 last, uint256 _limit ) = Pagination._paginationHandler(offset, limit, count);
        
        Post[] memory posts = new Post[](_limit);
        for (uint256 i = offset; i < last; i++) {
            uint256 postId = ICreator(postContract).getPostByIndex(i);
            Post memory post = _serialisePostById(postId);
            posts[i - offset] = post;
        }

        PostPaginationView memory _postPaginationView = PostPaginationView(
            posts,
            Pagination._paginationResponseHandler(offset, limit, count)
        );
        
        return _postPaginationView;
    }

    function getPostPaginatedListByProfile(
        uint256 profileId,
        uint256 offset,
        uint256 limit
    )
    public
    view 
    returns (PostPaginationView memory)
    {
        address postContract = IAdminUpgradeable(adminContractAddress).getContract(Data.Modules.CREATOR);
        uint256 count = IRNFT(postContract).getTokenCountofEntity(profileId);
        ( uint256 last, uint256 _limit ) = Pagination._paginationHandler(offset, limit, count);

        Post[] memory posts = new Post[](_limit);
        for (uint256 i = offset; i < last; i++) {
            
            uint256 postId = IRNFT(postContract).getTokenofEntityByIndex(profileId, i);
            Post memory post = _serialisePostById(postId);
            posts[i - offset] = post;
        }

        PostPaginationView memory _postPaginationView = PostPaginationView(
            posts,
            Pagination._paginationResponseHandler(offset, limit, count)
        );

        return _postPaginationView;
    }

    function getPostById(uint postId)
    public view returns (Post memory)
    {
        Post memory post = _serialisePostById(postId);
        return post;
    }

    function getCommentsByIds(
        uint256[] memory commentIds
    )
    public
    view
    returns (Post[] memory) {
        Post[] memory posts = new Post[](commentIds.length);
        for ( uint256 i = 0; i < commentIds.length; i++) {
            Post memory post = _serialisePostById(commentIds[i]);
            posts[i] = post;
        }
        return posts;
    }
    
    function _serialisePostById(
        uint256 postId
    )
    internal
    view
    returns (Post memory) {
        address postContract = IAdminUpgradeable(adminContractAddress).getContract(Data.Modules.CREATOR);
        string memory contentUri = IBaseNFT(postContract).getTokenURIs(postId);
        Post memory post = Post(postId, contentUri, IRNFT(postContract).getTokenCreator(postId), ICreator(postContract).getPostReferenceCount(postId));
        return post;
    }

}