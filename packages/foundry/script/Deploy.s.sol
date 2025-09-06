// script/Deploy.s.sol
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import "forge-std/Script.sol";
import "../contracts/PersonalVault/PersonalVaultFactory.sol";

contract Deploy is Script {
    function run() external {
        uint256 deployerPrivateKey = vm.envUint("PRIVATE_KEY");
        address deployer = vm.addr(deployerPrivateKey);
        
        console.log("Deployer:", deployer);
        console.log("Deployer balance:", deployer.balance);

        // Base Sepolia USDC address
        address usdcToken = vm.envAddress("USDC_ADDRESS");
        
        console.log("Using USDC:", usdcToken);

        vm.startBroadcast(deployerPrivateKey);

        // Deploy PersonalVaultFactory (no ENS parameters needed!)
        PersonalVaultFactory personalVaultFactory = new PersonalVaultFactory(usdcToken);

        console.log("PersonalVaultFactory deployed at:", address(personalVaultFactory));
        console.log("Implementation address:", personalVaultFactory.implementation());

        vm.stopBroadcast();
    }
}