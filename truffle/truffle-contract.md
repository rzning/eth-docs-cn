# @truffle/contract

- <https://github.com/trufflesuite/truffle/tree/develop/packages/contract>

更好的以太坊合约抽象，适用于 Node.js 和浏览器。

## Install

```sh
$ npm install @truffle/contract
```

## Usage

- 首先，设置一个新的 Web3 提供者 ( Provider ) 实例，并初始化你的合约。

- `contract()` 函数的输入是一个由 `@truffle/contract-schema` 定义的 JSON 对象 ( Blob ) 。

```js
const provider = new Web3.providers.HttpProvider('http://localhost:8545')
const contract = require('@truffle/contract')

var MyContract = contract({
  abi: [ ... ],
  unlinked_binary: ...,
  address: ..., // 可选的
  // 其他信息
})

MyContract.setProvider(provider)
```

现在你可以访问 `MyContract` 上的以下函数，以及其他更多函数：

- `at(address)`
  - 创建一个指定地址的 `MyContract` 实例。
- `deployed()`
  - 创建一个由 `MyContract` 管理的默认地址的 `MyContract` 实例。
- `new()`
  - 将此合约的新版本部署到网络，并获得代表新部署合约的 `MyContract` 实例。

每个实例都绑定到以太坊网络上的特定地址，并且每个实例都有从 Javascript 函数到合约函数的一对一映射。

```js
var deployedInstance = null
MyContract.deployed()
  .then((instance) => {
    // 获取部署的合约实例
    deployedInstance = instance
    return instance.someFunction(5)
  })
  .then((result) => {
    // Do something with the result or continue with more transactions.
    // 对结果进行处理，或者继续处理更多交易
    // ...
  })
```

或者使用 ES6 语法：

```js
const instance = await MyContract.deployed()
const result = await instance.someFunction(5)
```

## Example

我们将从 [Dapps For Beginners](https://dappsforbeginners.wordpress.com/tutorials/your-first-dapp/)
中的一个合约示例来使用 `@truffle/contract` 。

在这种情况下，抽象被 `@truffle/artifactor` 保存到一个 `.sol` 文件中。

```js
// 导入预先由 @truffle/artifactor 保存的包
const MetaCoin = require('./path/to/MetaCoin.sol')

// 设置 Web3 提供者
MetaCoin.setProvider(provider)

// 在此场景中，两个账户将来回发送 MetaCoin
// 以显示 @truffle/contract 如何实现简单的控制流
const account_one = 'f82526320d...'
const account_two = '4a08fcfc5e...'

// MetaCoin 合约地址
const contract_address = '8Ffa07FEF4...'

// MetaCoin 合约实例
let coin

MetaCoin.at(contract_address)
  .then((instance) => {
    coin = instance

    // 执行 sendCoin() 函数发送一个交易 ( Transaction )
    return coin.sendCoin(account_two, 3, { from: account_one })
  })
  .then((result) => {
    // 此回调函数不会立即执行，直到 @truffle/contract 验证了交易已经被处理，并且它被成功写入新的区块。
    // 如果在 120 秒内没有被处理， @truffle/contract 将抛出错误。

    // 返回一个 Promise 检查 account_two 的余额
    return coin.balances.call(account_two)
  })
  .then((balance_of_account_two) => {
    alert('Balance of account two is ', balance_of_account_two)
    // => 3

    // 发起交易，退回一定数额的 MetaCoin
    return coin.sendCoin(account_one, 1.5, { from: account_two })
  })
  .then((result) => {
    // 等待交易完成

    // 再次获取 account_two 的余额
    return coin.balances.call(account_two)
  })
  .then((balance_of_account_two) => {
    alert('Balance of account two is ' + balance_of_account_two)
    // => 1.5
  })
  .catch((error) => {
    alert('Error! ' + error.message)
  })
```

## API

你需要注意到这里有两个 API ：

- 一个是静态的合约抽象 ( Contract Abstraction ) API

  - 合约抽象 API 是一组适用于所有合约抽象函数，这些函数存在于抽象本身。

- 另一个是合约实例 ( Contract Instance ) API

  - 实例 API 是合约实例可用的 API ，它代表一个在网络上部署的特定合约的抽象，
  - 并且该 API 是基于 Solidity 源文件中可用的函数动态创建的。

## Contract Abstraction API

每个合约抽象，例如上面例子中的 `MyContract` ，都有以下实用函数：

- `MyContract.new([arg1, arg2, ...], [tx params])`

- `MyContract.at(address)`

- `MyContract.deployed()`

- `MyContract.transactionHash`

- `MyContract.link(instance)`

- `MyContract.link(name, address)`

- `MyContract.link(object)`

- `MyContract.networks()`

- `MyContract.setProvider(provider)`

- `MyContract.setNetwork(network_id)`

- `MyContract.hasNetwork(network_id)`

- `MyContract.defaults([new_defaults])`

- `MyContract.clone(network_id)`

- `MyContract.numberFormat = number_type`

- `MyContract.timeout(block_timeout)`

- `MyContract.autoGas = <boolean>`

- `MyContract.gasMultiplier(gas_multiplier)`

## Contract Instance API

每个合约实例根据合约 Solidity 源文件的不同而不同，并且实例的 API 是根据 Solidity 源文件动态创建的。

本文档使用以下 Solidity 源文件中的的 `MyContract` 合约作为示例讲解：

```solidity
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.5;

contract MyContract {
  uint256 public value;
  event ValueSet(uint256 value);

  function setValue(uint256 _value) public {
    value = _value;
    emit ValueSet(value);
  }

  function getValue() public view returns (uint256) {
    return value;
  }
}

```

获取已部署的合约实例：

```js
const instance = await MyContract.deployed()
// 得到的合约实例 JavaScript 对象包含三个函数： value(), setValue(), getValue()
```

使用合约函数发起一个交易：

```js
const result = await instance.setValue(5)
console.log(result)
```

执行交易将得到以下返回结果：

```js
{
  // 交易哈希
  tx: 'Ox6cb0bb...',
  // 收据信息： web3.eth.getTransactionReceipt(hash) 的返回值
  receipt: {
    // ...
  },
  // 触发的事件日志
  logs: [
    {
      address: "0x13274f...",
      args: {
        _value: BigNumber(5)
      },
      blockHash: "0x2f0700...",
      blockNumber: 42,
      event: "ValueSet",
      logIndex: 0,
      transactionHash: "0x6cb0bb...",
      transactionIndex: 0,
      type: "mined"
    }
  ]
}
```

- 如果交易调用的执行函数有返回值，则不会在这个结果对象中得到返回值。
- 你必须使用一个事件，如上例中的 `ValueSet` 事件，并且在日志数组总查找结果。

可以使用 `.call()` 显式发起一个调用，而不创建交易：

```js
instance.setValue.call(5).then(() => {
  // ...
})
// 上面调用不是很有用，因为 setValue() 会写入数据，
// 而我们传递的值不会被保存，因为我们没有创建交易。

// 调用 Getter 函数，并得到返回结果
instance.getValue.call().then((value) => {
  // ...
})

// 当函数被标记为 view 或 pure 时，直接执行函数同 call() 调用。
// @truffle/contract 自动将其以调用 ( Call ) 进行交互
instance.getValue().then((value) => {
  // ...
})
```

- 调用 ( Call ) 总是免费的，不花费任何 Ether ，所以很适合执行从区块链读取数据的函数。

发送以太 ( Ether ) 以及触发回退 ( Fallback ) 函数：

```js
// 通过发送一个交易来触发合约的回退函数：
instance
  .sendTransaction({
    // ...
  })
  .then((result) => {
    // ...
  })

// 只是想将 Ether 发送到合约，可以使用以下简写：
instance.send(web3.toWei(1, 'ether')).then((result) => {
  // ...
})
```

估计 Gas 使用量：

```js
instance.setValue.estimateGas(5).then((result) => {
  // result 为执行这个交易所需的 Gas 的估计值
})
```
