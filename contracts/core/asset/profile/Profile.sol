// SPDX-License-Identifier: GPL-3.0
pragma solidity >=0.8.0 <0.9.0;

import "@openzeppelin/contracts/token/ERC721/IERC721.sol";
import "@openzeppelin/contracts/utils/Base64.sol";
import "@openzeppelin/contracts/utils/Strings.sol";

import "../base/BaseNFT.sol";
import "../relation/IRelation.sol";
import "../handle/IHandle.sol";

import "../../admin/IAdminUpgradeable.sol";
import "../../../library/Data.sol";


contract Profile is BaseNFT {
    
    event CreateProfile(uint256 profileId, string contentUri, string profileHandle, string domain, uint256 appID);
    event UpdateProfile(uint256 profileId, string contentUri, uint256 appID);

    string private constant OWNER_ERR = "CANNOT VERIFY OWNER";
    string private constant AUTH_ERR = "ONLY ADMIN OF GROUP REQUIRED";
    string private constant HANDLE_ERR = "HANDLE TAKEN";
    string private constant CHARATER_INVAID_ERR = "CHARACTER INVALID";
    string private constant HANDLE_LENGTH_ERR = "HANDLE LENGTH INVALID";
    string private constant RADIAN_DEFAULT_IMAGE = "";


    uint8 private constant MIN_HANDLE_LENGTH = 2;
    uint8 private constant MAX_HANDLE_LENGTH = 12;

    address private immutable adminContract;

    mapping(bytes32 => uint256) private _profileOfHandleHash;
    mapping(uint256 => bytes32) private _handleHashOfProfile;
    mapping(bytes32 => string) private _stringOfHandleHash;

    constructor(
        string memory tokenName,
        string memory symbol,
        address _adminContract
        ) ERC721(tokenName, symbol) {
        adminContract = _adminContract;
    }

    modifier onlyOwner(uint256 profileId) {
        require( ownerOf(profileId) == msg.sender, OWNER_ERR);
        _;
    }

    /**
     * method to create a profile completed inheriting from identity
    */
    function createProfile(
        string memory profileHandle,
        string memory domain,
        string memory contentUri,
        bool isLocked,
        uint256 appID
    )
    external
    returns (uint256)
    {
        
        uint256 profileId = BaseNFT.mintToken(msg.sender, contentUri, isLocked);

        IHandle(IAdminUpgradeable(adminContract).getContract(Data.Modules.HANDLE)).registerProfileHandle(profileId, profileHandle, domain);
        // _registerHandle(profileId, profileHandle);

        emit CreateProfile(profileId, contentUri, profileHandle, domain, appID);
        return profileId;
    }

    function updateProfile(
        uint256 profileId,
        string memory contentUri,
        uint256 appID
    ) 
    external onlyOwner(profileId) 
    {
        BaseNFT.updateToken(profileId, contentUri);
        emit UpdateProfile(profileId, contentUri, appID);
    }

    // READ only
    // Returns an image with handle name
    // references Lens Protocol
    // source https://github.com/aave/lens-protocol
    function tokenURI(uint256 tokenId) public view override returns (string memory) {
        require(_exists(tokenId), "ERC721URIStorage: URI query for nonexistent token");

        // string memory _tokenURI = _tokenURIs[tokenId];
        return _getProfileTokenURI(
            tokenId,
            0,
            ownerOf(tokenId),
            getProfileHandle(tokenId),
            RADIAN_DEFAULT_IMAGE
        );
    }

    // references Lens Protocol
    // source https://github.com/aave/lens-protocol
    function _getProfileTokenURI(
        uint256 profileId,
        uint256 followers,
        address owner,
        string memory handle,
        string memory imageURI
    ) internal pure returns (string memory) {
        string memory handleWithAtSymbol = string(abi.encodePacked("@", handle));
        return
            string(
                abi.encodePacked(
                    "data:application/json;base64,",
                    Base64.encode(
                        abi.encodePacked(
                            "{'name':'",
                            handleWithAtSymbol,
                            "','description':'",
                            handleWithAtSymbol,
                            " - RADIAN profile','image':'data:image/svg+xml;base64,",
                            _getSVGImageBase64Encoded(handleWithAtSymbol, imageURI),
                            "','attributes':[{'trait_type':'id','value':'#",
                            Strings.toString(profileId),
                            "'},{'trait_type':'followers','value':'",
                            Strings.toString(followers),
                            "'},{'trait_type':'owner','value':'",
                            Strings.toHexString(uint160(owner)),
                            "'},{'trait_type':'handle','value':'",
                            handleWithAtSymbol,
                            "'}]}"
                        )
                    )
                )
            );
    }

    /**
     * @notice Generates the token image.
     *
     * @dev If the image URI was set and meets URI format conditions, it will be embedded in the token image.
     * Otherwise, a default picture will be used. Handle font size is a function of handle length.
     *
     * @param handleWithAtSymbol The profile's handle beginning with "@" symbol.
     * @param imageURI The profile's picture URI. An empty string if has not been set.
     *
     * @return string The profile token image as a base64-encoded SVG.
     */
    // references Lens Protocol
    // source https://github.com/aave/lens-protocol
    function _getSVGImageBase64Encoded(string memory handleWithAtSymbol, string memory imageURI)
        internal
        pure
        returns (string memory)
    {
        return        
            Base64.encode(
                abi.encodePacked(
                    "<svg width='455' height='450' viewBox='0 0 455 450' fill='none' xmlns='http://www.w3.org/2000/svg'><image href='",
                    imageURI,
                    "'/><text fill='white' xmlSpace='preserve' style={{whiteSpace: 'pre'}} font-family='Raleway' font-size='30' font-weight='bold' letter-spacing='0em'><tspan x='106.935' y='241.527'>", 
                    handleWithAtSymbol,
                    "</tspan></text></svg>"
                )
            );
    }

    function getProfileHandle(
        uint256 profileId
    ) public view returns (string memory){
        return IHandle(IAdminUpgradeable(adminContract).getContract(Data.Modules.HANDLE)).getProfileFullHandle(profileId);
    }

}