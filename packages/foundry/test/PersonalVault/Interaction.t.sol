// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import "forge-std/Test.sol";
import "../../contracts/PersonalVault/PersonalVaultFactory.sol";
import "../../contracts/PersonalVault/PersonalVault.sol";
import "solmate/tokens/ERC20.sol";

// Properly implemented mock registrar
contract MockRegistrarController {
    function available(string calldata) external pure returns (bool) { 
        return true; 
    }
    
    function rentPrice(string calldata, uint256) external pure returns (uint256) { 
        return 0.001 ether; 
    }
    
    function register(
        string calldata,
        address,
        uint256,
        address,
        bytes[] calldata,
        bool
    ) external payable {
        // Just accept the payment and do nothing
        // This is the minimal gas consumption
    }
}

// Properly implemented mock resolver with correct function signatures
contract MockPublicResolver {
    // Track some state to make it a proper contract (not empty)
    mapping(bytes32 => mapping(string => string)) public textRecords;
    mapping(bytes32 => address) public addrRecords;
    mapping(bytes32 => string) public nameRecords;
    
    function setAddr(bytes32 node, address _addr) external {
        addrRecords[node] = _addr;
    }
    
    function setName(bytes32 node, string calldata _name) external {
        nameRecords[node] = _name;
    }
    
    function setText(bytes32 node, string calldata key, string calldata value) external {
        textRecords[node][key] = value;
    }
    
    // Add minimal implementations of view functions that might be called
    function addr(bytes32 node) external view returns (address) {
        return addrRecords[node];
    }
    
    function name(bytes32 node) external view returns (string memory) {
        return nameRecords[node];
    }
    
    function text(bytes32 node, string calldata key) external view returns (string memory) {
        return textRecords[node][key];
    }
}

contract MockUSDC is ERC20 {
    constructor() ERC20("USD Coin", "USDC", 6) {}
    function mint(address to, uint256 amount) public { _mint(to, amount); }
}

contract PersonalVaultInteractionTest is Test {
    PersonalVaultFactory factory;
    MockUSDC usdc;
    MockRegistrarController registrar;
    MockPublicResolver resolver;
    address user1 = address(0x123);
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
        
        // Fund users with ETH as well for gas
        vm.deal(user1, 10 ether);
        vm.deal(user2, 10 ether);
        
        // Fund users with USDC
        usdc.mint(user1, 1000 * 10**6);
        usdc.mint(user2, 1000 * 10**6);
    }
    
    // Test 1: Factory creates functional vaults
    function testFactoryCreatesWorkingVault() public {
        vm.prank(user1);
        address vaultAddress = factory.createVault{value: 0.001 ether}(30 days, "testvault");
        
        PersonalVault vault = PersonalVault(vaultAddress);
        assertEq(vault.owner(), user1, "Vault owner should be user1");
        assertEq(vault.getBalance(), 0, "New vault should have 0 balance");
    }
    
    // Test 2: Multiple users can create vaults
    function testMultipleUsersCreateVaults() public {
        vm.prank(user1);
        address vault1 = factory.createVault{value: 0.001 ether}(30 days, "vault1");
        
        vm.prank(user2);
        address vault2 = factory.createVault{value: 0.001 ether}(60 days, "vault2");
        
        assertTrue(vault1 != vault2, "Vault addresses should be different");
        assertTrue(vault1 != address(0), "Vault1 should not be zero address");
        assertTrue(vault2 != address(0), "Vault2 should not be zero address");
    }
    
    // Test 3: Full workflow - create, deposit, withdraw (after maturity)
    function testFullVaultWorkflow() public {
        vm.prank(user1);
        address vaultAddress = factory.createVault{value: 0.001 ether}(1 days, "workflowvault");
        
        PersonalVault vault = PersonalVault(vaultAddress);
        
        // Deposit
        vm.prank(user1);
        usdc.approve(vaultAddress, 100 * 10**6);
        vm.prank(user1);
        vault.deposit(100 * 10**6);
        
        assertEq(vault.getBalance(), 100 * 10**6, "Vault should have 100 USDC");
        
        // Fast forward to after maturity
        vm.warp(block.timestamp + 2 days);
        
        // Withdraw after maturity (should get full amount, no penalty)
        vm.prank(user1);
        vault.withdraw();
        
        // User started with 1000, deposited 100, received back 100 (no penalty)
        assertEq(usdc.balanceOf(user1), 1000 * 10**6, "User should have all funds back after maturity");
    }
    
    // Test 4: Gas usage estimation
    function testGasUsage() public {
        vm.prank(user1);
        uint256 gasBefore = gasleft();
        factory.createVault{value: 0.001 ether}(30 days, "gasvault");
        uint256 gasUsed = gasBefore - gasleft();
        
        console.log("Gas used for vault creation:", gasUsed);
        
        // This helps estimate real deployment costs
        assertTrue(gasUsed < 1000000, "Vault creation should be gas efficient");
    }
    
    // Test 5: Factory tracking
    function testFactoryTracking() public {
        vm.prank(user1);
        address vault1 = factory.createVault{value: 0.001 ether}(30 days, "tracking1");
        
        vm.prank(user1);
        address vault2 = factory.createVault{value: 0.001 ether}(60 days, "tracking2");
        
        address[] memory userVaults = factory.getUserVaults(user1);
        assertEq(userVaults.length, 2, "User should have 2 vaults");
        assertEq(userVaults[0], vault1, "First vault should match");
        assertEq(userVaults[1], vault2, "Second vault should match");
    }
    
    // Test 6: Try early withdrawal (should fail)
    function testEarlyWithdrawalFails() public {
        vm.prank(user1);
        address vaultAddress = factory.createVault{value: 0.001 ether}(7 days, "earlyvault");
        
        PersonalVault vault = PersonalVault(vaultAddress);
        
        // Deposit
        vm.prank(user1);
        usdc.approve(vaultAddress, 100 * 10**6);
        vm.prank(user1);
        vault.deposit(100 * 10**6);
        
        // Try to withdraw early (should revert)
        vm.prank(user1);
        vm.expectRevert("Funds are locked until maturity");
        vault.withdraw();
    }
}