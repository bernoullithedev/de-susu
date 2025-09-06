// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import "forge-std/Test.sol";
import "forge-std/console.sol"; // For debugging
import "../../contracts/PersonalVault/PersonalVaultFactory.sol";
import "../../contracts/PersonalVault/PersonalVault.sol";
import "../../contracts/PersonalVault/interfaces/IPublicResolver.sol";
import "solmate/tokens/ERC20.sol";

/**
 * @title A fully functional mock of the Basenames RegistrarController
 * @dev This mock correctly processes the registration data, calling the resolver.
 * It simulates the actual behavior on Base Sepolia.
 * Based on the interface from the Base documentation: https://docs.base.org/docs/guides/ens/basenames
 */
contract MockRegistrarController {
    MockPublicResolver public immutable resolver;
    mapping(string => bool) public registeredNames;
    uint256 public constant REGISTRATION_PRICE = 0.001 ether;

    event NameRegistered(string indexed name, address owner, uint256 duration, address resolver);

    constructor(address _resolver) {
        resolver = MockPublicResolver(_resolver);
    }

    function available(string calldata name) external view returns (bool) {
        // Check if name is already registered
        return !registeredNames[name];
    }

    function rentPrice(string calldata, uint256) external pure returns (uint256) {
        return REGISTRATION_PRICE;
    }

    function register(
        string calldata name,
        address owner,
        uint256 duration,
        address resolverAddress,
        bytes[] calldata data,
        bool reverseRecord
    ) external payable {
        require(msg.value >= REGISTRATION_PRICE, "Insufficient fee");
        require(!registeredNames[name], "Name already registered");
        require(resolverAddress == address(resolver), "Unknown resolver");

        registeredNames[name] = true;

        // This is the crucial part: process the resolver data calls
        // This mimics exactly what the real RegistrarController does
        for (uint256 i = 0; i < data.length; i++) {
            (bool success, ) = resolverAddress.call(data[i]);
            require(success, "Resolver call failed");
        }

        emit NameRegistered(name, owner, duration, resolverAddress);
    }
}

/**
 * @title A comprehensive mock of the L2PublicResolver
 * @dev Implements the key functions for setting and getting ENS records.
 * Mirrors the actual resolver on Base Sepolia: 0x85c87E548091F204c2d0350B39Ce1874f02197c6
 * Interface reference: https://docs.ens.domains/contract-api-reference/publicresolver
 */
contract MockPublicResolver is IPublicResolver {
    // Storage for ENS records
    mapping(bytes32 => address) public addrs;
    mapping(bytes32 => string) public names;
    mapping(bytes32 => mapping(string => string)) public texts;

    event AddrSet(bytes32 indexed node, address a);
    event NameSet(bytes32 indexed node, string name);
    event TextSet(bytes32 indexed node, string indexed key, string value);

    function setAddr(bytes32 node, address addr) external override {
        addrs[node] = addr;
        emit AddrSet(node, addr);
    }
    
    function setName(bytes32 node, string calldata name) external override {
        names[node] = name;
        emit NameSet(node, name);
    }
    
    function setText(bytes32 node, string calldata key, string calldata value) external override {
        texts[node][key] = value;
        emit TextSet(node, key, value);
    }

    // Additional view functions for testing
    function addr(bytes32 node) external view returns (address) {
        return addrs[node];
    }
    
    function name(bytes32 node) external view returns (string memory) {
        return names[node];
    }
    
    function text(bytes32 node, string calldata key) external view returns (string memory) {
        return texts[node][key];
    }
}

contract MockUSDC is ERC20 {
    constructor() ERC20("USD Coin", "USDC", 6) {}
    function mint(address to, uint256 amount) public { _mint(to, amount); }
}

/**
 * @title PersonalVaultTest
 * @dev Comprehensive test suite for PersonalVault and PersonalVaultFactory
 * Tests all functionality including ENS integration, access control, and financial logic
 */
contract PersonalVaultTest is Test {
    PersonalVaultFactory public factory;
    MockUSDC public usdc;
    MockRegistrarController public registrar;
    MockPublicResolver public resolver;
    
    address public user1 = address(0x123);
    address public user2 = address(0x456);
    
    uint256 public constant REGISTRATION_FEE = 0.001 ether;

    function setUp() public {
        // Deploy in correct order: Resolver -> Registrar -> Factory
        usdc = new MockUSDC();
        resolver = new MockPublicResolver();
        registrar = new MockRegistrarController(address(resolver));
        
        factory = new PersonalVaultFactory(
            address(usdc),
            address(registrar),
            address(resolver)
        );
        
        // Fund users
        vm.deal(user1, 10 ether);
        vm.deal(user2, 10 ether);
        usdc.mint(user1, 1000 * 10**6);
        usdc.mint(user2, 1000 * 10**6);
    }

    // Helper function to compute ENS node hash
    // Reference: https://docs.ens.domains/contract-api-reference/name-processing#hashing-names
    function getEnsNode(string memory label) public pure returns (bytes32) {
        bytes32 baseNode = keccak256(abi.encodePacked("base.eth"));
        bytes32 labelHash = keccak256(abi.encodePacked(label));
        return keccak256(abi.encodePacked(baseNode, labelHash));
    }

    // Test 1: Complete Vault Creation with ENS Registration
    function test_VaultCreationWithENS() public {
        vm.prank(user1);
        address vaultAddress = factory.createVault{value: REGISTRATION_FEE}(30 days, "myvault");
        
        PersonalVault vault = PersonalVault(vaultAddress);
        
        // Verify vault properties
        assertEq(vault.owner(), user1, "Vault owner should be user1");
        assertEq(vault.getBalance(), 0, "New vault should have 0 balance");
        assertFalse(vault.isMature(), "New vault should not be mature");

        // Verify ENS registration was successful
        bytes32 node = getEnsNode("myvault");
        
        // Check addr record points to the vault
        assertEq(resolver.addr(node), vaultAddress, "ENS addr record should point to vault");
        
        // Check name record is correct
        assertEq(resolver.name(node), "myvault.base.eth", "ENS name record should be correct");
        
        // Check initial text records were set by vault initialization
        assertEq(resolver.text(node, "description"), "Personal Savings Vault", "Description should be set");
        assertEq(resolver.text(node, "status"), "active", "Status should be active");
        
        // Verify factory tracking
        address[] memory userVaults = factory.getUserVaults(user1);
        assertEq(userVaults.length, 1, "User should have 1 vault");
        assertEq(userVaults[0], vaultAddress, "Vault address should match");
    }

        // Test 2: Complete Deposit Workflow with ENS Updates
    function test_DepositUpdatesENSRecords() public {
        vm.prank(user1);
        address vaultAddress = factory.createVault{value: REGISTRATION_FEE}(30 days, "savings");
        PersonalVault vault = PersonalVault(vaultAddress);
        bytes32 node = getEnsNode("savings");

        // [FIX] Check that the balance record is initially NOT SET (empty string)
        // The vault initialization does not set a "balance" record.
        assertEq(resolver.text(node, "balance"), "", "Initial balance record should be empty before deposit");

        // Deposit funds
        vm.prank(user1);
        usdc.approve(vaultAddress, 100 * 10**6);
        vm.prank(user1);
        vault.deposit(50 * 10**6);

        // Verify vault balance
        assertEq(vault.getBalance(), 50 * 10**6, "Vault should have 50 USDC");
        
        // [FIX] Verify ENS records were updated FROM EMPTY to the new value
        assertEq(resolver.text(node, "balance"), "50000000", "ENS balance should be updated after deposit");
        assertEq(resolver.text(node, "totalDeposited"), "50000000", "ENS total deposited should be updated after deposit");
    }

        // Test 3: Complete Withdrawal Workflow with ENS Updates
    function test_WithdrawalWorkflow() public {
        // [FIX] Capture the user's exact initial balance before any actions
        uint256 initialUserBalance = usdc.balanceOf(user1);

        vm.prank(user1);
        address vaultAddress = factory.createVault{value: REGISTRATION_FEE}(1 days, "withdrawal-test");
        PersonalVault vault = PersonalVault(vaultAddress);
        bytes32 node = getEnsNode("withdrawal-test");

        // Deposit
        vm.prank(user1);
        usdc.approve(vaultAddress, 100 * 10**6);
        vm.prank(user1);
        vault.deposit(100 * 10**6);

        // [FIX] Verify the user's balance decreased by the deposit amount
        assertEq(usdc.balanceOf(user1), initialUserBalance - 100 * 10**6, "User's balance should decrease after deposit");

        // Fast forward to after maturity
        vm.warp(block.timestamp + 2 days);
        assertTrue(vault.isMature(), "Vault should be mature");

        // Withdraw
        vm.prank(user1);
        vault.withdraw();

        // [FIX] Verify funds were returned to the ORIGINAL initial balance
        assertEq(usdc.balanceOf(user1), initialUserBalance, "User should get all funds back, returning to initial balance");
        assertEq(vault.getBalance(), 0, "Vault should be empty");

        // Verify ENS records were updated
        assertEq(resolver.text(node, "balance"), "0", "ENS balance should be 0");
        assertEq(resolver.text(node, "status"), "withdrawn", "ENS status should be withdrawn");
        assertEq(resolver.text(node, "amountWithdrawn"), "100000000", "ENS should record withdrawal amount");
    }

    // Test 4: Access Control - Only Owner Can Operate
    function test_OnlyOwnerAccess() public {
        vm.prank(user1);
        address vaultAddress = factory.createVault{value: REGISTRATION_FEE}(30 days, "security");
        PersonalVault vault = PersonalVault(vaultAddress);

        // user2 tries to deposit (should fail)
        vm.prank(user2);
        usdc.approve(vaultAddress, 100 * 10**6);
        vm.prank(user2);
        vm.expectRevert("Not owner");
        vault.deposit(50 * 10**6);

        // user2 tries to withdraw (should fail)
        vm.prank(user2);
        vm.expectRevert("Not owner");
        vault.withdraw();
    }

    // Test 5: Timelock Enforcement - Early Withdrawal Prevention
    function test_EarlyWithdrawalReverts() public {
        vm.prank(user1);
        address vaultAddress = factory.createVault{value: REGISTRATION_FEE}(7 days, "timelocked");
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

        // Fast forward to just before maturity (should still revert)
        vm.warp(block.timestamp + 6 days + 23 hours);
        vm.prank(user1);
        vm.expectRevert("Funds are locked until maturity");
        vault.withdraw();
    }

    // Test 6: Multiple Vaults Per User
    function test_MultipleVaults() public {
        vm.prank(user1);
        address vault1 = factory.createVault{value: REGISTRATION_FEE}(30 days, "vault-one");

        vm.prank(user1);
        address vault2 = factory.createVault{value: REGISTRATION_FEE}(60 days, "vault-two");

        // Verify both vaults exist and are tracked
        address[] memory userVaults = factory.getUserVaults(user1);
        assertEq(userVaults.length, 2, "User should have 2 vaults");
        assertEq(userVaults[0], vault1, "First vault should match");
        assertEq(userVaults[1], vault2, "Second vault should match");

        // Verify separate ENS registration for each
        bytes32 node1 = getEnsNode("vault-one");
        bytes32 node2 = getEnsNode("vault-two");
        assertEq(resolver.addr(node1), vault1, "First vault ENS should point to correct address");
        assertEq(resolver.addr(node2), vault2, "Second vault ENS should point to correct address");
    }

    // Test 7: Name Sanitization in Factory
    function test_NameSanitization() public {
        vm.prank(user1);
        address vaultAddress = factory.createVault{value: REGISTRATION_FEE}(30 days, "My Test Vault!");
        
        // Should sanitize to "my-test-vault"
        bytes32 node = getEnsNode("my-test-vault");
        assertEq(resolver.addr(node), vaultAddress, "Sanitized name should be registered");
    }

    // Test 8: ENS Name Availability Check
    function test_DuplicateNameReverts() public {
        vm.prank(user1);
        factory.createVault{value: REGISTRATION_FEE}(30 days, "unique");

        // Try to create another vault with same name (should revert)
        vm.prank(user2);
        vm.expectRevert("Name not available");
        factory.createVault{value: REGISTRATION_FEE}(30 days, "unique");
    }

    // Test 9: Insufficient Registration Fee Reverts
    function test_InsufficientFeeReverts() public {
        vm.prank(user1);
        vm.expectRevert("Insufficient registration fee");
        factory.createVault{value: 0.0001 ether}(30 days, "testvault");
    }

    // Test 10: Refund of Excess ETH
    function test_ExcessEthRefund() public {
        uint256 initialBalance = user1.balance;
        
        vm.prank(user1);
        factory.createVault{value: 0.002 ether}(30 days, "refund-test"); // Send 2x the required fee
        
        // Should refund the excess (0.002 - 0.001 = 0.001 ether refund)
        assertEq(user1.balance, initialBalance - REGISTRATION_FEE, "User should be refunded excess ETH");
    }
}