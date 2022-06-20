// SPDX-License-Identifier: GPL-3.0
pragma solidity >=0.8.0 <0.9.0;

import "@openzeppelin/contracts-upgradeable/proxy/utils/Initializable.sol";

import "./IDappUpgradeable.sol";
import "../../library/Data.sol";

contract DappUpgradeable is Initializable, IDappUpgradeable {
    
    // events
    event RegisterAppId(address indexed appProvider, uint256 appId);
    event SetAppFee(uint256 fixedFee, uint16 tipFee, uint16 tradeFee);

    event SetPermission(string contentUri, bool permission, uint256 appId);
    
    // Error string
    string private constant PROVIDER_EXIST_ERR = "Provider Exists";
    string private constant PROVIDER_ERR = "No Provider";
    string private constant TIME_ERR = "Expired deadline";
    string private constant CID_ERR = "No contentUri";
    string private constant VALUE_ERR = "Max 30% Fee, at value=3000";
    

    mapping(uint256 => address) public providers;
    mapping(address => uint256) public providerIndex;
    uint256 public providerCount;

    // map for contentU
    string[] public contentUriArray;
    mapping(string=>uint256) public contentUriMapping;

    // fee receiver mapping
    mapping(uint256=>address) public receiverAddressMapping;
    
    // app fee mapping
    mapping(uint256=>uint256) public appFixedFee;
    mapping(uint256=>uint16) public appTipFee;
    mapping(uint256=>uint16) public appTradeFee;

    // data search
    // appId => contentUri id => permission
    mapping(uint256=>mapping(uint256=>bool)) public contentUriPermissionMapping;

    function tryRecover(
        bytes32 hash,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) internal pure returns (address) {
        // EIP-2 still allows signature malleability for ecrecover(). Remove this possibility and make the signature
        // unique. Appendix F in the Ethereum Yellow paper (https://ethereum.github.io/yellowpaper/paper.pdf), defines
        // the valid range for s in (301): 0 < s < secp256k1n ÷ 2 + 1, and for v in (302): v ∈ {27, 28}. Most
        // signatures from current libraries generate a unique signature with an s-value in the lower half order.
        //
        // If your library generates malleable signatures, such as s-values in the upper range, calculate a new s-value
        // with 0xFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFEBAAEDCE6AF48A03BBFD25E8CD0364141 - s1 and flip v from 27 to 28 or
        // vice versa. If your library also generates signatures with 0/1 for v instead 27/28, add 27 to v to accept
        // these malleable signatures as well.
        if (uint256(s) > 0x7FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF5D576E7357A4501DDFE92F46681B20A0) {
            return (address(0));
        }
        if (v != 27 && v != 28) {
            return (address(0));
        }

        // If the signature is valid (and not malleable), return the signer address
        address signer = ecrecover(hash, v, r, s);
        if (signer == address(0)) {
            return (address(0));
        }

        return (signer);
    }

    function initialize() public initializer {}

    // set a provider of tags, anyone can be a provider of tags
    function registerAppId() public {
        // check if provider is already registered
        require( providerIndex[msg.sender] == 0,  PROVIDER_EXIST_ERR);
        // add provider into the provider list
        providerCount += 1;
        providers[providerCount] = msg.sender;
        providerIndex[msg.sender] = providerCount;

        // set receiver address
        setReceiverAddress(msg.sender, providerCount);
        
        // emit
        emit RegisterAppId(msg.sender, providerCount);
    }

    // receiver address is the address that recevie the fees on using the RADIAN infrastructure
    function setReceiverAddress(address receiver, uint256 appId) public {
        receiverAddressMapping[appId] = receiver;
    }

    // update Fee
    function setAppFee(
        uint256 fixedFee,
        uint16 tipFee,
        uint16 tradeFee
    ) public {
        uint256 appId = providerIndex[msg.sender];
        require( appId > 0,  PROVIDER_ERR);
        require(tipFee <= 3000, VALUE_ERR);
        require(tradeFee <= 3000, VALUE_ERR);

        appFixedFee[appId] = fixedFee;
        appTipFee[appId] = tipFee;
        appTradeFee[appId] = tradeFee;

        // emit event
        emit SetAppFee(fixedFee, tipFee, tradeFee);
    }

    // get Receiver 
    function getReceiverAddress(uint256 appId) external override view returns (address payable) {
        return payable(receiverAddressMapping[appId]);
    }

    function getFixedFee(uint256 appId) external override view returns (uint256) {
        return appFixedFee[appId];
    }

    function getTipFee(uint256 appId) external override view returns (uint16) {
        return appTipFee[appId];
    }

    function getTradeFee(uint256 appId) external override view returns (uint16) {
        return appTradeFee[appId];
    }

    
    // set app given that the tags are updated by the provider
    function _setPermission(bool permission, string memory contentUri, address provider) private {
        uint256 contentUriIndex = getContentUriIndex(contentUri);

        // check if msg sender is in the provider list
        uint256 appId = providerIndex[provider];
        require( appId > 0, PROVIDER_ERR);

        // set permission
        contentUriPermissionMapping[appId][contentUriIndex] = permission;
        
        emit SetPermission(contentUri, permission, appId);
    }

    function setPermissionWithoutSig(
        bool permission,
        string memory contentUri) public {
            _setPermission(permission, contentUri, msg.sender);
        }
    
    // set app given that the tags are updated by the user
    function setPermissionWithSig(
        bool permission,
        string memory contentUri,
        uint256 deadline,
        uint8 v,
        bytes32 r,
        bytes32 s) public override {
        // prove that the tags are signed by the valid provider
        // reject signature past deadline
        require(deadline > block.timestamp, TIME_ERR);
        // convert app list into bytes
        bytes32 permissionString = keccak256(abi.encode("SET", contentUri, permission, deadline));
        address recoveredProvider = tryRecover(permissionString, v, r, s);
        
        // settags
        _setPermission(permission, contentUri, recoveredProvider);
    }

    function contentUriExist(
        string memory contentUri
    )  public view override returns (bool) {
        uint256 id = contentUriMapping[contentUri];
        bool isExist = id == 0;
        return isExist;
    }
    
    // getContentUri
    function getContentUriIndex(string memory contentUri) private returns (uint256) {
        uint256 contentUriIndex;
        // if contentUri not exists add contentUri to list
        if (contentUriMapping[contentUri] == 0) {
            contentUriArray.push(contentUri);
            contentUriIndex = contentUriArray.length;
            contentUriMapping[contentUri] = contentUriIndex;
        } else {
            contentUriIndex = contentUriMapping[contentUri];
        }
        return contentUriIndex;
    }

    // get the contentUri list with given tags and a list of given proviers
    function getcontentUri(uint256 appId, uint256 skip, uint256 limit) public view returns (ContentUri[] memory) {
        require( appId > 0 , PROVIDER_ERR);

        ContentUri[] memory selectedcontentUris = new ContentUri[](limit);
        for ( uint256 i = 0 ; i < limit ; i++ ) {
            bool permission = contentUriPermissionMapping[appId][skip+i+1];
            ContentUri memory contentUri = ContentUri(contentUriArray[skip+i], permission);
            selectedcontentUris[i] = contentUri; // get back the string
        }
        return selectedcontentUris;
    }

    function getPermission(string memory contentUri, uint256 appId) public view returns (bool) {
        uint256 contentUriIndex = contentUriMapping[contentUri];
        require(contentUriIndex != 0, CID_ERR);
        return contentUriPermissionMapping[appId][contentUriIndex];
    }

    function getProviderCount() external override view returns (uint256) {
        return providerCount;
    }

    function getProviderAddressByIndex(uint256 index) external override view returns (address) {
        return providers[index];
    }

    function providerExists(uint256 appId) external override view returns (bool) {
        return providers[appId] != address(0);
    }
}