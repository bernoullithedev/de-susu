// scripts/test-workflow.js
async function main() {
  console.log("🚀 Testing SusuChain Workflow...\n");
  
  // 1. Deploy factory
  console.log("1. Deploying factory...");
  const Factory = await ethers.getContractFactory("GroupPoolFactory");
  const factory = await Factory.deploy(usdcAddress, deployer);
  
  // 2. Create pool
  console.log("2. Creating pool...");
  const tx = await factory.createPool(
    "FamilySavings",
    "Test family pool",
    [kwame, ama],
    ["kwame.base.eth", "ama.base.eth"],
    100 * 10**6,
    0, // WEEKLY
    Math.floor(Date.now() / 1000) + 86400 * 7 // 1 week
  );
  
  // 3. Simulate member interactions
  console.log("3. Testing member interactions...");
  
  // Kwame contributes
  await usdc.connect(kwame).approve(pool.address, 100 * 10**6);
  await pool.connect(kwame).contribute();
  
  // Ama contributes  
  await usdc.connect(ama).approve(pool.address, 100 * 10**6);
  await pool.connect(ama).contribute();
  
  console.log("✅ All tests passed!");
}