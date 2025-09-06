// // SPDX-License-Identifier: MIT
// pragma solidity ^0.8.19;

// import "forge-std/Script.sol";
// import "forge-std/console.sol";
// import "../contracts/PersonalVault/PersonalVaultFactory.sol";
// import "../contracts/PersonalVault/PersonalVault.sol";

// // Proper mock contracts
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

// contract TestWorkflow is Script {
//     function run() external {
//         console.log("=== Testing PersonalVault Workflow ===");
        
//         vm.startBroadcast();
        
//         // Deploy proper mock contracts
//         MockRegistrarController registrar = new MockRegistrarController();
//         MockPublicResolver resolver = new MockPublicResolver();
//         address usdcAddress = address(0x1234567890123456789012345678901234567890);
        
//         console.log("Deploying mock contracts...");
//         console.log("Registrar:", address(registrar));
//         console.log("Resolver:", address(resolver));
        
//         // Deploy factory with proper mock addresses
//         PersonalVaultFactory factory = new PersonalVaultFactory(
//             usdcAddress,
//             address(registrar),
//             address(resolver)
//         );
        
//         console.log("Factory deployed at:", address(factory));
        
//         // Test creating a vault
//         console.log("Creating test vault...");
//         address vaultAddress = factory.createVault{value: 0.001 ether}(30 days, "testvault");
//         console.log("Vault created at:", vaultAddress);
        
//         // Test vault functionality
//         PersonalVault vault = PersonalVault(vaultAddress);
//         console.log("Vault owner:", vault.owner());
//         console.log("Vault balance:", vault.getBalance());
//         console.log("Vault mature:", vault.isMature());
        
//         // Test factory tracking
//         address[] memory userVaults = factory.getUserVaults(msg.sender);
//         console.log("Number of user vaults:", userVaults.length);
        
//         vm.stopBroadcast();
        
//         console.log("=== Workflow Test Completed Successfully! ===");
//     }
// }