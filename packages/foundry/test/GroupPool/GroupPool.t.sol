// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import "forge-std/Test.sol";
import "../../contracts/GroupPool/GroupPool.sol";
import "../../contracts/GroupPool/GroupPoolFactory.sol";
import "../../contracts/GroupPool/IGroupPool.sol";
import "../../contracts/GroupPool/IPublicResolver.sol";
import "@openzeppelin/contracts/token/ERC20/ERC20.sol";

// Mock USDC token for testing
contract MockUSDC is ERC20 {
    constructor() ERC20("USD Coin", "USDC") {
        _mint(msg.sender, 1000000 * 10 ** decimals());
    }
    
    function mint(address to, uint256 amount) public {
        _mint(to, amount);
    }
}

// Complete mock ENS Resolver
contract MockENSResolver is IPublicResolver {
    mapping(bytes32 => address) public addrs;
    mapping(bytes32 => string) public names;
    mapping(bytes32 => mapping(string => string)) public texts;
    
    event AddrSet(bytes32 indexed node, address addr);
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

// Complete mock Registrar Controller that properly handles ENS registration
contract MockRegistrarController {
    MockENSResolver public resolver;
    mapping(string => bool) public registeredNames;
    uint256 public constant REGISTRATION_PRICE = 0.01 ether;
    
    event NameRegistered(string indexed name, address owner, address resolver);
    
    constructor(address _resolver) {
        resolver = MockENSResolver(_resolver);
    }
    
    function available(string calldata name) external view returns (bool) {
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
        
        registeredNames[name] = true;
        
        // Process resolver data calls
        for (uint256 i = 0; i < data.length; i++) {
            (bool success, ) = resolverAddress.call(data[i]);
            require(success, "Resolver call failed");
        }
        
        emit NameRegistered(name, owner, resolverAddress);
    }
}

contract GroupPoolTest is Test {
    GroupPoolFactory public factory;
    MockUSDC public usdc;
    MockENSResolver public ensResolver;
    MockRegistrarController public registrarController;
    
    address public owner = address(0x1);
    address public member1 = address(0x2);
    address public member2 = address(0x3);
    address public member3 = address(0x4);
    address public nonMember = address(0x5);
    
    uint256 public constant CONTRIBUTION_AMOUNT = 100 * 10 ** 6; // 100 USDC (6 decimals)
    uint256 public constant MATURITY_DATE = 30 days;
    uint256 public constant REGISTRATION_FEE = 0.01 ether;
    
    function setUp() public {
        vm.startPrank(owner);
        
        // Deploy mock USDC
        usdc = new MockUSDC();

        // Deploy mock ENS resolver
        ensResolver = new MockENSResolver();
        
        // Deploy mock registrar controller
        registrarController = new MockRegistrarController(address(ensResolver));
        
        // Deploy factory with USDC token address and owner
        factory = new GroupPoolFactory(
            address(usdc),
            owner
        );
        
        // Update the resolver and registrar addresses in factory to use our mocks
        factory.updatePublicResolver(address(ensResolver));
        factory.updateRegistrarController(address(registrarController));
        
        // Mint USDC to members
        usdc.mint(member1, 1000 * 10 ** 6);
        usdc.mint(member2, 1000 * 10 ** 6);
        usdc.mint(member3, 1000 * 10 ** 6);
        
        // Give owner some ETH for registration fees
        vm.deal(owner, 10 ether);
        vm.deal(member1, 10 ether);
        
        vm.stopPrank();
    }
    
    function test_CreatePoolWithENS() public {
        vm.startPrank(owner);
        
        address[] memory members = new address[](3);
        members[0] = member1;
        members[1] = member2;
        members[2] = member3;
        
        string[] memory ensNames = new string[](3);
        ensNames[0] = "member1.eth";
        ensNames[1] = "member2.eth";
        ensNames[2] = "member3.eth";
        
        address poolAddress = factory.createPool{value: REGISTRATION_FEE}(
            "Test Pool",
            "Test Description",
            members,
            ensNames,
            CONTRIBUTION_AMOUNT,
            IGroupPool.ContributionInterval.WEEKLY,
            block.timestamp + MATURITY_DATE
        );
        
        IGroupPool pool = IGroupPool(poolAddress);
        
        // Verify pool properties
        assertEq(pool.poolName(), "Test Pool");
        assertEq(pool.creator(), owner);
        assertEq(pool.contributionAmount(), CONTRIBUTION_AMOUNT);
        assertEq(uint256(pool.contributionInterval()), uint256(IGroupPool.ContributionInterval.WEEKLY));
        assertEq(pool.totalContributors(), 3);
        
        // Verify pool has ENS name
        string memory poolENS = pool.poolENSName();
        assertTrue(bytes(poolENS).length > 0);
        assertTrue(endsWith(poolENS, ".base.eth"));
        
        // Verify factory knows the ENS name
        string memory factoryENS = factory.getPoolENS(poolAddress);
        assertEq(factoryENS, poolENS);
        
        // Verify ENS records were set
        bytes32 node = keccak256(abi.encodePacked(keccak256(abi.encodePacked("base.eth")), keccak256(abi.encodePacked("test-pool"))));
        assertEq(ensResolver.addr(node), poolAddress);
        assertEq(ensResolver.name(node), poolENS);
        
        // Verify members
        assertTrue(pool.isMember(member1));
        assertTrue(pool.isMember(member2));
        assertTrue(pool.isMember(member3));
        assertFalse(pool.isMember(nonMember));
        
        vm.stopPrank();
    }

    function test_JoinAndContributeWithENS() public {
        vm.startPrank(owner);
        
        address[] memory members = new address[](2);
        members[0] = member1;
        members[1] = member2;
        
        string[] memory ensNames = new string[](2);
        ensNames[0] = "member1.eth";
        ensNames[1] = "member2.eth";
        
        address poolAddress = factory.createPool{value: REGISTRATION_FEE}(
            "Test Pool",
            "Test Description",
            members,
            ensNames,
            CONTRIBUTION_AMOUNT,
            IGroupPool.ContributionInterval.WEEKLY,
            block.timestamp + MATURITY_DATE
        );
        
        IGroupPool pool = IGroupPool(poolAddress);
        
        vm.stopPrank();
        
        // Join first
        vm.prank(member1);
        pool.joinPool("member1.eth");
        
        vm.prank(member2);
        pool.joinPool("member2.eth");
        
        // Approve USDC spending
        vm.prank(member1);
        usdc.approve(poolAddress, CONTRIBUTION_AMOUNT * 10);
        
        vm.prank(member2);
        usdc.approve(poolAddress, CONTRIBUTION_AMOUNT * 10);
        
        // Member1 contributes
        vm.prank(member1);
        pool.contribute();
        
        assertTrue(pool.hasContributed(member1));
        assertEq(pool.getContributionCount(member1), 1);
        assertEq(pool.totalFunds(), CONTRIBUTION_AMOUNT);
        
        // Member2 contributes
        vm.prank(member2);
        pool.contribute();
        
        assertTrue(pool.hasContributed(member2));
        assertEq(pool.getContributionCount(member2), 1);
        assertEq(pool.totalFunds(), 2 * CONTRIBUTION_AMOUNT);
        
        // Check ENS records were updated
        bytes32 node = keccak256(abi.encodePacked(keccak256(abi.encodePacked("base.eth")), keccak256(abi.encodePacked("test-pool"))));
        assertEq(ensResolver.text(node, "totalFunds"), "200000000");
    }
    
    function test_WithdrawalWithENS() public {
        vm.startPrank(owner);
        
        address[] memory members = new address[](2);
        members[0] = member1;
        members[1] = member2;
        
        string[] memory ensNames = new string[](2);
        ensNames[0] = "member1.eth";
        ensNames[1] = "member2.eth";
        
        address poolAddress = factory.createPool{value: REGISTRATION_FEE}(
            "Test Pool",
            "Test Description",
            members,
            ensNames,
            CONTRIBUTION_AMOUNT,
            IGroupPool.ContributionInterval.WEEKLY,
            block.timestamp + 1 days // Short maturity
        );
        
        IGroupPool pool = IGroupPool(poolAddress);
        
        vm.stopPrank();
        
        // Join and contribute
        vm.prank(member1);
        pool.joinPool("member1.eth");
        
        vm.prank(member1);
        usdc.approve(poolAddress, CONTRIBUTION_AMOUNT);
        
        vm.prank(member1);
        pool.contribute();
        
        // Fast forward to maturity
        vm.warp(block.timestamp + 2 days);
        
        uint256 initialBalance = usdc.balanceOf(member1);
        
        // Member1 withdraws
        vm.prank(member1);
        pool.withdraw();
        
        assertEq(usdc.balanceOf(member1), initialBalance + CONTRIBUTION_AMOUNT);
        assertEq(usdc.balanceOf(poolAddress), 0);
        
        // Check ENS records were updated
        bytes32 node = keccak256(abi.encodePacked(keccak256(abi.encodePacked("base.eth")), keccak256(abi.encodePacked("test-pool"))));
        assertEq(ensResolver.text(node, "totalFunds"), "0");
    }
    
    function test_ENSNameUpdates() public {
        vm.startPrank(owner);
        
        address[] memory members = new address[](1);
        members[0] = member1;
        
        string[] memory ensNames = new string[](1);
        ensNames[0] = "oldname.eth";
        
        address poolAddress = factory.createPool{value: REGISTRATION_FEE}(
            "Test Pool",
            "Test Description",
            members,
            ensNames,
            CONTRIBUTION_AMOUNT,
            IGroupPool.ContributionInterval.WEEKLY,
            block.timestamp + MATURITY_DATE
        );
        
        IGroupPool pool = IGroupPool(poolAddress);
        
        vm.stopPrank();
        
        // Join first
        vm.prank(member1);
        pool.joinPool("oldname.eth");
        
        // Update ENS name
        vm.prank(member1);
        pool.updateENSName("newname.eth");
        
        assertEq(pool.getMemberENS(member1), "newname.eth");
    }
    
    function test_FactoryAdminFunctions() public {
        // Test admin functions
        vm.prank(owner);
        factory.updateImplementation(address(0x123));
        
        vm.prank(owner);
        factory.updateUsdcToken(address(0x456));
        
        vm.prank(owner);
        factory.updatePublicResolver(address(0x789));
        
        vm.prank(owner);
        factory.updateRegistrarController(address(0xABC));
        
        assertEq(factory.implementation(), address(0x123));
        assertEq(factory.usdcToken(), address(0x456));
    }
    
    function test_Revert_InsufficientRegistrationFee() public {
        vm.startPrank(owner);
        
        address[] memory members = new address[](1);
        members[0] = member1;
        
        string[] memory ensNames = new string[](1);
        ensNames[0] = "member1.eth";
        
        vm.expectRevert("Insufficient registration fee");
        factory.createPool{value: 0.001 ether}(
            "Test Pool",
            "Test Description",
            members,
            ensNames,
            CONTRIBUTION_AMOUNT,
            IGroupPool.ContributionInterval.WEEKLY,
            block.timestamp + MATURITY_DATE
        );
        
        vm.stopPrank();
    }
    
    function test_Revert_NameNotAvailable() public {
        vm.startPrank(owner);
        
        // Register a name first
        address[] memory members = new address[](1);
        members[0] = member1;
        
        string[] memory ensNames = new string[](1);
        ensNames[0] = "member1.eth";
        
        factory.createPool{value: REGISTRATION_FEE}(
            "Test Pool",
            "Test Description",
            members,
            ensNames,
            CONTRIBUTION_AMOUNT,
            IGroupPool.ContributionInterval.WEEKLY,
            block.timestamp + MATURITY_DATE
        );
        
        // Try to register same name again
        vm.expectRevert("Name not available");
        factory.createPool{value: REGISTRATION_FEE}(
            "Test Pool", // Same name
            "Test Description 2",
            members,
            ensNames,
            CONTRIBUTION_AMOUNT,
            IGroupPool.ContributionInterval.WEEKLY,
            block.timestamp + MATURITY_DATE
        );
        
        vm.stopPrank();
    }

    // Helper function to check if string ends with suffix
    function endsWith(string memory str, string memory suffix) internal pure returns (bool) {
        bytes memory strBytes = bytes(str);
        bytes memory suffixBytes = bytes(suffix);
        
        if (strBytes.length < suffixBytes.length) {
            return false;
        }
        
        for (uint256 i = 0; i < suffixBytes.length; i++) {
            if (strBytes[strBytes.length - suffixBytes.length + i] != suffixBytes[i]) {
                return false;
            }
        }
        
        return true;
    }
}