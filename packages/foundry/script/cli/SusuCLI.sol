// // SPDX-License-Identifier: MIT
// pragma solidity ^0.8.19;

// import "forge-std/Script.sol";
// import "forge-std/console.sol";
// import "../../contracts/PersonalVault/PersonalVaultFactory.sol";
// import "../../contracts/PersonalVault/PersonalVault.sol";
// import "solmate/tokens/ERC20.sol";

// contract SusuCLI is Script {
//     PersonalVaultFactory public factory;
//     ERC20 public usdc;
    
//     function run() external {
//         // Load deployed factory address or deploy new one
//         address factoryAddress = vm.envOr("FACTORY_ADDRESS", address(0));
        
//         if (factoryAddress == address(0)) {
//             console.log("No factory address found. Deploying new one...");
//             deployFactory();
//         } else {
//             console.log("Using existing factory:", factoryAddress);
//             // Fix: Cast address to the contract type
//             factory = PersonalVaultFactory(payable(factoryAddress));
//             usdc = ERC20(factory.usdc());
//         }
        
//         // Main menu
//         while (true) {
//             console.log("\n=== SusuChain CLI ===");
//             console.log("1. Create Personal Vault");
//             console.log("2. Deposit to Vault");
//             console.log("3. Withdraw from Vault");
//             console.log("4. Check Vault Balance");
//             console.log("5. List My Vaults");
//             console.log("6. Exit");
            
//             string memory choice = vm.readLine("Choose option: ");
            
//             if (vm.parseUint(choice) == 1) {
//                 createVault();
//             } else if (vm.parseUint(choice) == 2) {
//                 depositToVault();
//             } else if (vm.parseUint(choice) == 3) {
//                 withdrawFromVault();
//             } else if (vm.parseUint(choice) == 4) {
//                 checkBalance();
//             } else if (vm.parseUint(choice) == 5) {
//                 listMyVaults();
//             } else if (vm.parseUint(choice) == 6) {
//                 break;
//             } else {
//                 console.log("Invalid option!");
//             }
//         }
//     }
    
//     function deployFactory() internal {
//         // Use mock addresses for local testing
//         address usdcAddress = address(0x1234567890123456789012345678901234567890);
//         address registrarController = 0x49aE3cC2e3AA768B1e5654f5D3C6002144A59581; // Mock for local
//         address publicResolver = 0x85C87e548091f204C2d0350b39ce1874f02197c6; // Mock for local
        
//         vm.startBroadcast();
//         factory = new PersonalVaultFactory(usdcAddress, registrarController, publicResolver);
//         vm.stopBroadcast();
        
//         usdc = ERC20(usdcAddress);
//         console.log("Factory deployed at:", address(factory));
//     }
    
//     function createVault() internal {
//         string memory vaultName = vm.readLine("Enter vault name: ");
//         string memory lockDaysStr = vm.readLine("Lock duration (days): ");
//         uint256 lockDays = vm.parseUint(lockDaysStr);
//         uint256 lockDuration = lockDays * 1 days;
        
//         uint256 price = 0.001 ether;
//         console.log("Registration fee:", price, "ETH");
        
//         vm.startBroadcast();
//         address vaultAddress = factory.createVault{value: price}(lockDuration, vaultName);
//         vm.stopBroadcast();
        
//         console.log("Vault created at:", vaultAddress);
//         console.log("ENS name:", vaultName, ".base.eth");
//     }
    
//     function depositToVault() internal {
//         address vaultAddress = getVaultAddress();
//         string memory amountStr = vm.readLine("Amount to deposit (USDC): ");
//         uint256 amount = vm.parseUint(amountStr) * 10**6; // Convert to USDC decimals
        
//         console.log("Approving USDC...");
//         vm.startBroadcast();
//         usdc.approve(vaultAddress, amount);
//         vm.stopBroadcast();
        
//         console.log("Depositing...");
//         vm.startBroadcast();
//         PersonalVault(vaultAddress).deposit(amount);
//         vm.stopBroadcast();
        
//         console.log("Deposited", amount / 10**6, "USDC to vault");
//     }
    
//     function withdrawFromVault() internal {
//         address vaultAddress = getVaultAddress();
        
//         console.log("Withdrawing...");
//         vm.startBroadcast();
//         PersonalVault(vaultAddress).withdraw();
//         vm.stopBroadcast();
        
//         console.log("Funds withdrawn from vault");
//     }
    
//     function checkBalance() internal view {
//         address vaultAddress = getVaultAddress();
//         uint256 balance = PersonalVault(vaultAddress).getBalance();
//         console.log("Vault balance:", balance / 10**6, "USDC");
        
//         bool isMature = PersonalVault(vaultAddress).isMature();
//         console.log("Vault is mature:", isMature);
        
//         if (!isMature) {
//             uint256 timeLeft = PersonalVault(vaultAddress).timeUntilMaturity();
//             console.log("Time until maturity:", timeLeft / 1 days, "days");
//         }
//     }
    
//     function listMyVaults() internal view {
//         address user = msg.sender;
//         address[] memory vaults = factory.getUserVaults(user);
        
//         console.log("Your vaults:");
//         for (uint256 i = 0; i < vaults.length; i++) {
//             PersonalVault vault = PersonalVault(vaults[i]);
//             console.log(i + 1, "- Address:", vaults[i]);
//             console.log("  Balance:", vault.getBalance() / 10**6, "USDC");
//             console.log("  Mature:", vault.isMature());
//         }
//     }
    
//     function getVaultAddress() internal view returns (address) {
//         address[] memory vaults = factory.getUserVaults(msg.sender);
//         require(vaults.length > 0, "No vaults found");
        
//         if (vaults.length == 1) {
//             return vaults[0];
//         }
        
//         console.log("Your vaults:");
//         for (uint256 i = 0; i < vaults.length; i++) {
//             console.log(i + 1, "-", vaults[i]);
//         }
        
//         // Fix: Use string.concat for proper concatenation
//         string memory prompt = string.concat(
//             "Select vault (1-", 
//             vm.toString(vaults.length), 
//             "): "
//         );
//         string memory choiceStr = vm.readLine(prompt);
//         uint256 choice = vm.parseUint(choiceStr);
//         require(choice > 0 && choice <= vaults.length, "Invalid choice");
        
//         return vaults[choice - 1];
//     }
// }