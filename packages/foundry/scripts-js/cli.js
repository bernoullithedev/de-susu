// scripts/cli.js
const commands = {
  createPool: async (name, description, interval, amount) => {
    const tx = await factory.createPool(name, description, [], [], amount, interval, futureDate);
    console.log(`✅ Pool created: ${tx.address}`);
  },
  
  addMember: async (poolAddress, memberAddress, ensName) => {
    // Would need to be called by pool owner
    const pool = await ethers.getContractAt("GroupPool", poolAddress);
    await pool.addMember(memberAddress, ensName);
    console.log(`✅ Member added: ${ensName}`);
  },
  
  joinPool: async (poolAddress, ensName) => {
    const pool = await ethers.getContractAt("GroupPool", poolAddress);
    await pool.joinPool(ensName);
    console.log(`✅ Joined pool as: ${ensName}`);
  },
  
  contribute: async (poolAddress) => {
    const pool = await ethers.getContractAt("GroupPool", poolAddress);
    await usdc.approve(poolAddress, contributionAmount);
    await pool.contribute();
    console.log(`✅ Contributed to pool`);
  }
};