// // SPDX-License-Identifier: MIT
// pragma solidity ^0.8.19;

// import "forge-std/Script.sol";
// import "../../contracts/PersonalVault/PersonalVaultFactory.sol";

// contract DeployPersonalVault is Script {
//     function run() external {
//         address usdcAddress = vm.envAddress("USDC_ADDRESS");
//         address registrarController = vm.envAddress("REGISTRAR_CONTROLLER");
//         address publicResolver = vm.envAddress("PUBLIC_RESOLVER");
        
//         // For Base Sepolia deployment
//         vm.startBroadcast();
        
//         PersonalVaultFactory factory = new PersonalVaultFactory(
//             usdcAddress,
//             registrarController,
//             publicResolver
//         );
        
//         vm.stopBroadcast();
        
//         console.log("PersonalVaultFactory deployed at:", address(factory));
//     }
// }