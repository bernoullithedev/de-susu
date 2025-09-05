// script/deploy/DeployMocks.s.sol
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import "forge-std/Script.sol";
import "../utils/MockContracts.sol";

contract DeployMocks is Script {
    function run() external {
        vm.startBroadcast();
        
        // Deploy mock contracts
        MockUSDC usdc = new MockUSDC();
        MockRegistrarController registrar = new MockRegistrarController();
        MockPublicResolver resolver = new MockPublicResolver();
        
        // Log addresses for easy access
        console.log("MockUSDC deployed at:", address(usdc));
        console.log("MockRegistrarController deployed at:", address(registrar));
        console.log("MockPublicResolver deployed at:", address(resolver));
        
        vm.stopBroadcast();
    }
}