// // SPDX-License-Identifier: MIT
// pragma solidity ^0.8.19;

// import "forge-std/Test.sol";
// import "../../contracts/GroupPool/GroupPool.sol";
// import "../../contracts/GroupPool/GroupPoolFactory.sol";
// import "../../contracts/GroupPool/IGroupPool.sol";
// import "@openzeppelin/contracts/token/ERC20/ERC20.sol";

// // Mock USDC token for testing
// contract MockUSDC is ERC20 {
//     constructor() ERC20("USD Coin", "USDC") {
//         _mint(msg.sender, 1000000 * 10 ** decimals());
//     }
    
//     function mint(address to, uint256 amount) public {
//         _mint(to, amount);
//     }
// }

// // Mock ENS Registry for testing
// contract MockENSRegistry is IENSRegistry {
//     mapping(bytes32 => address) public owners;
//     mapping(bytes32 => address) public resolvers;
    
//     function setSubnodeRecord(
//         bytes32 parentNode,
//         bytes32 label,
//         address newOwner,
//         address newResolver,
//         uint64 ttl
//     ) external override {
//         bytes32 node = keccak256(abi.encodePacked(parentNode, label));
//         owners[node] = newOwner;
//         resolvers[node] = newResolver;
//     }
    
//     function setResolver(bytes32 node, address newResolver) external override {
//         resolvers[node] = newResolver;
//     }
    
//     function owner(bytes32 node) external view override returns (address) {
//         return owners[node];
//     }
    
//     function resolver(bytes32 node) external view override returns (address) {
//         return resolvers[node];
//     }
// }

// // Mock ENS Resolver for testing
// contract MockENSResolver is IENSResolver {
//     mapping(bytes32 => address) public addrs;
//     mapping(bytes32 => string) public names;
//     mapping(bytes32 => mapping(string => string)) public texts;
    
//     function setAddr(bytes32 node, address newAddr) external override {
//         addrs[node] = newAddr;
//     }
    
//     function setName(bytes32 node, string memory newName) external override {
//         names[node] = newName;
//     }
    
//     function setText(bytes32 node, string memory key, string memory value) external override {
//         texts[node][key] = value;
//     }
    
//     function addr(bytes32 node) external view override returns (address) {
//         return addrs[node];
//     }
    
//     function name(bytes32 node) external view override returns (string memory) {
//         return names[node];
//     }
    
//     function text(bytes32 node, string memory key) external view override returns (string memory) {
//         return texts[node][key];
//     }
// }

// contract GroupPoolTest is Test {
//     GroupPoolFactory public factory;
//     MockUSDC public usdc;
//     MockENSRegistry public ensRegistry;
//     MockENSResolver public ensResolver;
    
//     address public owner = address(0x1);
//     address public member1 = address(0x2);
//     address public member2 = address(0x3);
//     address public member3 = address(0x4);
//     address public nonMember = address(0x5);
    
//     uint256 public constant CONTRIBUTION_AMOUNT = 100 * 10 ** 6; // 100 USDC (6 decimals)
//     uint256 public constant MATURITY_DATE = 30 days;
//     bytes32 public constant BASE_DOMAIN_NODE = keccak256(abi.encodePacked("base.eth"));
    
//     function setUp() public {
//         vm.startPrank(owner);
        
//         // Deploy mock USDC
//         usdc = new MockUSDC();

//         // Deploy mock ENS components
//         ensRegistry = new MockENSRegistry();
//         ensResolver = new MockENSResolver();
        
//         // Deploy factory with ENS parameters
//         factory = new GroupPoolFactory(
//             address(usdc),
//             address(ensRegistry),
//             address(ensResolver),
//             BASE_DOMAIN_NODE,
//             owner
//         );
        
//         // Mint USDC to members
//         usdc.mint(member1, 1000 * 10 ** 6);
//         usdc.mint(member2, 1000 * 10 ** 6);
//         usdc.mint(member3, 1000 * 10 ** 6);
        
//         vm.stopPrank();
//     }
    
//     function test_CreatePoolWithENS() public {
//         vm.startPrank(owner);
        
//         address[] memory members = new address[](3);
//         members[0] = member1;
//         members[1] = member2;
//         members[2] = member3;
        
//         string[] memory ensNames = new string[](3);
//         ensNames[0] = "member1.eth";
//         ensNames[1] = "member2.eth";
//         ensNames[2] = "member3.eth";
        
//         address poolAddress = factory.createPool(
//             "Test Pool",
//             "Test Description",
//             members,
//             ensNames,
//             CONTRIBUTION_AMOUNT,
//             IGroupPool.ContributionInterval.WEEKLY,
//             block.timestamp + MATURITY_DATE
//         );
        
//         IGroupPool pool = IGroupPool(poolAddress);
        
//         // Verify pool properties
//         assertEq(pool.poolName(), "Test Pool");
//         assertEq(pool.creator(), owner);
//         assertEq(pool.contributionAmount(), CONTRIBUTION_AMOUNT);
//         assertEq(uint256(pool.contributionInterval()), uint256(IGroupPool.ContributionInterval.WEEKLY));
//         assertEq(pool.totalContributors(), 3);
        
//         // Verify pool has ENS name
//         string memory poolENS = pool.poolENSName();
//         assertTrue(bytes(poolENS).length > 0);
//         assertTrue(endsWith(poolENS, ".base.eth"));
        
//         // Verify factory knows the ENS name
//         string memory factoryENS = factory.getPoolENS(poolAddress);
//         assertEq(factoryENS, poolENS);
        
//         // Verify members
//         assertTrue(pool.isMember(member1));
//         assertTrue(pool.isMember(member2));
//         assertTrue(pool.isMember(member3));
//         assertFalse(pool.isMember(nonMember));
        
//         vm.stopPrank();
//     }

//     function test_UpdateENSName() public {
//         vm.startPrank(owner);
        
//         address[] memory members = new address[](1);
//         members[0] = member1;
        
//         string[] memory ensNames = new string[](1);
//         ensNames[0] = "oldname.eth";
        
//         address poolAddress = factory.createPool(
//             "Test Pool",
//             "Test Description",
//             members,
//             ensNames,
//             CONTRIBUTION_AMOUNT,
//             IGroupPool.ContributionInterval.WEEKLY,
//             block.timestamp + MATURITY_DATE
//         );
        
//         IGroupPool pool = IGroupPool(poolAddress);
        
//         vm.stopPrank();
        
//         // Join first
//         vm.prank(member1);
//         pool.joinPool("oldname.eth");
        
//         // Verify initial ENS name
//         assertEq(pool.getMemberENS(member1), "oldname.eth");
        
//         // Update ENS name
//         vm.prank(member1);
//         pool.updateENSName("newname.eth");
        
//         // Verify updated ENS name
//         assertEq(pool.getMemberENS(member1), "newname.eth");
        
//         // Cannot set empty ENS name
//         vm.prank(member1);
//         vm.expectRevert("ENS name cannot be empty");
//         pool.updateENSName("");
//     }
    
//     function test_JoinPoolWithENS() public {
//         vm.startPrank(owner);
        
//         address[] memory members = new address[](2);
//         members[0] = member1;
//         members[1] = member2;
        
//         string[] memory ensNames = new string[](2);
//         ensNames[0] = "member1.eth";
//         ensNames[1] = "member2.eth";
        
//         address poolAddress = factory.createPool(
//             "Test Pool",
//             "Test Description",
//             members,
//             ensNames,
//             CONTRIBUTION_AMOUNT,
//             IGroupPool.ContributionInterval.WEEKLY,
//             block.timestamp + MATURITY_DATE
//         );
        
//         IGroupPool pool = IGroupPool(poolAddress);
        
//         vm.stopPrank();
        
//         // Member1 joins with ENS name
//         vm.prank(member1);
//         pool.joinPool("member1.eth");
//         assertEq(pool.getMemberENS(member1), "member1.eth");
        
//         // Member2 joins with different ENS name
//         vm.prank(member2);
//         pool.joinPool("member2-updated.eth");
//         assertEq(pool.getMemberENS(member2), "member2-updated.eth");
        
//         // Member2 joins again without changing ENS name
//         vm.prank(member2);
//         pool.joinPool("");
//         assertEq(pool.getMemberENS(member2), "member2-updated.eth"); // Should remain unchanged
        
//         // Non-member cannot join
//         vm.prank(nonMember);
//         vm.expectRevert("Not allowed to join this pool");
//         pool.joinPool("nonmember.eth");
//     }

//     // Helper function to check if string ends with suffix
//     function endsWith(string memory str, string memory suffix) internal pure returns (bool) {
//         bytes memory strBytes = bytes(str);
//         bytes memory suffixBytes = bytes(suffix);
        
//         if (strBytes.length < suffixBytes.length) {
//             return false;
//         }
        
//         for (uint256 i = 0; i < suffixBytes.length; i++) {
//             if (strBytes[strBytes.length - suffixBytes.length + i] != suffixBytes[i]) {
//                 return false;
//             }
//         }
        
//         return true;
//     }
    
//     function test_Contribute() public {
//         vm.startPrank(owner);
        
//         address[] memory members = new address[](2);
//         members[0] = member1;
//         members[1] = member2;
        
//         string[] memory ensNames = new string[](2);
//         ensNames[0] = "member1.eth";
//         ensNames[1] = "member2.eth";
        
//         address poolAddress = factory.createPool(
//             "Test Pool",
//             "Test Description",
//             members,
//             ensNames,
//             CONTRIBUTION_AMOUNT,
//             IGroupPool.ContributionInterval.WEEKLY,
//             block.timestamp + MATURITY_DATE
//         );
        
//         IGroupPool pool = IGroupPool(poolAddress);
        
//         vm.stopPrank();
        
//         // Join first
//         vm.prank(member1);
//         pool.joinPool("member1.eth");
        
//         vm.prank(member2);
//         pool.joinPool("member2.eth");
        
//         // Approve USDC spending
//         vm.prank(member1);
//         usdc.approve(poolAddress, CONTRIBUTION_AMOUNT);
        
//         vm.prank(member2);
//         usdc.approve(poolAddress, CONTRIBUTION_AMOUNT);
        
//         // Member1 contributes
//         vm.prank(member1);
//         pool.contribute();
        
//         assertTrue(pool.hasContributed(member1));
//         assertEq(pool.getContributionCount(member1), 1);
//         assertEq(pool.totalFunds(), CONTRIBUTION_AMOUNT);
        
//         // Member2 contributes
//         vm.prank(member2);
//         pool.contribute();
        
//         assertTrue(pool.hasContributed(member2));
//         assertEq(pool.getContributionCount(member2), 1);
//         assertEq(pool.totalFunds(), 2 * CONTRIBUTION_AMOUNT);
        
//         // Cannot contribute twice in same period
//         vm.prank(member1);
//         vm.expectRevert("Not time for next contribution yet");
//         pool.contribute();
        
//         // Non-member cannot contribute
//         vm.prank(nonMember);
//         vm.expectRevert("Not a pool member");
//         pool.contribute();
//     }
    
//     function test_CannotContributeAfterMaturity() public {
//         vm.startPrank(owner);
        
//         address[] memory members = new address[](1);
//         members[0] = member1;
        
//         string[] memory ensNames = new string[](1);
//         ensNames[0] = "member1.eth";
        
//         address poolAddress = factory.createPool(
//             "Test Pool",
//             "Test Description",
//             members,
//             ensNames,
//             CONTRIBUTION_AMOUNT,
//             IGroupPool.ContributionInterval.WEEKLY,
//             block.timestamp + 1 days // Short maturity
//         );
        
//         IGroupPool pool = IGroupPool(poolAddress);
        
//         vm.stopPrank();
        
//         // Join
//         vm.prank(member1);
//         pool.joinPool("member1.eth");
        
//         // Approve USDC
//         vm.prank(member1);
//         usdc.approve(poolAddress, CONTRIBUTION_AMOUNT);
        
//         // Fast forward past maturity
//         vm.warp(block.timestamp + 2 days);
        
//         // Cannot contribute after maturity
//         vm.prank(member1);
//         vm.expectRevert("Pool has matured");
//         pool.contribute();
//     }
    
//     function test_IndividualWithdrawal() public {
//         vm.startPrank(owner);
        
//         address[] memory members = new address[](3);
//         members[0] = member1;
//         members[1] = member2;
//         members[2] = member3;
        
//         string[] memory ensNames = new string[](3);
//         ensNames[0] = "member1.eth";
//         ensNames[1] = "member2.eth";
//         ensNames[2] = "member3.eth";
        
//         address poolAddress = factory.createPool(
//             "Test Pool",
//             "Test Description",
//             members,
//             ensNames,
//             CONTRIBUTION_AMOUNT,
//             IGroupPool.ContributionInterval.WEEKLY,
//             block.timestamp + MATURITY_DATE
//         );
        
//         IGroupPool pool = IGroupPool(poolAddress);
        
//         vm.stopPrank();
        
//         // Join all members
//         vm.prank(member1);
//         pool.joinPool("member1.eth");
        
//         vm.prank(member2);
//         pool.joinPool("member2.eth");
        
//         vm.prank(member3);
//         pool.joinPool("member3.eth");
        
//         // Approve USDC spending
//         vm.prank(member1);
//         usdc.approve(poolAddress, CONTRIBUTION_AMOUNT * 2); // Member1 contributes double
        
//         vm.prank(member2);
//         usdc.approve(poolAddress, CONTRIBUTION_AMOUNT);
        
//         vm.prank(member3);
//         usdc.approve(poolAddress, CONTRIBUTION_AMOUNT);
        
//         // Member1 contributes twice (double amount)
//         vm.prank(member1);
//         pool.contribute();
        
//         // Fast forward 1 week for next contribution
//         vm.warp(block.timestamp + 7 days);
//         vm.prank(member1);
//         pool.contribute();
        
//         // Member2 contributes once
//         vm.prank(member2);
//         pool.contribute();
        
//         // Member3 does NOT contribute
        
//         // Fast forward to maturity
//         vm.warp(block.timestamp + MATURITY_DATE);
        
//         uint256 initialBalance1 = usdc.balanceOf(member1);
//         uint256 initialBalance2 = usdc.balanceOf(member2);
//         uint256 poolBalance = usdc.balanceOf(poolAddress);
        
//         assertEq(poolBalance, 3 * CONTRIBUTION_AMOUNT); // 2 from member1, 1 from member2
        
//         // Check withdrawable amounts (proportional to contributions)
//         uint256 withdrawable1 = pool.getWithdrawableAmount(member1);
//         uint256 withdrawable2 = pool.getWithdrawableAmount(member2);
//         uint256 withdrawable3 = pool.getWithdrawableAmount(member3);
        
//         // Member1 should get 2/3 of total, Member2 gets 1/3, Member3 gets 0
//         assertEq(withdrawable1, (2 * CONTRIBUTION_AMOUNT * 3 * CONTRIBUTION_AMOUNT) / (3 * CONTRIBUTION_AMOUNT));
//         assertEq(withdrawable2, (1 * CONTRIBUTION_AMOUNT * 3 * CONTRIBUTION_AMOUNT) / (3 * CONTRIBUTION_AMOUNT));
//         assertEq(withdrawable3, 0);
        
//         // Member1 withdraws
//         vm.prank(member1);
//         pool.withdraw();
        
//         assertEq(usdc.balanceOf(member1), initialBalance1 + withdrawable1);
//         assertEq(usdc.balanceOf(poolAddress), poolBalance - withdrawable1);
        
//         // Member2 withdraws
//         vm.prank(member2);
//         pool.withdraw();
        
//         assertEq(usdc.balanceOf(member2), initialBalance2 + withdrawable2);
//         assertEq(usdc.balanceOf(poolAddress), 0);
        
//         // Member3 cannot withdraw (no contributions)
//         vm.prank(member3);
//         vm.expectRevert("No contributions to withdraw");
//         pool.withdraw();
        
//         // Cannot withdraw twice
//         vm.prank(member1);
//         vm.expectRevert("Already withdrawn");
//         pool.withdraw();
//     }
    
//     function test_CannotWithdrawBeforeMaturity() public {
//         vm.startPrank(owner);
        
//         address[] memory members = new address[](1);
//         members[0] = member1;
        
//         string[] memory ensNames = new string[](1);
//         ensNames[0] = "member1.eth";
        
//         address poolAddress = factory.createPool(
//             "Test Pool",
//             "Test Description",
//             members,
//             ensNames,
//             CONTRIBUTION_AMOUNT,
//             IGroupPool.ContributionInterval.WEEKLY,
//             block.timestamp + MATURITY_DATE
//         );
        
//         IGroupPool pool = IGroupPool(poolAddress);
        
//         vm.stopPrank();
        
//         // Join and contribute
//         vm.prank(member1);
//         pool.joinPool("member1.eth");
        
//         vm.prank(member1);
//         usdc.approve(poolAddress, CONTRIBUTION_AMOUNT);
        
//         vm.prank(member1);
//         pool.contribute();
        
//         // Try to withdraw before maturity
//         vm.prank(member1);
//         vm.expectRevert("Pool not matured yet");
//         pool.withdraw();
//     }
    
//     function test_GetWithdrawableAmount() public {
//         vm.startPrank(owner);
        
//         address[] memory members = new address[](2);
//         members[0] = member1;
//         members[1] = member2;
        
//         string[] memory ensNames = new string[](2);
//         ensNames[0] = "member1.eth";
//         ensNames[1] = "member2.eth";
        
//         address poolAddress = factory.createPool(
//             "Test Pool",
//             "Test Description",
//             members,
//             ensNames,
//             CONTRIBUTION_AMOUNT,
//             IGroupPool.ContributionInterval.WEEKLY,
//             block.timestamp + MATURITY_DATE
//         );
        
//         IGroupPool pool = IGroupPool(poolAddress);
        
//         vm.stopPrank();
        
//         // Join and contribute
//         vm.prank(member1);
//         pool.joinPool("member1.eth");
        
//         vm.prank(member1);
//         usdc.approve(poolAddress, CONTRIBUTION_AMOUNT);
        
//         vm.prank(member1);
//         pool.contribute();
        
//         // Member2 does not contribute
        
//         // Fast forward to maturity
//         vm.warp(block.timestamp + MATURITY_DATE + 1);
        
//         // Member1 should be able to withdraw their contribution
//         assertEq(pool.getWithdrawableAmount(member1), CONTRIBUTION_AMOUNT);
        
//         // Member2 should get 0 (no contributions)
//         assertEq(pool.getWithdrawableAmount(member2), 0);
        
//         // Non-member should get 0
//         assertEq(pool.getWithdrawableAmount(nonMember), 0);
//     }
    
//     function test_FactoryOwnership() public {
//         // Test that only owner can update implementation
//         vm.prank(nonMember);
//         vm.expectRevert();
//         factory.updateImplementation(address(0));
        
//         // Test that only owner can update USDC token
//         vm.prank(nonMember);
//         vm.expectRevert();
//         factory.updateUsdcToken(address(0));
        
//         // Owner can update
//         vm.prank(owner);
//         factory.updateImplementation(address(0x123));
        
//         vm.prank(owner);
//         factory.updateUsdcToken(address(0x456));
//     }

//     function test_FactoryENSUpdates() public {
//         // Test that only owner can update ENS registry
//         vm.prank(nonMember);
//         vm.expectRevert();
//         factory.updateENSRegistry(address(0));
        
//         // Test that only owner can update ENS resolver
//         vm.prank(nonMember);
//         vm.expectRevert();
//         factory.updateENSResolver(address(0));
        
//         // Owner can update
//         vm.prank(owner);
//         factory.updateENSRegistry(address(0x123));
        
//         vm.prank(owner);
//         factory.updateENSResolver(address(0x456));
        
//         // Verify updates
//         assertEq(address(0x123), address(factory.ensRegistry()));
//         assertEq(address(0x456), address(factory.ensResolver()));
//     }
// }
