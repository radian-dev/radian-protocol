// SPDX-License-Identifier: GPL-3.0
pragma solidity >=0.8.0 <0.9.0;

import "../../library/Data.sol";

interface IAdminUpgradeable {

    function setInfraFee(uint16 tipFee, uint16 tradeFee) external;
    function setTipFee(uint16 _tipFee) external;
    function setTradeFee(uint16 _tradeFee) external;

    function setWhiteListedContract(address whiteListedContract)  external;
    function pauseWhiteListedContract(address whiteListedContract) external;
    function isContractWhitelisted(address sender) external view returns (bool);

    function setWhiteListedDomain(string memory whiteListedDomain) external;
    function pauseWhiteListedDomain(string memory whiteListedDomain) external;
    function isDomainWhitelisted(bytes32 domainHash) external view returns (bool);
    
    // get contract 
    function getContract(Data.Modules contractType) external view returns (address);

    // get fee
    function getTradeFee() external view returns (uint16);
    function getTipFee() external view returns (uint16);

    // get the receiver address
    function getReceiverAddress() external returns (address payable);

}