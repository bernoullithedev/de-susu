// script/Deploy.s.sol
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import "forge-std/Script.sol";
import "../contracts/GroupPool/GroupPoolFactory.sol";
import "../contracts/PersonalVault/PersonalVaultFactory.sol";

contract Deploy is Script {
    function run() external {
        vm.startBroadcast();

        // Base Sepolia contract addresses
        address usdcToken = 0x036CbD53842c5426634e7929541eC2318f3dCF7e; // USDC on Base Sepolia
        address registrarController = 0x49aE3cC2e3AA768B1e5654f5D3C6002144A59581; // Basenames Registrar
        address publicResolver = 0x85C87e548091f204C2d0350b39ce1874f02197c6; // Basenames Resolver

        console.log("Using Base Sepolia addresses:");
        console.log("USDC:", usdcToken);
        console.log("Registrar Controller:", registrarController);
        console.log("Public Resolver:", publicResolver);

        // Deploy GroupPoolFactory
        GroupPoolFactory groupPoolFactory = new GroupPoolFactory(
            usdcToken,
            tx.origin,
            registrarController,
            publicResolver
        );

        console.log("GroupPoolFactory deployed at:", address(groupPoolFactory));

        // Deploy PersonalVaultFactory
        PersonalVaultFactory personalVaultFactory = new PersonalVaultFactory(
            usdcToken,
            registrarController,
            publicResolver
        );

        console.log("PersonalVaultFactory deployed at:", address(personalVaultFactory));

        vm.stopBroadcast();
    }
}
