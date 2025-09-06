// // SPDX-License-Identifier: MIT
// pragma solidity ^0.8.19;

// import "forge-std/Script.sol";
// import "forge-std/console.sol";
// import "../contracts/PersonalVault/PersonalVaultFactory.sol";
// import "../contracts/PersonalVault/PersonalVault.sol";

// // Mock contracts for local testing
// contract MockRegistrarController {
//     function available(string calldata) external pure returns (bool) { return true; }
//     function rentPrice(string calldata, uint256) external pure returns (uint256) { return 0.001 ether; }
//     function register(string calldata, address, uint256, address, bytes[] calldata, bool) external payable {}
// }

// contract MockPublicResolver {
//     function setAddr(bytes32, address) external {}
//     function setName(bytes32, string calldata) external {}
//     function setText(bytes32, string calldata, string calldata) external {}
// }

// contract DemoCLI is Script {
//     PersonalVaultFactory public factory;
    
//     function run() external {
//         console.log("=== SusuChain Demo CLI ===");
        
//         // Deploy everything fresh
//         vm.startBroadcast();
        
//         // Deploy mocks
//         MockRegistrarController registrar = new MockRegistrarController();
//         MockPublicResolver resolver = new MockPublicResolver();
//         address usdcAddress = address(0x1234567890123456789012345678901234567890);
        
//         // Deploy factory
//         factory = new PersonalVaultFactory(
//             usdcAddress,
//             address(registrar),
//             address(resolver)
//         );
        
//         console.log("Factory deployed at:", address(factory));
        
//         // Demo the complete workflow
//         console.log("\n1. Creating vaults...");
//         demoCreateVaults();
        
//         console.log("\n2. Listing vaults...");
//         demoListVaults();
        
//         console.log("\n3. Checking vault status...");
//         demoCheckVaults();
        
//         vm.stopBroadcast();
        
//         console.log("\n=== Demo Completed Successfully! ===");
//         console.log("Your PersonalVault system is ready for use!");
//     }
    
//     function demoCreateVaults() internal {
//         // Create multiple vaults with different parameters
//         address vault1 = factory.createVault{value: 0.001 ether}(30 days, "short-term");
//         console.log("Created 30-day vault:", vault1);
        
//         address vault2 = factory.createVault{value: 0.001 ether}(90 days, "medium-term");
//         console.log("Created 90-day vault:", vault2);
        
//         address vault3 = factory.createVault{value: 0.001 ether}(365 days, "long-term");
//         console.log("Created 365-day vault:", vault3);
//     }
    
//     function demoListVaults() internal view {
//         address[] memory vaults = factory.getUserVaults(msg.sender);
//         console.log("You have", vaults.length, "vault(s):");
        
//         for (uint256 i = 0; i < vaults.length; i++) {
//             PersonalVault vault = PersonalVault(vaults[i]);
//             console.log(i + 1, "-", vaults[i]);
//             console.log("  ENS Name:", vault.vaultENSName());
//             console.log("  Lock Duration:", vault.lockDuration() / 1 days, "days");
//         }
//     }
    
//     function demoCheckVaults() internal view {
//         address[] memory vaults = factory.getUserVaults(msg.sender);
        
//         for (uint256 i = 0; i < vaults.length; i++) {
//             PersonalVault vault = PersonalVault(vaults[i]);
            
//             console.log("\nVault", i + 1, "Details:");
//             console.log("  Address:", vaults[i]);
//             console.log("  Owner:", vault.owner());
//             console.log("  Lock Duration:", vault.lockDuration() / 1 days, "days");
//             console.log("  Created:", vault.createdAt());
//             console.log("  Matures at:", vault.getLockEndTime());
//             console.log("  Is Mature:", vault.isMature());
            
//             if (!vault.isMature()) {
//                 console.log("  Time until maturity:", vault.timeUntilMaturity() / 1 days, "days");
//             }
//         }
//     }
// }