// // SPDX-License-Identifier: MIT
// pragma solidity ^0.8.19;

// import "forge-std/Script.sol";
// import "../../contracts/GroupPool/GroupPoolFactory.sol";

// contract DeployToBaseSepolia is Script {
//     // Base Sepolia Addresses (Official)
//     address constant USDC_ADDRESS = 0x036CbD53842c5426634e7929541eC2318f3dCF7e;
//     address constant REGISTRAR_CONTROLLER = 0x4Ff5C61A5a2896a8419E7E5C9c355C169C0B46c2;
//     address constant PUBLIC_RESOLVER = 0x51464C87a2E7026FF7E783cf4ef7B9a1aE966D81;

//     function run() external {
//         // Load private key from .env
//         uint256 deployerPrivateKey = vm.envUint("PRIVATE_KEY");
//         address deployerAddress = vm.addr(deployerPrivateKey);
        
//         console.log("Deploying from: ", deployerAddress);
//         console.log("Using USDC address: ", USDC_ADDRESS);
//         console.log("Using Registrar Controller: ", REGISTRAR_CONTROLLER);
//         console.log("Using Public Resolver: ", PUBLIC_RESOLVER);

//         vm.startBroadcast(deployerPrivateKey);

//         // Deploy the Factory - make the deployer the owner
//         GroupPoolFactory factory = new GroupPoolFactory(USDC_ADDRESS, deployerAddress);
        
//         // Configure it with the real Base Sepolia addresses
//         factory.updateRegistrarController(REGISTRAR_CONTROLLER);
//         factory.updatePublicResolver(PUBLIC_RESOLVER);

//         console.log("GroupPoolFactory deployed at: ", address(factory));

//         vm.stopBroadcast();
//     }
// }