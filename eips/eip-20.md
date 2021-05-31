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
> - 一下规范使用 Solidity 0.4.17 或更高版本语法。
> - 调用者必须处理 `returns (bool success)` 返回  `false` 的情况，
>   调用者绝不能假定 `false` 永远不返回。

```solidity
function name() public view returns (string)

function symbol() public view returns (string)

function decimals() public view returns (uint8)

function totalSupply() public view returns (uint256)

function balanceOf(address _owner) public view returns (uint256 balance)

function transfer(address _to, uint256 _value) public returns (bool success)

function transferFrom(address _from, address _to, uint256 _value) public returns (bool success)

function approve(address _spender, uint256 _value) public returns (bool success)

function allowance(address _owner, address _spender) public view returns (uint256 remaining)
```

### 事件 Events

```solidity
event Transfer(address indexed _from, address indexed _to, uint256 _value)

event Approval(address indexed _owner, address indexed _spender, uint256 _value)
```

## 实现 Implementation

- [OpenZeppelin implementation](https://github.com/OpenZeppelin/openzeppelin-contracts/blob/master/contracts/token/ERC20/ERC20.sol)
- [ConsenSys implementation](https://github.com/ConsenSys/Tokens/blob/master/contracts/eip20/EIP20.sol)

