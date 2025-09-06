// // script/deploy/DeploySusuChain.s.sol
// // SPDX-License-Identifier: MIT
// pragma solidity ^0.8.19;

// import "forge-std/Script.sol";
// import "../../contracts/GroupPool/GroupPoolFactory.sol";
// import "../utils/MockContracts.sol";

// contract DeploySusuChain is Script {
//     function run() external {
//         vm.startBroadcast();
        
//         // Get mock contract addresses (deploy them first)
//         address usdc = vm.envAddress("MOCK_USDC");
//         address registrar = vm.envAddress("MOCK_REGISTRAR");
//         address resolver = vm.envAddress("MOCK_RESOLVER");
        
//         // Deploy GroupPoolFactory
//         GroupPoolFactory factory = new GroupPoolFactory(usdc, msg.sender);
        
//         // Update factory with mock addresses
//         factory.updateRegistrarController(registrar);
//         factory.updatePublicResolver(resolver);
        
//         console.log("GroupPoolFactory deployed at:", address(factory));
        
//         vm.stopBroadcast();
//     }
// }