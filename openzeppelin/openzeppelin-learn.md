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

> 部署合约并与之交互

- 与大多数软件不同，智能合约不会在你的计算机或某人的服务器上运行，它们存在于以太坊网络本身。
  这意味着与它们交互与更传统的应用程序有一点不同。

### 3.1 安装本地区块链 ( Setting up a Local Blockchain )

- 在开始之前，我们首先需要一个可以部署合约的环境。
- 以太坊区块链（通常被称为“主网”，意为“主网络”）要求以以太币的形式使用真钱。
  这使得它在尝试新想法或工具时成为一个糟糕的选择。
- 为了解决这个问题，存在一些“测试网”，包括 Ropsten, Rinkeby, Kovan 和 Goerli 区块链。
- 在开发过程中，最好使用本地区块链。
  它运行在你的机器上，不需要 Internet 访问，并提供所有你需要的 Ether 。
  这些原因也使得本地区块链非常适合自动化测试。
- 最受欢迎的本地区块链是 [Ganache](https://github.com/trufflesuite/ganache-cli)

在你项目中安装 Ganache 命令行工具：

```sh
$ npm install --save-dev ganache-cli
```

在启动时， Ganache 将创建一组随机解锁的帐户，并给他们 Ether 。

```sh
$ npx ganache-cli --deterministic
```

- Ganache 将打印出可用帐户及其私钥的列表，以及一些区块链配置值。
- 最重要的是，它将显示其地址，我们将使用该地址连接到它。默认情况下为 `127.0.0.1:8545` 。
- 请记住，每次运行 Ganache 时，它都会创建一个全新的本地区块链，以前运行的状态不会保留。
- 或者，在运行 Ganache 时使用 `——db` 选项 ，提供一个目录来存储运行期间的数据。

### 3.2 部署智能合约 ( Deploying a Smart Contract )

> Truffle 使用迁移 (migrations) 来部署合约。
>
> [Running Migrations - Truffle Suite Documentation](https://www.trufflesuite.com/docs/truffle/getting-started/running-migrations)

- 迁移由 JavaScript 文件和一个用于跟踪链上迁移的特殊迁移合约组成。

创建一个 JavaScript 迁移文件来部署 Box 合约：

```js
// migrations/2_deploy.js

const Box = artifacts.require("Box")

module.exports = async function (deployer) {
  await deployer.deploy(Box)
}
```

在部署之前，我们需要配置与 ganache 的连接：

```js
// truffle-config.js

module.exports = {
  // ...
  networks: {
    development: {
      host: '127.0.0.1',
      port: 8545,
      network_id: '*'
    }
    // ...
  }
}
```

使用 [migrate](https://www.trufflesuite.com/docs/truffle/reference/truffle-commands#migrate)
命令将 Box 合约部署到 `development` 网路 ( Ganache ) ：

```sh
$ npx truffle migrate --network development
```

- Truffle 会跟踪你已经部署的合约，但在部署时也会显示其地址。
  这些值在以编程方式与它们进行交互时非常有用。

### 3.3 从控制台进行交互 ( Interacting from the Console )

使用 [Truffle Console](https://www.trufflesuite.com/docs/truffle/getting-started/using-truffle-develop-and-the-console)
与我们在本地开发网路上部署的 Box 智能合约进行交互：

```sh
$ npx truffle console --network development
truffle(development)> box = await Box.deployed()
undefined
```

发送交易：

- Box 合约的 `store` 函数接收一个整数值并将其存储在合约存储中，
- 由于此函数修改了区块链的状态，因此我们需要向合约发送一个交易 ( Transaction ) 来执行它。

```sh
truffle(development)> await box.store(42)
```

- 交易收据 ( Transaction Receipt ) 还显示了 Box 合约触发了一个 `ValueChanged` 事件。


查询状态：

- 只是对区块链状态的查询，不需要发送交易。
- 查询状态不会花费任何的 Ether 。

```sh
truffle(development)> await box.retrieve()
<BN: 2a>
```

- Box 合约默认返回 `uint256` 格式的数字，可以将其转换为字符串显示：

```sh
truffle(development)> (await box.retrieve()).toString()
'42'
```

### 3.4 以编程方式进行交互 ( Interacting programmatically )

> [Writing External Scripts - Truffle Suite](https://www.trufflesuite.com/docs/truffle/getting-started/writing-external-scripts)

编写脚本：

```js
// scripts/index.js

module.exports = async function main(callback) {
  try {
    // 在这里编写我们的逻辑
    // ...

    // Retrieve accounts from the local node
    // 从本地节点查询启用的账户列表
    const accounts = await web3.eth.getAccounts()
    console.log(accounts)

    // 获取合约实例
    // Set up a Truffle contract, representing our deployed Box instance
    // 使用 Trufle 合约抽象，来表示我们部署的 Box 实例
    const Box = artifacts.require('Box')
    const box = await Box.deployed()

    // 发送一个交易 ( Sending a transaction )
    // Send a transaction to store() a new value in the Box
    await box.store(23)

    // 调用合约方法
    // Call the retrieve() function of the deployed Box contract
    // 调用已部署的 Box 合约的 retrieve() 函数
    value = await box.retrieve()
    console.log('Box value is', value.toString())

    callback(0)
  } catch (exception) {
    console.error(exception)
    callback(1)
  }
}
```

- 脚本逻辑应该都添加到上面 `main()` 函数中。

执行脚本:

```sh
$ npx truffle exec --network development ./scripts/index.js
```

- 对于发送交易：
- 在实际应用程序中，你可能需要先估计交易所需的 Gas 价格，
- 并检查 [gas price oracle](https://ethgasstation.info/) 以了解每笔交易的最优价格。


> 使用 Web3 中的 `estimateGas()` 方法估计所需的 Gas
> 
> `myContract.methods.myMethod(...).estimateGas(options[, callback])` 
> 
> [estimateGas - web3.eth.Contract](https://web3js.readthedocs.io/en/v1.2.0/web3-eth-contract.html#methods-mymethod-estimategas)


--------------------------------------------------------------------------------

## 4. Writing automated tests

> 编写自动化测试

