// SPDX-License-Identifier: MIT
pragma solidity >=0.4.25 <0.9.0;

library ConvertLib {
    /**
     * @notice 数值转换
     * @param amount - 数值
     * @param conversionRate - 转换率
     */
    function convert(uint256 amount, uint256 conversionRate) public pure returns (uint256 convertedAmount) {
        return amount * conversionRate;
    }
}
