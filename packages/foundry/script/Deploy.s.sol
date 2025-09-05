// script/Deploy.s.sol
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import "forge-std/Script.sol";
import "../contracts/GroupPool/GroupPoolFactory.sol";
import "../contracts/PersonalVault/PersonalVaultFactory.sol";
import "./utils/MockContracts.sol";

contract Deploy is Script {
    function run() external {
        vm.startBroadcast();

        // For local development, deploy mocks first
        MockUSDC usdc = new MockUSDC();
        MockRegistrarController registrar = new MockRegistrarController();
        MockPublicResolver resolver = new MockPublicResolver();

        console.log("Mock contracts deployed:");
        console.log("USDC:", address(usdc));
        console.log("Registrar:", address(registrar));
        console.log("Resolver:", address(resolver));

        // Deploy GroupPoolFactory
        GroupPoolFactory groupPoolFactory = new GroupPoolFactory(
            address(usdc),
            tx.origin,
            address(registrar),
            address(resolver)
        );

        console.log("GroupPoolFactory deployed at:", address(groupPoolFactory));

        // Deploy PersonalVaultFactory
        PersonalVaultFactory personalVaultFactory = new PersonalVaultFactory(
            address(usdc),
            address(registrar),
            address(resolver)
        );

        console.log("PersonalVaultFactory deployed at:", address(personalVaultFactory));

        vm.stopBroadcast();
    }
}
