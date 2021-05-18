# Learn - OpenZeppelin Docs

- <https://docs.openzeppelin.com/learn/>

1. Setting up a Node project
2. Developing smart contracts
3. Deploying and interacting
4. Writing automated tests
5. Connecting to public test networks
6. Upgrading smart contracts
7. Preparing for mainnet

--------------------------------------------------------------------------------

## 1. Setting up a Node project

> 配置一个 Node 项目。

### 安装 Node

```sh
$ node --version
```

### 创建一个项目

```sh
$ mkdir learn && cd learn

$ npm init -y
```

### 使用 `npx`

```sh
$ npx truffle init
```

--------------------------------------------------------------------------------

## 2. Developing smart contracts

> 开发智能合约。

### 2.1 使用 truffle 初始化项目

```sh
$ npm install --save-dev truffle

$ npx truffle init
```

### 2.2 在 `contracts/` 目录编写一个名为 Box 的智能合约

```solidity
// contracts/Box.sol
// SPDX-License-Identifier: MIT
pragma solidity ^0.6.0;

contract Box {
    uint256 private value;

    // Emitted when the stored value changes
    // 当存储的值发生变化时触发
    event ValueChanged(uint256 newValue);

    // Stores a new value in the contract
    // 在合约中存储一个新值
    function store(uint256 newValue) public {
        value = newValue;
        emit ValueChanged(newValue);
    }

    // Reads the last stored value
    // 读取最后存储的值
    function retrieve() public view returns (uint256) {
        return value;
    }
}
```

### 2.3 编译合约

> 以太坊虚拟机 ( EVM ) 不能直接执行 Solidity 代码，我们首先需要将其编译为 EVM 字节码。

我们需要首先配置 Truffle 使用的 solc 版本：

```js
// truffle-config.js

module.exports = {
  // ...
  compilers: {
    solc: {
      version: '0.6.12'
      //...
    }
  }
}
```

执行编译命令：

```sh
$ npx truffle compile
```

### 2.4 添加更多合约

- 作为示例，我们需要在 Box 合约中添加一个简单的访问控制系统：
- 我们将在一个名为 Auth 的合约中存储一个管理员地址，并且只允许 Auth 中指定的账户使用 Box 合约。

```solidity
// contracts/access-control/Auth.sol
// SPDX-License-Identifier: MIT
pragma solidity ^0.6.0;

contract Auth {
    address private administrator;

    constructor() public {
        // Make the deployer of the contract the administrator
        // 使契约的部署者成为管理员
        administrator = msg.sender;
    }

    function isAdministrator(address user) public view returns (bool) {
        return user == administrator;
    }
}
```

在 Box 合约中引用 Auth 合约：

```solidity
// contracts/Box.sol
// SPDX-License-Identifier: MIT
pragma solidity ^0.6.0;

// Import Auth from the access-control subdirectory
// 从访问控制子目录导入 Auth
import "./access-control/Auth.sol";

contract Box {
    uint256 private value;
    Auth private auth;

    event ValueChanged(uint256 newValue);

    constructor(Auth _auth) public {
        auth = _auth;
    }

    function store(uint256 newValue) public {
        // Require that the caller is registered as an administrator in Auth
        // 要求调用者是 Auth 中注册的管理员
        require(auth.isAdministrator(msg.sender), "Unauthorized");

        value = newValue;
        emit ValueChanged(newValue);
    }

    function retrieve() public view returns (uint256) {
        return value;
    }
}
```

### 2.5 Using OpenZeppelin Contracts

> Solidity 合约继承：
> 
> [Inheritance - Contracts — Solidity 0.8.5 documentation](https://docs.soliditylang.org/en/latest/contracts.html#inheritance)

安装并导入 OpenZeppelin 合约：

```sh
$ npm install --save-dev @openzeppelin/contracts
```

```solidity
// contracts/Box.sol
// SPDX-License-Identifier: MIT
pragma solidity ^0.6.0;

// Import Ownable from the OpenZeppelin Contracts library
// 从 OpenZeppelin 合约库导入 Ownable
import "@openzeppelin/contracts/access/Ownable.sol";

// Make Box inherit from the Ownable contract
// 使 Box 继承自 Ownable 合约
contract Box is Ownable {
    uint256 private value;

    event ValueChanged(uint256 newValue);

    // The onlyOwner modifier restricts who can call the store function
    // onlyOwner 修饰符限制谁可以调用 store 函数
    function store(uint256 newValue) public onlyOwner {
        value = newValue;
        emit ValueChanged(newValue);
    }

    function retrieve() public view returns (uint256) {
        return value;
    }
}
```

> 有关 Ownable 合约的详细信息可以参考：
> 
> [Access Control - OpenZeppelin Docs](https://docs.openzeppelin.com/contracts/4.x/access-control)

--------------------------------------------------------------------------------

## 3. Deploying and interacting

> 部署和交互

