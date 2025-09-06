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
        address ensRegistry = 0x4d3Cc9518A2E37E425a662796b0b6f06f09513B0; // ENS Registry on Base Sepolia
        address publicResolver = 0x8A1c15F111a4e931399E2D658da63F911aE95A52; // Public Resolver on Base Sepolia

        // Your domain information
        string memory parentName = "de-susu-demo.base.eth";
        bytes32 parentNamehash = 0x32bd44c64f61c0b474fc24a1a139e393fd8d26057ff7316a6fcefc27e9d32db0; // REPLACE THIS!

        console.log("Using Base Sepolia addresses:");
        console.log("USDC:", usdcToken);
        console.log("ENS Registry:", ensRegistry);
        console.log("Public Resolver:", publicResolver);
        console.log("Parent Domain:", parentName);

        // Deploy PersonalVaultFactory
        PersonalVaultFactory personalVaultFactory = new PersonalVaultFactory(
            usdcToken,
            ensRegistry,           // ENS Registry address
            publicResolver,        // Public Resolver address  
            parentName,            // Your domain name
            parentNamehash         // Namehash of your domain
        );

        console.log("PersonalVaultFactory deployed at:", address(personalVaultFactory));

        vm.stopBroadcast();
    }
}