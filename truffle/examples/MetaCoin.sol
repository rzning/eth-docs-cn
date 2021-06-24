// SPDX-License-Identifier: MIT
pragma solidity >=0.4.25 <0.9.0;

import "./ConvertLib.sol";

// 此合约只是一个类似 Coin 合约的简单示例，并不是一个标准的代币合约。
// 若你想创建一个符合标准的 Token 合约，可以参考 https://github.com/ConsenSys/Tokens
// Cheers!

contract MetaCoin {
    /**
     * @notice 账户余额
     */
    mapping(address => uint256) balances;

    /**
     * @notice [Event] 账户转账时触发
     */
    event Transfer(address indexed _from, address indexed _to, uint256 _value);

    constructor() {
        balances[tx.origin] = 10000;
    }

    /**
     * @notice 向指定账户转账
     * @param receiver - 目标账户
     * @param amount - 转账金额
     */
    function sendCoin(address receiver, uint256 amount) public returns (bool sufficient) {
        if (balances[msg.sender] < amount) return false;
        balances[msg.sender] -= amount;
        balances[receiver] += amount;
        emit Transfer(msg.sender, receiver, amount);
        return true;
    }

    /**
     * @notice 以指定单位查询余额
     */
    function getBalanceInEth(address addr) public view returns (uint256) {
        return ConvertLib.convert(getBalance(addr), 2);
    }

    /**
     * @notice 查询余额
     */
    function getBalance(address addr) public view returns (uint256) {
        return balances[addr];
    }
}
