// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

/**
 * @title 可暂停
 *
 * @dev 该合约模块实现可有授权账户触发的紧急停止机制
 * - 该合约通过继承来使用
 * - 该合约提供 whenNotPaused 和 whenPaused 修饰符，可以将其应用到你的合约函数上。
 */
abstract contract Pausable {
    /**
     * @dev [Evnet] 当账户 account 触发暂停时触发
     */
    event Paused(address account);

    /**
     * @dev [Event] 当账户 account 解除暂停时触发
     */
    event Unpaused(address account);

    /**
     * @dev 暂停状态
     */
    bool private _paused;

    /**
     * @dev 以未暂停状态初始化合约
     */
    constructor() {
        _paused = false;
    }

    /**
     * @dev [Getter] 暂停状态
     *
     * - 若合约被暂停，则返回 true ，否则返回 false
     */
    function paused() public view virtual returns (bool) {
        return _paused;
    }

    /**
     * @dev [Modifier] 使函数仅在合约未暂停时可调用
     */
    modifier whenNotPaused() {
        require(!paused(), "Pausable: paused");
        _;
    }

    /**
     * @dev [Modifier] 使函数仅在合约暂停时可调用
     */
    modifier whenPaused() {
        require(paused(), "Pausable: not paused");
        _;
    }

    /**
     * @dev [内部可覆盖] 将合约设为暂停状态
     */
    function _pause() internal virtual whenNotPaused {
        _paused = true;
        emit Paused(msg.sender);
    }

    /**
     * @dev [内部可覆盖] 将合约恢复正常正常状态
     */
    function _unpause() internal virtual whenPaused {
        _paused = false;
        emit Unpaused(msg.sender);
    }
}
