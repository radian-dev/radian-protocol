// SPDX-License-Identifier: GPL-3.0
pragma solidity >=0.8.0 <0.9.0;

interface IERC20 {
    function transferFrom(
        address from,
        address to,
        uint256 amount
    ) external returns (bool);
}

contract DirectTip {
    
    event TipPub(address fromUser, address toUser, string pubId, address tokenAddress, uint256 amount);
    event TipProfile(address fromUser, address toUser, string profileId, address tokenAddress, uint256 amount);

    function tipPubNativeToken(
        address toUser,
        string memory pubId,
        uint256 amount
    ) external {
        payable(toUser).transfer(amount);
        emit TipPub(msg.sender, toUser, pubId, address(0), amount);
    }
    
    function tipPubERC20Token(
        address toUser,
        string memory pubId,
        address tokenAddress,
        uint256 amount
    ) external {
        IERC20(tokenAddress).transferFrom(msg.sender, toUser, amount);
        emit TipPub(msg.sender, toUser, pubId, tokenAddress, amount);
    }

    function tipProfileNativeToken(
        address toUser,
        string memory profileId,
        uint256 amount
    ) external {
        payable(toUser).transfer(amount);
        emit TipProfile(msg.sender, toUser, profileId, address(0), amount);
    }
    
    function tipProfileERC20Token(
        address toUser,
        string memory profileId,
        address tokenAddress,
        uint256 amount
    ) external {
        IERC20(tokenAddress).transferFrom(msg.sender, toUser, amount);
        emit TipProfile(msg.sender, toUser, profileId, tokenAddress, amount);
    }

}