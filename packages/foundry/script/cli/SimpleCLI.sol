// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import "forge-std/Script.sol";
import "forge-std/console.sol";
import "../../contracts/PersonalVault/PersonalVaultFactory.sol";

contract SimpleCLI is Script {
    function run() external {
        console.log("=== Simple SusuChain CLI ===");
        
        // Always deploy a new factory for testing
        vm.startBroadcast();
        
        address usdcAddress = address(0x1234567890123456789012345678901234567890);
        address registrarController = address(0x1111111111111111111111111111111111111111);
        address publicResolver = address(0x2222222222222222222222222222222222222222);
        
        PersonalVaultFactory factory = new PersonalVaultFactory(
            usdcAddress,
            registrarController,
            publicResolver
        );
        
        console.log("Factory deployed at:", address(factory));
        
        // Test creating a vault
        console.log("Creating test vault...");
        address vaultAddress = factory.createVault{value: 0.001 ether}(30 days, "testvault");
        console.log("Vault created at:", vaultAddress);
        
        // Test listing vaults
        address[] memory vaults = factory.getUserVaults(msg.sender);
        console.log("Number of vaults created:", vaults.length);
        
        vm.stopBroadcast();
        
        console.log("CLI test completed successfully!");
    }
}