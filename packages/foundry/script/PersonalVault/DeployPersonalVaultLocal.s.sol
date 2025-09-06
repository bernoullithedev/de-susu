// // SPDX-License-Identifier: MIT
// pragma solidity ^0.8.19;

// import "forge-std/Script.sol";
// import "../../contracts/PersonalVault/PersonalVaultFactory.sol";

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

// contract DeployPersonalVaultLocal is Script {
//     function run() external {
//         // Use mock addresses for local testing
//         address usdcAddress = address(0x1234567890123456789012345678901234567890);
//         MockRegistrarController registrar = new MockRegistrarController();
//         MockPublicResolver resolver = new MockPublicResolver();
        
//         console.log("Deploying PersonalVaultFactory with mock addresses:");
//         console.log("USDC:", usdcAddress);
//         console.log("Registrar:", address(registrar));
//         console.log("Resolver:", address(resolver));
        
//         vm.startBroadcast();
        
//         PersonalVaultFactory factory = new PersonalVaultFactory(
//             usdcAddress,
//             address(registrar),
//             address(resolver)
//         );
        
//         vm.stopBroadcast();
        
//         console.log("PersonalVaultFactory deployed at:", address(factory));
//         console.log("Local deployment successful! Use this for testing only.");
//     }
// }