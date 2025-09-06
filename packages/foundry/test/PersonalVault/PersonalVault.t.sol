// // SPDX-License-Identifier: MIT
// pragma solidity ^0.8.19;

// import "forge-std/Test.sol";
// import "../../contracts/PersonalVault/PersonalVault.sol";
// import "../../contracts/PersonalVault/PersonalVaultFactory.sol";
// import "../../contracts/PersonalVault/interfaces/IENSRegistry.sol";
// import "../../contracts/PersonalVault/interfaces/IPublicResolver.sol";

// // Mock ENS Registry for testing
// contract MockENSRegistry is IENSRegistry {
//     mapping(bytes32 => address) public owners;
//     mapping(bytes32 => address) public resolvers;
    
//     function setOwner(bytes32 node, address owner) external override {
//         owners[node] = owner;
//     }
    
//     function setSubnodeOwner(bytes32 node, bytes32 label, address owner) external override returns (bytes32) {
//         bytes32 subnode = keccak256(abi.encodePacked(node, label));
//         owners[subnode] = owner;
//         return subnode;
//     }
    
//     function setResolver(bytes32 node, address resolver) external override {
//         resolvers[node] = resolver;
//     }
    
//     function owner(bytes32 node) external view override returns (address) {
//         return owners[node];
//     }
    
//     function resolver(bytes32 node) external view override returns (address) {
//         return resolvers[node];
//     }
// }

// // Mock Public Resolver for testing - implementing all required functions
// contract MockPublicResolver is IPublicResolver {
//     mapping(bytes32 => mapping(string => string)) public textRecords;
//     mapping(bytes32 => address) public addrRecords;
//     mapping(bytes32 => string) public nameRecords;
    
//     function setText(bytes32 node, string calldata key, string calldata value) external override {
//         textRecords[node][key] = value;
//     }
    
//     function text(bytes32 node, string calldata key) external view override returns (string memory) {
//         return textRecords[node][key];
//     }
    
//     function setAddr(bytes32 node, address addr) external override {
//         addrRecords[node] = addr;
//     }
    
//     function addr(bytes32 node) external view override returns (address) {
//         return addrRecords[node];
//     }
    
//     function setName(bytes32 node, string calldata name) external override {
//         nameRecords[node] = name;
//     }
    
//     function name(bytes32 node) external view returns (string memory) {
//         return nameRecords[node];
//     }
// }

// // Mock USDC token for testing
// contract MockUSDC {
//     mapping(address => uint256) public balanceOf;
//     mapping(address => mapping(address => uint256)) public allowance;
    
//     constructor() {
//         balanceOf[msg.sender] = 1000000 * 10**6; // 1M USDC for deployer
//     }
    
//     function transfer(address to, uint256 amount) external returns (bool) {
//         require(balanceOf[msg.sender] >= amount, "Insufficient balance");
//         balanceOf[msg.sender] -= amount;
//         balanceOf[to] += amount;
//         return true;
//     }
    
//     function transferFrom(address from, address to, uint256 amount) external returns (bool) {
//         require(balanceOf[from] >= amount, "Insufficient balance");
//         require(allowance[from][msg.sender] >= amount, "Insufficient allowance");
//         balanceOf[from] -= amount;
//         balanceOf[to] += amount;
//         allowance[from][msg.sender] -= amount;
//         return true;
//     }
    
//     function approve(address spender, uint256 amount) external returns (bool) {
//         allowance[msg.sender][spender] = amount;
//         return true;
//     }
// }

// contract PersonalVaultTest is Test {
//     PersonalVaultFactory public factory;
//     MockENSRegistry public ensRegistry;
//     MockPublicResolver public publicResolver;
//     MockUSDC public usdc;
    
//     address constant OWNER = address(0x1234);
//     address constant USER = address(0x5678);
    
//     string constant PARENT_NAME = "de-susu-demo.base.eth";
//     bytes32 constant PARENT_NAMEHASH = keccak256(abi.encodePacked(PARENT_NAME));
    
//     function setUp() public {
//         vm.startPrank(OWNER);
        
//         // Deploy mocks
//         usdc = new MockUSDC();
//         ensRegistry = new MockENSRegistry();
//         publicResolver = new MockPublicResolver();
        
//         // Set up initial domain ownership - OWNER owns the parent domain
//         ensRegistry.setOwner(PARENT_NAMEHASH, OWNER);
        
//         // Deploy factory
//         factory = new PersonalVaultFactory(
//             address(usdc),
//             address(ensRegistry),
//             address(publicResolver),
//             PARENT_NAME,
//             PARENT_NAMEHASH
//         );
        
//         vm.stopPrank();
//     }
    
//     function test_FactoryDeployment() public {
//         assertEq(factory.owner(), OWNER);
//         assertEq(address(factory.ensRegistry()), address(ensRegistry));
//         assertEq(address(factory.publicResolver()), address(publicResolver));
//         assertEq(factory.parentName(), PARENT_NAME);
//         assertEq(factory.parentNamehash(), PARENT_NAMEHASH);
//         assertFalse(factory.domainOwnershipTransferred());
//     }
    
//     function test_AcceptDomainOwnership() public {
//         vm.startPrank(OWNER);
        
//         // Verify initial ownership
//         assertEq(ensRegistry.owner(PARENT_NAMEHASH), OWNER);
        
//         // Transfer ownership to factory
//         factory.acceptDomainOwnership();
        
//         // Verify ownership transfer
//         assertEq(ensRegistry.owner(PARENT_NAMEHASH), address(factory));
//         assertTrue(factory.domainOwnershipTransferred());
        
//         vm.stopPrank();
//     }
    
//     function test_RevertIf_AcceptDomainOwnership_NotOwner() public {
//     vm.startPrank(USER);
    
//     // Change from string expectation to custom error expectation
//     vm.expectRevert(abi.encodeWithSignature("OwnableUnauthorizedAccount(address)", USER));
//     factory.acceptDomainOwnership();
    
//     vm.stopPrank();
// }
    
//     function test_RevertIf_AcceptDomainOwnership_NotDomainOwner() public {
//     vm.startPrank(USER);
    
//     // This will fail the Ownable check first, so use the custom error
//     vm.expectRevert(abi.encodeWithSignature("OwnableUnauthorizedAccount(address)", USER));
//     factory.acceptDomainOwnership();
    
//     vm.stopPrank();
// }
    
//     function test_CreateVault() public {
//         vm.startPrank(OWNER);
        
//         // First transfer domain ownership to factory
//         factory.acceptDomainOwnership();
        
//         // Fund user with USDC
//         usdc.transfer(USER, 1000 * 10**6);
        
//         vm.stopPrank();
        
//         // User creates a vault
//         vm.startPrank(USER);
        
//         uint256 lockDuration = 30 days;
//         string memory vaultName = "My Savings Vault";
        
//         address vaultAddress = factory.createVault(lockDuration, vaultName);
        
//         // Verify vault was created
//         assertTrue(vaultAddress != address(0));
        
//         PersonalVault vault = PersonalVault(vaultAddress);
//         assertEq(vault.owner(), USER);
//         assertEq(vault.lockDuration(), lockDuration);
//         assertEq(address(vault.usdc()), address(usdc));
        
//         // Verify vault was added to user's list
//         address[] memory userVaults = factory.getUserVaults(USER);
//         assertEq(userVaults.length, 1);
//         assertEq(userVaults[0], vaultAddress);
        
//         // Verify vault count
//         assertEq(factory.getVaultCount(), 1);
        
//         vm.stopPrank();
//     }
    
//     function test_RevertIf_CreateVault_WithoutDomainOwnership() public {
//         vm.startPrank(USER);
        
//         vm.expectRevert("Factory not domain owner. Call acceptDomainOwnership() first.");
//         factory.createVault(30 days, "Test Vault");
        
//         vm.stopPrank();
//     }
    
//     function test_RevertIf_CreateVault_EmptyName() public {
//         vm.startPrank(OWNER);
//         factory.acceptDomainOwnership();
//         vm.stopPrank();
        
//         vm.startPrank(USER);
        
//         vm.expectRevert("Empty label");
//         factory.createVault(30 days, "");
        
//         vm.stopPrank();
//     }
    
//     function test_SanitizeName() public {
//         vm.startPrank(OWNER);
//         factory.acceptDomainOwnership();
//         vm.stopPrank();
        
//         vm.startPrank(USER);
        
//         // Test various name sanitizations
//         address vault1 = factory.createVault(30 days, "My Vault");
//         address vault2 = factory.createVault(30 days, "MY_VAULT");
//         address vault3 = factory.createVault(30 days, "my-vault-123");
        
//         assertTrue(vault1 != address(0));
//         assertTrue(vault2 != address(0));
//         assertTrue(vault3 != address(0));
        
//         vm.stopPrank();
//     }
    
//     function test_VaultDepositAndWithdraw() public {
//         vm.startPrank(OWNER);
//         factory.acceptDomainOwnership();
//         usdc.transfer(USER, 5000 * 10**6); // 5000 USDC
//         vm.stopPrank();
        
//         vm.startPrank(USER);
        
//         // Create vault
//         address vaultAddress = factory.createVault(7 days, "Test Vault");
//         PersonalVault vault = PersonalVault(vaultAddress);
        
//         // Approve vault to spend USDC
//         uint256 depositAmount = 1000 * 10**6; // 1000 USDC
//         usdc.approve(address(vault), depositAmount);
        
//         // Deposit funds
//         vault.deposit(depositAmount);
        
//         // Verify deposit
//         assertEq(vault.getBalance(), depositAmount);
//         assertEq(usdc.balanceOf(address(vault)), depositAmount);
        
//         // Try early withdrawal (should fail)
//         vm.expectRevert("Funds are locked until maturity");
//         vault.withdraw();
        
//         // Fast forward time
//         vm.warp(block.timestamp + 8 days);
        
//         // Withdraw funds
//         vault.withdraw();
        
//         // Verify withdrawal
//         assertEq(vault.getBalance(), 0);
//         assertEq(usdc.balanceOf(address(USER)), 5000 * 10**6); // Full amount back
        
//         vm.stopPrank();
//     }
    
//     function test_RevertIf_Deposit_NotOwner() public {
//         vm.startPrank(OWNER);
//         factory.acceptDomainOwnership();
//         usdc.transfer(USER, 1000 * 10**6);
//         vm.stopPrank();
        
//         vm.startPrank(USER);
//         address vaultAddress = factory.createVault(7 days, "Test Vault");
//         PersonalVault vault = PersonalVault(vaultAddress);
//         vm.stopPrank();
        
//         // Try to deposit from different address
//         vm.startPrank(address(0x9999));
//         vm.expectRevert("Not owner");
//         vault.deposit(100 * 10**6);
//         vm.stopPrank();
//     }
    
//     function test_ENSSubdomainCreation() public {
//         vm.startPrank(OWNER);
//         factory.acceptDomainOwnership();
//         usdc.transfer(USER, 1000 * 10**6);
//         vm.stopPrank();
        
//         vm.startPrank(USER);
        
//         string memory vaultName = "test-vault";
//         address vaultAddress = factory.createVault(30 days, vaultName);
        
//         // Verify ENS subdomain was created
//         bytes32 labelHash = keccak256(abi.encodePacked("test-vault"));
//         bytes32 expectedNode = keccak256(abi.encodePacked(PARENT_NAMEHASH, labelHash));
        
//         assertEq(ensRegistry.owner(expectedNode), vaultAddress);
//         assertEq(address(ensRegistry.resolver(expectedNode)), address(publicResolver));
        
//         vm.stopPrank();
//     }
    
//     function test_AdminFunctions() public {
//         vm.startPrank(OWNER);
//         factory.acceptDomainOwnership();
//         vm.stopPrank();
        
//         vm.startPrank(OWNER);
        
//         // Test admin functions
//         bytes32 labelHash = keccak256(abi.encodePacked("test"));
//         factory.adminSetSubnodeOwner(labelHash, USER);
        
//         // Test ownership transfer back
//         factory.transferDomainOwnership(OWNER);
//         assertFalse(factory.domainOwnershipTransferred());
//         assertEq(ensRegistry.owner(PARENT_NAMEHASH), OWNER);
        
//         vm.stopPrank();
//     }
    
//     function test_RevertIf_AdminFunctions_NotOwner() public {
//     vm.startPrank(OWNER);
//     factory.acceptDomainOwnership();
//     vm.stopPrank();
    
//     vm.startPrank(USER);
    
//     bytes32 labelHash = keccak256(abi.encodePacked("test"));
    
//     // Update both expectations to use custom error format
//     vm.expectRevert(abi.encodeWithSignature("OwnableUnauthorizedAccount(address)", USER));
//     factory.adminSetSubnodeOwner(labelHash, USER);
    
//     vm.expectRevert(abi.encodeWithSignature("OwnableUnauthorizedAccount(address)", USER));
//     factory.transferDomainOwnership(USER);
    
//     vm.stopPrank();
// }
// }