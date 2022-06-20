// SPDX-License-Identifier: GPL-3.0
pragma solidity >=0.8.0 <0.9.0;

import "@openzeppelin/contracts-upgradeable/access/AccessControlUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/utils/ContextUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/proxy/utils/Initializable.sol";

import "../../library/Data.sol";
import "./IAdminUpgradeable.sol";

contract AdminUpgradeable is Initializable, AccessControlUpgradeable, IAdminUpgradeable {
    
    event SetInfraFee(uint16 tipFee, uint16 tradeFee);
    event SetContract(address contractAddress, uint8 contractType);
    
    address public receiverAddress;
    bytes32 public constant DAO_ROLE = keccak256("DAO_ROLE");
    
    string private constant PERM_ERR = "No Permission";
    string private constant VALUE_ERR = "Max 30% Fee, at value=3000";

    
    uint256 public networkCount;
    // index => networkID
    mapping(uint256 => string) public supportedExternalNetworks; // networkID is the position of networkType in list + 1
    mapping(uint256 => string) public networkIDTypeMapping;
    // networkID => network enabled
    mapping(uint256 => bool) public externalNetworkEnableMapping;
    // network Type 
    mapping(string=>bool) public registeredNetworkTypeMapping;


    // store the list of contracts and fee
    mapping(Data.Modules=>address) public contractMapping;
    mapping(address=>bool) public whiteListedContracts;    
    mapping(bytes32=>bool) public whiteListedDomains;

    // infraFee
    uint16 public tradeFee;
    uint16 public tipFee;

    modifier onlyDao {
        require(hasRole(DAO_ROLE, _msgSender()), PERM_ERR);
        _;
    }
    
    function initialize() public initializer {
        __AccessControl_init_unchained();
        _setupRole(DEFAULT_ADMIN_ROLE, _msgSender());
        _setupRole(DAO_ROLE, _msgSender());
        receiverAddress = _msgSender();
    }

    // receiver address is the address that recevie the fees on using the RADIAN infrastructure
    function setReceiverAddress(address receiver) public onlyDao {
        receiverAddress = receiver;
    }

    function getReceiverAddress() public view override returns (address payable) {
        return payable(receiverAddress);
    }

    function setContract(address contractAddress, Data.Modules contractType) public {
        contractMapping[contractType] = contractAddress;
        emit SetContract(contractAddress, uint8(contractType));
    }

    function getContract(Data.Modules contractType) public view override returns (address) {
        return contractMapping[contractType];
    }
    
    // update infra Fee
    function setInfraFee(
        uint16 _tipFee,
        uint16 _tradeFee
    ) external override onlyDao {
        require(tipFee <= 3000, VALUE_ERR);
        require(tradeFee <= 3000, VALUE_ERR);
        tipFee = _tipFee;
        tradeFee = _tradeFee;

        // emit event
        emit SetInfraFee(tipFee, tradeFee);
    }

    function setTipFee(uint16 _tipFee) external override onlyDao {
        tipFee = _tipFee;
    }

    function setTradeFee(uint16 _tradeFee) external override onlyDao{
        tradeFee = _tradeFee;
    }

    // whitelist interaction contracts
    function setWhiteListedContract(address whiteListedContract)  external override onlyDao {
        whiteListedContracts[whiteListedContract] = true;
    }

    function pauseWhiteListedContract(address whiteListedContract) external override onlyDao {
        whiteListedContracts[whiteListedContract] = false;
    }

    function isContractWhitelisted(address sender) external view override returns (bool){
        return whiteListedContracts[sender];
    }

    // whitelist domain name
    function setWhiteListedDomain(string memory whiteListedDomain) external override onlyDao {
        whiteListedDomains[keccak256(bytes(whiteListedDomain))] = true;
    }

    function pauseWhiteListedDomain(string memory whiteListedDomain) external override onlyDao {
        whiteListedDomains[keccak256(bytes(whiteListedDomain))] = false;
    }

    function isDomainWhitelisted(bytes32 domainHash) external view override returns (bool) {
        return whiteListedDomains[domainHash];
    }

    // get fee
    function getTradeFee() external override view returns (uint16) {
        return tradeFee;
    }

    function getTipFee() external override view returns (uint16) {
        return tipFee;
    }


}