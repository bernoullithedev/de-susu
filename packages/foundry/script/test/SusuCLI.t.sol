// // script/test/SusuCLI.t.sol
// // SPDX-License-Identifier: MIT
// pragma solidity ^0.8.19;

// import "forge-std/Test.sol";
// import "forge-std/console.sol";
// import "../../contracts/GroupPool/GroupPoolFactory.sol";
// import "../utils/MockContracts.sol";

// contract SusuCLI is Test {
//     GroupPoolFactory public factory;
//     MockUSDC public usdc;
//     MockRegistrarController public registrar;
//     MockPublicResolver public resolver;
    
//     address public admin = address(0x1);
//     address public kwame = address(0x2);
//     address public ama = address(0x3);
//     address public kofi = address(0x4);
    
//     function setUp() public {
//         // Fund test accounts with ETH first
//         vm.deal(kwame, 10 ether);
//         vm.deal(ama, 10 ether);
//         vm.deal(kofi, 10 ether);
//         vm.deal(admin, 10 ether);
        
//         // Deploy mocks
//         usdc = new MockUSDC();
//         registrar = new MockRegistrarController();
//         resolver = new MockPublicResolver();
        
//         // Deploy factory - make admin the owner
//         vm.prank(admin);
//         factory = new GroupPoolFactory(address(usdc), admin);
        
//         // Update with mock addresses - MUST use admin (the owner)
//         vm.prank(admin);
//         factory.updateRegistrarController(address(registrar));
        
//         vm.prank(admin);
//         factory.updatePublicResolver(address(resolver));
        
//         // Fund test users with USDC
//         usdc.mint(kwame, 1000 * 10**6);
//         usdc.mint(ama, 1000 * 10**6);
//         usdc.mint(kofi, 1000 * 10**6);
//     }
    
//     function testFullWorkflow() public {
//         console.log("Starting SusuChain CLI Test Workflow...");
        
//         // 1. Create Pool
//         console.log("1. Creating pool...");
//         address[] memory members = new address[](3);
//         members[0] = kwame;
//         members[1] = ama;
//         members[2] = kofi;
        
//         string[] memory ensNames = new string[](3);
//         ensNames[0] = "kwame.base.eth";
//         ensNames[1] = "ama.base.eth";
//         ensNames[2] = "kofi.base.eth";
        
//         vm.prank(kwame);
//         address poolAddress = factory.createPool{value: 0.001 ether}(
//             "FamilySavings",
//             "Our family emergency fund",
//             members,
//             ensNames,
//             100 * 10**6, // 100 USDC
//             IGroupPool.ContributionInterval.WEEKLY,
//             block.timestamp + 30 days
//         );
        
//         console.log("   Pool created:", poolAddress);
        
//         // 2. Get Pool Info
//         IGroupPool pool = IGroupPool(poolAddress);
//         console.log("   Pool name:", pool.poolName());
//         console.log("   Pool ENS:", pool.poolENSName());
//         console.log("   Total members:", pool.totalContributors());
        
//         // 3. Members join pool
//         console.log("2. Members joining pool...");
        
//         vm.prank(kwame);
//         pool.joinPool("kwame.base.eth");
//         console.log("   Kwame joined");
        
//         vm.prank(ama);
//         pool.joinPool("ama.base.eth");
//         console.log("   Ama joined");
        
//         vm.prank(kofi);
//         pool.joinPool("kofi.base.eth");
//         console.log("   Kofi joined");
        
//         // 4. Approve USDC spending
//         console.log("3. Approving USDC...");
        
//         vm.prank(kwame);
//         usdc.approve(poolAddress, 300 * 10**6);
        
//         vm.prank(ama);
//         usdc.approve(poolAddress, 300 * 10**6);
        
//         vm.prank(kofi);
//         usdc.approve(poolAddress, 300 * 10**6);
//         console.log("   USDC approved");
        
//         // 5. Make contributions
//         console.log("4. Making contributions...");
        
//         vm.prank(kwame);
//         pool.contribute();
//         console.log("   Kwame contributed 100 USDC");
        
//         vm.prank(ama);
//         pool.contribute();
//         console.log("   Ama contributed 100 USDC");
        
//         vm.prank(kofi);
//         pool.contribute();
//         console.log("   Kofi contributed 100 USDC");
        
//         // 6. Check pool state
//         console.log("5. Checking pool state...");
//         console.log("   Total funds:", pool.totalFunds() / 10**6, "USDC");
//         console.log("   Kwame contributions:", pool.getContributionCount(kwame));
//         console.log("   Ama contributions:", pool.getContributionCount(ama));
//         console.log("   Kofi contributions:", pool.getContributionCount(kofi));
        
//         // 7. Fast forward to maturity
//         console.log("6. Fast forwarding to maturity...");
//         vm.warp(block.timestamp + 31 days);
//         console.log("   Pool matured");
        
//         // 8. Withdraw funds
//         console.log("7. Withdrawing funds...");
        
//         uint256 kwameBefore = usdc.balanceOf(kwame);
//         vm.prank(kwame);
//         pool.withdraw();
//         uint256 kwameAfter = usdc.balanceOf(kwame);
//         console.log("   Kwame withdrew:", (kwameAfter - kwameBefore) / 10**6, "USDC");
        
//         uint256 amaBefore = usdc.balanceOf(ama);
//         vm.prank(ama);
//         pool.withdraw();
//         uint256 amaAfter = usdc.balanceOf(ama);
//         console.log("   Ama withdrew:", (amaAfter - amaBefore) / 10**6, "USDC");
        
//         uint256 kofiBefore = usdc.balanceOf(kofi);
//         vm.prank(kofi);
//         pool.withdraw();
//         uint256 kofiAfter = usdc.balanceOf(kofi);
//         console.log("   Kofi withdrew:", (kofiAfter - kofiBefore) / 10**6, "USDC");
        
//         console.log("SUCCESS! Full workflow completed!");
//         console.log("=================================");
//     }
    
//     function run() external {
//         testFullWorkflow();
//     }
// }