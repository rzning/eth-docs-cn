# Go Ethereum

> 仓库地址 : <https://github.com/ethereum/go-ethereum>

Go Ethereum 是官方 Go 语言实现的以太坊协议 ( Ethereum protocol ) 。

对于稳定的版本和不稳定的主分支，可以使用自动构建。

其二进制存档发表于 <https://geth.ethereum.org/downloads/> 。

## 从源文件构建

有关先决条件和详细的构建说明，请参阅 wiki 上的安装说明：

- [Building Ethereum · ethereum/go-ethereum Wiki](https://github.com/ethereum/go-ethereum/wiki/Building-Ethereum)

构建 Geth 需要 Go （版本 1.10 或更高）和 C 编译器。
你可以使用您最喜欢的包管理器安装它们。
一旦安装了依赖，运行下面命令：

```sh
$ make geth
```

或者，构建完整的实用程序套件：

```sh
$ make all
```

## 可执行程序

go-ethereum 项目附带了在 cmd 目录中可找到的几个包装器或可执行程序。

Command | Description
-|-
`geth` | Ethereum CLI 主客户端。它是进入以太网络的入口点，能够作为完整节点运行，存档节点（保留所有历史状态）或一个轻节点（实时检索数据）。
`abigen` | 一个源代码生成器将 Ethereum 合约定义转换为易于使用的、编译时、类型安全的 Go 包。
`bootnode` |
`evm` |
`gethrpctest` |
`rlpdump` |
`puppeth` |

## 运行 `geth`

