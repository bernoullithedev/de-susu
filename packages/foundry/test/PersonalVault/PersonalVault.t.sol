// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import "forge-std/Test.sol";
import "../../contracts/PersonalVault/PersonalVault.sol";
import "../../contracts/PersonalVault/PersonalVaultFactory.sol";
import "solmate/tokens/ERC20.sol";

// Mock contracts for testing
contract MockRegistrarController {
    function available(string calldata) external pure returns (bool) { return true; }
    function rentPrice(string calldata, uint256) external pure returns (uint256) { return 0.001 ether; }
    function register(string calldata, address, uint256, address, bytes[] calldata, bool) external payable {}
}

contract MockPublicResolver {
    function setAddr(bytes32, address) external {}
    function setName(bytes32, string calldata) external {}
    function setText(bytes32, string calldata, string calldata) external {}
}

// Mock USDC contract for testing
contract MockUSDC is ERC20 {
    constructor() ERC20("USD Coin", "USDC", 6) {}
    
    function mint(address to, uint256 amount) public {
        _mint(to, amount);
    }
}

contract PersonalVaultTest is Test {
    PersonalVaultFactory factory;
    MockUSDC usdc;
    MockRegistrarController registrar;
    MockPublicResolver resolver;
    address user = address(0x123);
    address user2 = address(0x456);
    
    function setUp() public {
        usdc = new MockUSDC();
        registrar = new MockRegistrarController();
        resolver = new MockPublicResolver();
        
        factory = new PersonalVaultFactory(
            address(usdc),
            address(registrar),
            address(resolver)
        );
        
        // Mint some USDC to users
        usdc.mint(user, 1000 * 10**6);
        usdc.mint(user2, 1000 * 10**6);
        
        // Fund users with ETH for registration fees
        vm.deal(user, 1 ether);
        vm.deal(user2, 1 ether);
    }
    
    function testCreateVault() public {
        vm.prank(user);
        address vaultAddress = factory.createVault{value: 0.001 ether}(30 days, "testvault");
        
        assertTrue(vaultAddress != address(0), "Vault should be created");
        
        address[] memory userVaults = factory.getUserVaults(user);
        assertEq(userVaults.length, 1, "User should have one vault");
        assertEq(userVaults[0], vaultAddress, "Vault address should match");
    }
    
    function testDeposit() public {
        vm.prank(user);
        address vaultAddress = factory.createVault{value: 0.001 ether}(30 days, "depositvault");
        PersonalVault vault = PersonalVault(vaultAddress);
        
        // Approve vault to spend USDC
        vm.prank(user);
        usdc.approve(vaultAddress, 100 * 10**6);
        
        // Deposit
        vm.prank(user);
        vault.deposit(50 * 10**6);
        
        assertEq(vault.getBalance(), 50 * 10**6, "Vault should have 50 USDC");
    }
    
    function testEarlyWithdrawalFails() public {
        vm.prank(user);
        address vaultAddress = factory.createVault{value: 0.001 ether}(30 days, "earlyvault");
        PersonalVault vault = PersonalVault(vaultAddress);
        
        // Approve and deposit
        vm.prank(user);
        usdc.approve(vaultAddress, 100 * 10**6);
        vm.prank(user);
        vault.deposit(100 * 10**6);
        
        // Try to withdraw early (should revert)
        vm.prank(user);
        vm.expectRevert("Funds are locked until maturity");
        vault.withdraw();
    }
    
    function testOnTimeWithdrawal() public {
        vm.prank(user);
        address vaultAddress = factory.createVault{value: 0.001 ether}(1 days, "ontimevault");
        PersonalVault vault = PersonalVault(vaultAddress);
        
        // Approve and deposit
        vm.prank(user);
        usdc.approve(vaultAddress, 100 * 10**6);
        vm.prank(user);
        vault.deposit(100 * 10**6);
        
        // Fast forward time past lock period
        vm.warp(block.timestamp + 2 days);
        
        // Withdraw after lock period
        vm.prank(user);
        vault.withdraw();
        
        // Should have full amount back (no penalty)
        assertEq(usdc.balanceOf(user), 1000 * 10**6, "User should have all USDC back");
        assertEq(vault.getBalance(), 0, "Vault should be empty after withdrawal");
    }
    
    function testNotOwnerCannotWithdraw() public {
        vm.prank(user);
        address vaultAddress = factory.createVault{value: 0.001 ether}(30 days, "securityvault");
        PersonalVault vault = PersonalVault(vaultAddress);
        
        // Approve and deposit
        vm.prank(user);
        usdc.approve(vaultAddress, 100 * 10**6);
        vm.prank(user);
        vault.deposit(100 * 10**6);
        
        // Try to withdraw as different user
        vm.prank(user2);
        vm.expectRevert("Not owner");
        vault.withdraw();
    }
    
    function testVaultMaturityFunctions() public {
        vm.prank(user);
        address vaultAddress = factory.createVault{value: 0.001 ether}(7 days, "maturityvault");
        PersonalVault vault = PersonalVault(vaultAddress);
        
        // Check maturity functions
        assertFalse(vault.isMature(), "Vault should not be mature initially");
        assertTrue(vault.timeUntilMaturity() > 0, "Should have time until maturity");
        
        // Fast forward to maturity
        vm.warp(block.timestamp + 7 days);
        
        assertTrue(vault.isMature(), "Vault should be mature after lock period");
        assertEq(vault.timeUntilMaturity(), 0, "No time should remain until maturity");
    }
    
    function testMultipleVaultsPerUser() public {
        vm.prank(user);
        address vault1 = factory.createVault{value: 0.001 ether}(30 days, "vault1");
        
        vm.prank(user);
        address vault2 = factory.createVault{value: 0.001 ether}(60 days, "vault2");
        
        address[] memory userVaults = factory.getUserVaults(user);
        assertEq(userVaults.length, 2, "User should have 2 vaults");
        assertEq(userVaults[0], vault1, "First vault should match");
        assertEq(userVaults[1], vault2, "Second vault should match");
    }
}