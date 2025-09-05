// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

// Interface for L2PublicResolver (standard ENS resolver)
interface IPublicResolver {
    function setAddr(bytes32 node, address addr) external;
    function setName(bytes32 node, string calldata newName) external;
    function setText(bytes32 node, string calldata key, string calldata value) external;
}