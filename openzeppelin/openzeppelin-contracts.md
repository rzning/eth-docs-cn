# Contracts - OpenZeppelin Docs

- <https://docs.openzeppelin.com/contracts/4.x/>

> A library for secure smart contract development.

一个用于安全智能合约开发的库。


## Overview

### Installation

```sh
npm install @openzeppelin/contracts
```

### Usage

```solidity
// contracts/MyNFT.sol
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";

contract MyNFT is ERC721 {
    constructor() ERC721("MyNFT", "MNFT") {
    }
}
```

## Learn More

- 访问控制 [Access Control](https://docs.openzeppelin.com/contracts/4.x/access-control)

- 代币 [Tokens](https://docs.openzeppelin.com/contracts/4.x/tokens)

  - [ERC20](https://docs.openzeppelin.com/contracts/4.x/erc20)
  - [ERC721](https://docs.openzeppelin.com/contracts/4.x/erc721)

- 实用工具 [Utilities](https://docs.openzeppelin.com/contracts/4.x/utilities)

API

- [Access](https://docs.openzeppelin.com/contracts/4.x/api/access)
- [ERC 20](https://docs.openzeppelin.com/contracts/4.x/api/token/erc20)
- ERC 721
- ERC 777
- ERC 1155
- Finance
- Governance
- Meta Transactions
- Proxy
- Security
- Utils

