// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

interface IAccessControl {
    function hasRole(bytes32 role, address account) external view returns (bool);

    function getRoleAdmin(bytes32 role) external view returns (bytes32);

    function grantRole(bytes32 role, address account) external;

    function revokeRole(bytes32 role, address account) external;

    function renounceRole(bytes32 role, address account) external;
}

/**
 * @title 访问控制
 */
abstract contract AccessControl is IAccessControl {
    /// @dev 角色数据结构
    struct RoleData {
        mapping(address => bool) members;
        bytes32 adminRole;
    }

    /// @dev 角色列表
    mapping(bytes32 => RoleData) private _roles;

    /// @dev 默认管理角色
    bytes32 public constant DEFAULT_ADMIN_ROLE = 0x00;

    /**
     * @dev [Event] 角色的管理角色改变时触发
     * @param role - 角色
     * @param previousAdminRole - 之前的管理角色
     * @param newAdminRole - 新的管理角色
     */
    event RoleAdminChanged(bytes32 indexed role, bytes32 indexed previousAdminRole, bytes32 indexed newAdminRole);

    /**
     * @dev [Event] 角色授权
     */
    event RoleGranted(bytes32 indexed role, address indexed account, address indexed sender);

    /**
     * @dev [Event] 角色撤销
     */
    event RoleRevoked(bytes32 indexed role, address indexed account, address indexed sender);

    /**
     * @dev [Modifier] 当前账户有指定角色
     */
    modifier onlyRole(bytes32 role) {
        _checkRole(role, msg.sender);
        _;
    }

    /**
     * @dev 若账户 account 被授予了 role 角色，则返回 true
     */
    function hasRole(bytes32 role, address account) public view override returns (bool) {
        return _roles[role].members[account];
    }

    /**
     * @dev 检查账户 account 是否被授予了 role 角色
     */
    function _checkRole(bytes32 role, address account) internal view {
        if (!hasRole(role, account)) {
            revert("account is missing role.");
        }
    }

    /**
     * @dev 获取指定 role 的管理角色
     */
    function getRoleAdmin(bytes32 role) public view override returns (bytes32) {
        return _roles[role].adminRole;
    }

    /**
     * @dev 角色授权
     */
    function grantRole(bytes32 role, address account) public virtual override onlyRole(getRoleAdmin(role)) {
        _grantRole(role, account);
    }

    /**
     * @dev 角色撤销
     */
    function revokeRole(bytes32 role, address account) public virtual override onlyRole(getRoleAdmin(role)) {
        _revokeRole(role, account);
    }

    /**
     * @dev 主动放弃指定 role
     *
     * - 提供一种机制，在账户安全受到威胁（比如可信任设备丢失）时可以主动撤销指定角色权限。
     */
    function renounceRole(bytes32 role, address account) public virtual override {
        require(account == msg.sender, "AccessControl: can only renounce roles for self");

        _revokeRole(role, account);
    }

    /**
     * @dev [内部可覆盖] 给指定 account 授予指定 role
     *
     * - 如果 account 尚未被授予 role 则触发 RoleGranted 事件。
     * - 与 grantRole(role, account) 函数不同的是，此函数不会对调用账户执行任何检查。
     * - 此函数只应该在为系统设置初始角色时从构造函数调用。
     * - 以任何其他方式使用此函数都可以有效的绕过 AccessContrl 施加的管理系统。
     */
    function _setupRole(bytes32 role, address account) internal virtual {
        _grantRole(role, account);
    }

    /**
     * @dev [内部可覆盖] 设置指定角色 role 的管理角色 adminRole
     */
    function _setRoleAdmin(bytes32 role, bytes32 adminRole) internal virtual {
        emit RoleAdminChanged(role, getRoleAdmin(role), adminRole);
        _roles[role].adminRole = adminRole;
    }

    /**
     * @dev [私有] 将 role 授予指定 account
     */
    function _grantRole(bytes32 role, address account) private {
        if (!hasRole(role, account)) {
            _roles[role].members[account] = true;
            emit RoleGranted(role, account, msg.sender);
        }
    }

    /**
     * @dev [私有] 将 account 从指定 role 中移除
     */
    function _revokeRole(bytes32 role, address account) private {
        if (hasRole(role, account)) {
            _roles[role].members[account] = false;
            emit RoleRevoked(role, account, msg.sender);
        }
    }
}
