// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

/**
 * @dev 在 EIP 中定义的 ERC20 标准接口
 */
interface IERC20 {
    /**
     * @dev 返回代币总量
     */
    function totalSupply() external view returns (uint256);

    /**
     * @dev 查询指定账户余额
     */
    function balanceOf(address account) external view returns (uint256);

    /**
     * @dev 向指定账户转账，转账成功返回 true 并触发 {Transfer} 事件
     */
    function transfer(address recipient, uint256 amount) external returns (bool);

    /**
     * @dev 查询授权的 transferFrom() 可用余额，调用 approve() 或者 transferFrom() 方法余额值将变化
     */
    function allowance(address owner, address spender) external view returns (uint256);

    /**
     * @dev 授权指定账户可转账的金额， 操作成功返回 true 并触发 {Approval} 事件
     */
    function approve(address spender, uint256 amount) external returns (bool);

    /**
     * @dev 在授权的限额范围内，将授权账户的一定数量代币转给目标账户，操作成功返回 true 并触发 {Transfer} 事件
     */
    function transferFrom(
        address sender,
        address recipient,
        uint256 amount
    ) external returns (bool);

    /**
     * @dev [Event] 转账成功时触发，转账金额可为零
     * @param value - 转账金额
     */
    event Transfer(address indexed from, address indexed to, uint256 value);

    /**
     * @dev [Event] 授权操作成功时触发
     * @param value - 授权的金额
     */
    event Approval(address indexed owner, address indexed spender, uint256 value);
}
