# Solidity Reference Types

- <https://docs.soliditylang.org/en/develop/types.html#reference-types>

目前，引用类型包括：

- 结构体 ( Structs )
- 数组 ( Arrays )
- 映射 ( Mappings )

---

本文内容：

1. 数据位置 ( Data location )
2. 数组 ( Arrays )
3. 数组切片 ( Array Slices )
4. 结构体 ( Structs )
5. 映射类型 ( Mapping Types )

---

## 1. Data location

所有引用类型都有一个额外的注解：数据位置 ( Data Location )

如果使用引用类型，则始终必须显式提供类型被存储的数据区域：

- `memory` - 其生命周期仅限于外部函数调用。
- `storage` - 存储状态变量的位置，生命周期仅限于合约的生命周期。
- `calldata` - 用于存储函数参数的特殊区域。

有关 `calldata` 说明：

- `calldata` 为一个不可修改、非持久化的区域，用于存储函数参数，其行为与 `memory` 类似。
- 外部函数的参数需要使用 `calldata` 声明，也可以用在其他变量。
- 在 0.5.0 版本之前，可以省略数据位置，并且会根据变量的类型、函数类型等默认到不同的位置，
  但现在所有的复杂类型都必须给出明确的数据位置。
- 如果可以，请尝试使用 `calldata` 用作数据位置，这样可以避免复制并确保数据不被修改。
- 具有 `calldata` 数据位置的数组和结构体也可以从函数中返回，但不能分配此类类型。

数据位置不仅与数据的持久性相关，而且与赋值的语义相关：

- 在 `storage` 和 `memory` 或来自 `calldata` 之间的赋值，总是创建一个独立的副本。
- 从 `memory` 到 `memory` 的赋值只能创建引用。
  者意味着对一个内存变量的更改，在引用相同数据的所有其他内存变量中也可见。
- 从 `storage` 到本地存储变量的赋值，也只是分配一个引用。
- 所有其他赋值给 `storage` 都是复制。

```solidity
// SPDX-License-Identifier: GPL-3.0
pragma solidity >=0.5.0 <0.9.0;

contract C {
  // 数组 x 的存储位置是 storage
  // 这是唯一可以省略数据位置的地方。
  uint256[] x;

  // memoryArray 的数据位置为 memory
  function f(uint256[] memory memoryArray) public {
    // ✔ 可行，将整个数组复制到 storage
    x = memoryArray;

    // ✔ 可行，赋值一个指针，变量 y 的数据位置为 storage
    uint256[] storage y = x;

    // ✔ 可行，通过 y 修改 x
    y.pop();

    // ✔ 可行，清除数组，同时修改 y
    delete x;

    // ❌ 不可行，它需要在存储中创建一个新的临时未命名数组，但是 storage 是静态分配的。
    y = memoryArray;
    //  ^ error: uint256[] memory 类型不能隐式转换为期望的 uint256[] storage 指针类型。

    // ❌ 不可行，因为它会重置指针，但它没有可指向的合理位置。
    delete y;
    // ^ error: 一元运算符 delete 不能应用于 uint256[] storage 指针类型。

    // ✔ 可调用，移交对 x 的引用
    g(x);
    // ✔ 可调用，在 memory 中创建一个独立的临时副本
    h(x);
  }

  function g(uint256[] storage) internal pure {}

  function h(uint256[] memory) public pure {}
}

```

## 2. Arrays

数组可以是编译时固定大小，也可以是动态大小。

元素类型为 `T` 固定大小为 `k` 的数组标记为 `T[k]` ，动态大小则标记为 `T[]` 。

例如一个由 5 个 `uint` 动态数组组成的数组写作 `uint[][5]` 。与其他一些语言相比，这种符号是相反的。

索引是从零开始的，访问与声明的方向相反。例如你有一个 `uint[][5] memory x` 变量，
使用 `x[2][6]` 来访问第三个动态数组中的第七个 `uint` 数据，使用 `x[]` 访问第三个动态数组。

数组元素可以是任意类型的，包括映射或结构体。

由于类型的一般限制，映射只能存储在 `storage` 数据位置，并且公开可见的函数需要 ABI 类型的参数。

可以将状态变量数组标记为 `public` 类型，这将使 Solidity 自动生成一个带数字索引必须参数的 Getter 函数。

访问超出数组长度的元素将导致断言错误。

### 2.1 `bytes` and `string` 作为数组

`bytes` 和 `string` 类型的变量是特殊的数组。

- `bytes` 类似于 `byte[]` ，但是 `bytes` 数据被紧密打包在 calldata 和 memory 中。

- `string` 与 `bytes` 相同，但是不能通过长度和索引来访问。

Solidity 没有字符串操作函数，但是有第三方字符串库。

你可以通过使用它们的 keccak256-hash 来比较两个字符串，可以使用 `bytes.concat()` 函数来连接两个字符串：

```solidity
function f(string calldata s1, string calldata s2) {
  /// @dev 比较字符串
  keccak256(abi.encodePacked(s1)) == keccak256(abi.encodePacked(s2));
  /// @dev 拼接字符串
  bytes.concat(bytes(s1), bytes(s2));
}

```

你应该使用 `bytes` 而不是 `byte[]` ，因为其 Gas 费用更低，由于 `byte[]` 在元素之间添加了 31 个填充字节。

作为一般规则，使用 `bytes` 表示任意长度的原始字节数据，使用 `string` 表示任意长度的字符串 ( UTF-8 ) 数据。

如果可以将长度限制在一定数量的字节，那么总是使用 `bytes1` 到 `bytes32` 中的一种值类型，因为它们便宜得多。

如果你想以字节形式访问字符串 `str` 可以使用 `bytes(str).length` 或者 `bytes(str)[7] = 'x'` 。
请记住，你访问的是 UTF-8 形式的低级字节，而不是单个字符。

### 2.2 `bytes.concat()` 函数

你可以使用 `bytes.concat()` 连接一个可变数量的 `bytes` 或者 `bytes1 ... bytes32` 。

该函数返回单个 `bytes memory` 类型数组，其中包含无填充的参数内容。

如果希望使用字符串参数或其他类型，则需要首先将它们转换为 `bytes` 或 `bytes1 ... bytes32` 。

```solidity
// SPDX-License-Identifier: GPL-3.0
pragma solidity ^0.8.4;

contract C {
  bytes s = 'Storage';

  function f(
    bytes calldata c,
    string memory m,
    bytes16 b
  ) public view {
    bytes memory a = bytes.concat(s, c, c[:2], 'Literal', bytes(m), b);
    assert((s.length + c.length + 2 + 7 + bytes(m).length + 16) == a.length);
  }
}

```

如果不带参数调用 `bytes.concat()` 函数，将返回一个空 `bytes` 数组。

### 2.3 Memory Arrays

可以使用 `new` 操作符来创建动态长度的内存数组。

与 storage arrays 相反的是，你不能调整 memory arrays 的大小，例如 `.push()` 成员函数将不可用。

你必须预先计算所需的大小，或者创建一个新的内存数组并复制每个元素。

正如 Solidity 中的所有变量一样，新分配数组的元素总是初始化为默认值。

```solidity
// SPDX-License-Identifier: GPL-3.0
pragma solidity >=0.4.16 <0.9.0;

contract C {
  function f(uint256 len) public pure {
    uint256[] memory a = new uint256[](7);
    bytes memory b = new bytes(len);
    assert(a.length == 7);
    assert(b.length == len);
    a[6] = 8;
  }
}

```

### 2.4 Array Literals

数组字面量是用方括号 ( `[…]` ) 括起来的一个或多个表达式的逗号分隔列表。例如 `[1, a, f(3)]` 。

数组字面量总是一个静态大小的内存数组，其长度为表达式的数量。

数组字面量的基类型是列表中第一个表达式的类型，这样所有其他表达式都可以隐式转换为它。如果转换不了，则为类型错误。

`[1, 2, 3]` 的类型为 `uint8[3] memory` ，如果你想要的结果是 `uint[3] memory` 类型，
你需要将第一个元素转换为 `uint` 类型，即 `[uint(1), 2, 3]` 。

`[1, -1]` 是无效的，因为 `uint8` 和 `int8` 之间不能相互隐式转换。若使其正确，可以使用 `[int8(1), -1]` 。

由于不同类型的固定大小内存数组不能相互转换，如果想使用二维数组字面量，则必须始终显式指定公共基类型：

```solidity
// SPDX-License-Identifier: GPL-3.0
pragma solidity >=0.4.16 <0.9.0;

contract C {
  function f() public pure returns (uint24[2][4] memory) {
    uint24[2][4] memory x = [
      [uint24(0x1), 1],
      [0xffffff, 2],
      [uint24(0xff), 3],
      [uint24(0xffff), 4]
    ];

    // 以下赋值将不起作用，因为一些内部数组的类型不对。
    // uint[2][4] memory x = [[0x1, 1], [0xffffff, 2], [0xff, 3], [0xffff, 4]];

    return x;
  }
}

```

不能将固定大小的内存数组分配给动态大小的内存数组：

```solidity
// SPDX-License-Identifier: GPL-3.0
pragma solidity >=0.4.0 <0.9.0;

// 这将无法编译
contract C {
  function f() public {
    // 下一行产生了一个类型错误
    uint256[] memory x = [uint256(1), 3, 4];
    // ^ error: uint256[3] memory 类型不能隐式转换为期望的 uint256[] memory 类型。
  }
}

```

如果要初始化动态大小的数组，则必须分配各个元素：

```solidity
// SPDX-License-Identifier: GPL-3.0
pragma solidity >=0.4.16 <0.9.0;

contract C {
  function f() public pure {
    uint256[] memory x = new uint256[](3);
    x[0] = 1;
    x[1] = 3;
    x[2] = 4;
  }
}

```

## 数组成员

- `length`
- `push()`
- `push(x)`
- `pop()`

## 3. Array Slices

## 4. Structs

## 5. Mapping Types
