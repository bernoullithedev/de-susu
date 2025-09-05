// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

interface IPublicResolver {
    function setAddr(bytes32 node, address addr) external;
    function setName(bytes32 node, string calldata name) external;
    function setText(bytes32 node, string calldata key, string calldata value) external;
    function text(bytes32 node, string calldata key) external view returns (string memory);
    function addr(bytes32 node) external view returns (address);
}