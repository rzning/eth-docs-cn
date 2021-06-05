# EIP-20: ERC-20 Token Standard

- <https://eips.ethereum.org/EIPS/eip-20>
- <https://github.com/ethereum/EIPs/blob/master/EIPS/eip-20.md>
- <https://learnblockchain.cn/docs/eips/eip-20.html>

ERC-20 代币标准

## 简要说明 Simple Summary

> A standard interface for tokens.

一个代币 ( Tokens ) 的标准接口。

## 摘要 Abstract

> The following standard allows for the implementation of a standard API for tokens within smart contracts.

以下标准允许在智能合约中实现 Tokens 的标准 API 。

> This standard provides basic functionality to transfer tokens,
> as well as allow tokens to be approved so they can be spent by another on-chain third party.

该标准提供了转账代币的基本功能，并且允许授权代币给其他人，以便链上第三方应用使用。

## 动机 Motivation

> A standard interface allows any tokens on Ethereum to be re-used by other applications:
> from wallets to decentralized exchanges.

标准接口允许以太坊上的任何代币被其他应用程序重用：从钱包到去中心化的交易所。

## 代币规范 Token Specification

### 函数 Methods

> Notes:
>
> - 一下规范使用 Solidity 0.4.17 或更高版本语法。
> - 调用者必须处理 `returns (bool success)` 返回 `false` 的情况，
>   调用者绝不能假定 `false` 永远不返回。

```solidity
/**
 * @dev [可选] 返回代币的名称
 */
function name() public view returns (string)

/**
 * @dev [可选] 返回代币的符号（通常为字母缩写）例如 “HIX”
 */
function symbol() public view returns (string)

/**
 * @dev [可选] 返回代币使用的小数点数，例如 8 表示将代币数量除以 100000000 以获得其用户表示
 */
function decimals() public view returns (uint8)

/**
 * @dev 返回代币总供应量
 */
function totalSupply() public view returns (uint256)

/**
 * @dev 返回 `_owner` 指定账户的余额
 */
function balanceOf(address _owner) public view returns (uint256 balance)

/**
 * @dev 向 `_to` 地址转 `_value` 数量的代币，并且必须触发 `Transfer` 事件。
 *
 * 如果消息调用者的账户余额没有足够的代币，函数应该抛出 ( `throw` ) 异常。
 *
 * NOTE: 转 0 个代币必须视为正常交易，同样需要触发 `Transfer` 事件。
 */
function transfer(address _to, uint256 _value) public returns (bool success)

/**
 * @dev 从 `_from` 地址向 `_to` 地址转 `_value` 数量的代币，并且必须触发 `Transfer` 事件。
 *
 * 此方法用于撤销工作流 ( Withdraw Workflow ) ，允许合约代表你转移代币。
 *
 * 例如，这可以用于允许合约代表你转移代币和/或以子货币收取费用。
 *
 * 除非 `_from` 账户通过某种机制授权消息的发送者，否则函数应该抛出 ( `throw` ) 异常。
 *
 * NOTE: 转 0 个代币必须视为正常交易，并触发 `Transfer` 事件。
 */
function transferFrom(address _from, address _to, uint256 _value) public returns (bool success)

/**
 * @dev 授权 `_spender` 可以从你的账户中多次提款 ( Withdraw ) ，最多提取 ( Withdraw ) `_value` 数量的代币。
 *
 * 如果再次调用此函数，将使用 `_value` 覆盖当前限额 ( Allowance ) 。
 *
 * NOTE: 为防止向量攻击 ( Attack Vectors ) ，客户端应确保以下面方式创建用户接口：
 * 需要先将限额设置为 0 ，然后再为同一 `_spender` 设置另一个值。
 */
function approve(address _spender, uint256 _value) public returns (bool success)

/**
 * @dev 返回 `_spender` 仍然可以从 `_owner` 中提取的的金额。
 *
 * 查询 `_owner` 授权给 `_spender` 的额度。
 */
function allowance(address _owner, address _spender) public view returns (uint256 remaining)
```

### 事件 Events

```solidity
/**
 * @dev 必须在代币转账 ( Transferred ) 时触发，包括零值转账。
 *
 * NOTE: 一个代币合约在创建新代币时应该触发 `Transfer` 事件，并将 `_from` 地址设置为 `0x0` 。
 */
event Transfer(address indexed _from, address indexed _to, uint256 _value)

/**
 * @dev `approve()` 函数成功调用时，必须触发 `Approval` 事件。
 */
event Approval(address indexed _owner, address indexed _spender, uint256 _value)
```

## 实现 Implementation

- [OpenZeppelin implementation](https://github.com/OpenZeppelin/openzeppelin-contracts/blob/master/contracts/token/ERC20/ERC20.sol)
- [ConsenSys implementation](https://github.com/ConsenSys/Tokens/blob/master/contracts/eip20/EIP20.sol)
