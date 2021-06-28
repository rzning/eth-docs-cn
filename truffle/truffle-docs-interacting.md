# Intercating With Your Contracts

与你的合约交互

- <https://www.trufflesuite.com/docs/truffle/getting-started/interacting-with-your-contracts>

编写原生请求到以太坊网络，实现与你的合约交互，非常的笨拙和麻烦。
而且对于发出的每个请求的状态也非常的复杂。
幸运的是， Truffle 为此进行了封装，使你可以轻松地与合约进行交互。

## 读写数据

- 向以太坊网络写入数据称为：交易 ( Transaction )
- 从以太坊网络读取数据称为：调用 ( Call )

💰 交易 Transactions

- 消耗 Gas 费用 ( Ether )
- 改变网络状态
- 不会立即执行，需要等待矿工打包
- 没有执行返回值，只有一个交易 ID

📡 调用 Calls

- 免费，不消耗 Gas
- 不改变网络状态
- 立即执行
- 有返回值

## 合约抽象

合约抽象 ( Contract Abstraction ) 是通过 JavaScript 与以太坊合约进行交互的基础。

- 合约抽象是一种代码的封装，使我们可以更容易的与合约进行交互，而不用关系内部执行细节。
- Truffle 使用 `@truffle/contract` 模块实现它自己的合约抽象。

通过 `truffle unbox metacoin` 获得 MetaCoin 合约示例：

- [MetaCoin.sol](./examples/MetaCoin.sol)

> 合约中除构造函数外，提供了三个方法 `sendCoin()` , `getBalanceInEth()` , `getBalance()`

合约编译部署之后可以在 Truffle 控制台中，以名为 `MetaCoin` 的合约抽象进行访问：

```sh
truffle(develop)> let instance = await MetaCoin.deployed()
```

- 由合约抽象可以得到特定地址的合约实例。
- 合约抽象实例包含与合约中存在的完全相同的函数。
- 合约抽象实例还包含一个指向合约部署版本的地址。

## 执行合约函数

- 使用合约抽象实例，可以轻松的在以太坊网络上执行合约函数。

💰 执行交易 Transaction

- 在 MetaCoin 合约中 `sendCoin()` 是唯一一个会改变网络状态的函数。
- 我们需要将 `sendCoin(receiver, amount)` 函数作为一个交易 ( Transaction ) 来执行。

```sh
truffle(develop)> let accounts = await web3.eth.getAccounts()
truffle(develop)> instance.sendCoin(accounts[1], 10, {from: accounts[0]})
```

以上代码有一些有趣的地方：

- 我们直接调用合约实例的 `sendCoin()` 函数，它默认以交易来执行，而不是调用。
- 我们将一个对象作为第三个参数传递给了 `sendCoin()` 函数，而在合约中此函数没有第三个参数。
- 我们称这个特殊的对象为交易参数 ( Transaction Params ) 。
- 从合约实例执行 Transaction 函数时，始终可以将 Transaction Params 作为最后一个参数传递。
- 上例中我们设置了 `from` 地址参数，以确保此交易来自 `accounts[0]` 账户。

可以设置的 Transaction Params 对应于以太坊交易中的字段：

- `from`
- `to`
- `gas`
- `gasPrice`
- `value`
- `data`
- `nonce`

📡 执行调用 Call

- 调用 `getBalance()` 函数查询指定账户的余额，此函数没有改变网络状态，只是简单的返回执行结果。

```sh
truffle(develop)> let balance = await instance.getBalance(accounts[0])
truffle(develop)> balance.toNumber()
```

- 由于以太坊可以处理非常大的数字，
  我们执行以上方法将得到一个 [BN](https://github.com/indutny/bn.js) 对象，
  然后将其转换为数字并打印。

## 处理交易结果

```sh
truffle(develop)> let result = await instance.sendCoin(accounts[1], 10, {from: accounts[0]})
truffle(develop)> result
```

当执行交易时，将得到一个 `result` 对象，其中包含有关此次交易的大量信息：

- `result.tx` - ( string ) 交易哈希
- `result.logs` - ( array ) 已解码的事件日志
- `result.receipt` - ( object ) 交易收据，包括使用的 Gas 数量。

更多信息，可以参阅 [@truffle/contract](https://github.com/trufflesuite/truffle/tree/master/packages/contract)

## 捕获事件

- 通过捕获合约触发的事件，可以更深入的了解合约的状态。
- 处理事件最简单的方式是，处理交易结果中的 `logs` 数组。

```sh
truffle(develop)> let result = await instance.sendCoin(accounts[1], 10, {from: accounts[0]})
truffle(develop)> result.log[0]
```

- 执行以上代码将得到执行 `sendCoin()` 函数触发 `Transfer(msg.sender, receiver, amount)` 事件的细节。

## 部署一个新合约

- 调用合约的 `new()` 函数，可以将一个新的合约部署到网络，并返回其实例对象。

```sh
truffle(develop)> let newInstance = await MetaCoin.new()
truffle(develop)> newInstance.address
'0x64307b67314b584b1E3Be606255bd683C835A876'
```

## 使用指定地址的合约

- 如果已经有已部署的合约地址，可以使用合约的 `at()` 方法创建一个新的合约实例来表示该地址上的合约。

```sh
truffle(develop)> let specificInstance = await MetaCoin.at("0x1234...");
```

## 给合约发送以太币 ( Ether )

你可以简单的直接向合约发送 Ether 或者触发合约的 [Fallback] 函数。

[fallback]: https://docs.soliditylang.org/en/develop/contracts.html#fallback-function

```js
// 将交易直接发送到合约，这与执行所有可用的合约实例函数一样有效，
// 并且和 `web3.eth.sendTransaction()` 函数的 API 相同， 只是没有回调。
// 若未指定目标地址 `to` ，则会自动填充。
instance
  .sendTransaction({
    // ...
  })
  .then((result) => {
    // ...
  })

// 直接发送以太的一种简写：
instance.send(web3.utils.toWei(1, 'ether')).then((result) => {
  // ...
})
```

## Truffle 合约对象的特殊方法

- `estimateGas()` - 估计一笔交易所需的 Gas 量
- `sendTransaction()` - 以交易 ( Transaction ) 方式执行指定方法
- `call()` - 以调用 ( Call ) 方式执行指定方法
- `request()`
  - 此方法不执行交易或调用，
  - 而是返回一个可传递给 `web3.eth.sendTransaction()` 或 `web3.eth.call()` 的对象，以便手动执行。
  - 与 `estimateGas()` 方法类似，若你想执行手动部署，可用使用 `Contract.new.request()`

```js
const instance = await MyContract.deployed()

// 估计执行 `sendTokens()` 函数所需的 Gas
// 参数 `4, myAccount` 对应合约函数的签名
const amountOfGas = await instance.sendTokens.estimateGas(4, myAccount)

// 估计部署合约所需的 Gas
const deployOfGas = await MyContract.new.estimateGas()

// 强制以交易方式执行合约的 getTokenBalance() 函数
// 返回的结果为此次交易的详情对象
const result = await instance.getTokenBalance.sendTransaction(myAccount)
```

## 执行重载方法

可以通过合约的 `.methods` 属性显式地调用它们的访问器：

```js
const instance = await MyContract.deployed()
instance.methods['setValue(uint256)'](123)
instance.methods['setValue(uint256,uint256)'](11, 55)
```

## 使用枚举

```solidity
contract ExampleContract {
  enum ExampleEnum {
    ExampleOption0,
    ExampleOption1,
    ExampleOption2
  }

  // ...
}

```

通过合约抽象可以访问合约中定义的枚举：

```js
const value = ExampleContract.ExampleEnum.ExampleOption0
// => 0

// 也可以通过合约抽象上的 `enums` 属性得到枚举属性
const value2 = ExampleContract.enums.ExampleEnum.ExampleOption0
//  => 0
```

可以直接将枚举传递给合约方法，而不必担心它们的数值。
