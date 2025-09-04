// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

interface IRegistrarController {
    function available(string calldata name) external view returns (bool);
    function rentPrice(string calldata name, uint256 duration) external view returns (uint256);
    function register(
        string calldata name,
        address owner,
        uint256 duration,
        address resolver,
        bytes[] calldata data,
        bool reverseRecord
    ) external payable;
}