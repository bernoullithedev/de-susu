// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import "@openzeppelin/contracts/proxy/Clones.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/ReentrancyGuard.sol";
import "./GroupPool.sol";
import "./IGroupPool.sol";
import "../PersonalVault/interfaces/IPublicResolver.sol";
import "../PersonalVault/interfaces/IRegistrarController.sol";


// Interface imported from PersonalVault/interfaces/IRegistrarController.sol

/**
 * @title GroupPoolFactory
 * @dev Factory contract for creating GroupPool instances with ENS integration
 * This contract enables the creation of savings pools with human-readable ENS names
 * Built for SusuChain - Decentralized Savings for Africa on Base L2
 * Key Features:
 * - Minimal proxy pattern for gas-efficient pool creation
 * - Automatic ENS registration for each pool
 * - Social login integration via Base Account
 * - Gasless transactions support via Base Paymaster
 */
contract GroupPoolFactory is Ownable, ReentrancyGuard {
    using Clones for address;
    
    // Implementation contract address for GroupPool (used for minimal proxy pattern)
    address public implementation;
    
    // USDC token address (stablecoin used for contributions)
    address public usdcToken;
    
    // Basenames contracts on Base Sepolia (update for mainnet if needed)
    // These enable ENS registration on Base network
    address public registrarController = 0x49aE3cC2e3AA768B1e5654f5D3C6002144A59581;
    address public publicResolver = 0x85C87e548091f204C2d0350b39ce1874f02197c6;
    
    // Track all created pools for discovery and analytics
    address[] public allPools;
    
    // Mapping from pool address to ENS name for easy lookup
    mapping(address => string) public poolENSNames;
    
    // Events for frontend integration and monitoring
    event PoolCreated(address indexed poolAddress, string name, address creator, string ensName);
    event ENSNameRegistered(address indexed poolAddress, string ensName);
    
    /**
     * @dev Constructor initializes the factory with required parameters
     * @param _usdcToken Address of USDC token contract
     * @param initialOwner Owner address for administrative functions
     * Deploys a new GroupPool implementation for cloning
     */
    constructor(
        address _usdcToken,
        address initialOwner,
        address _registrarController,
        address _publicResolver
    ) Ownable(initialOwner) {
        usdcToken = _usdcToken;
        registrarController = _registrarController;
        publicResolver = _publicResolver;
        // Deploy implementation contract for minimal proxy pattern
        implementation = address(new GroupPool());
    }
    
    /**
     * @dev Sanitizes names for ENS compatibility
     * @param _name Input name to sanitize
     * @return sanitized name in lowercase with only alphanumeric chars and hyphens
     * This ensures ENS names follow the required format standards
     */
    function sanitizeName(string memory _name) internal pure returns (string memory) {
        bytes memory nameBytes = bytes(_name);
        bytes memory sanitized = new bytes(nameBytes.length);
        uint256 len = 0;
        
        for (uint256 i = 0; i < nameBytes.length; i++) {
            bytes1 char = nameBytes[i];
            if (char >= 0x41 && char <= 0x5A) { // A-Z to lowercase
                sanitized[len] = bytes1(uint8(char) + 32);
                len++;
            } else if (
                (char >= 0x30 && char <= 0x39) || // 0-9
                (char >= 0x61 && char <= 0x7A) || // a-z
                char == 0x2D // hyphen -
            ) {
                sanitized[len] = char;
                len++;
            } else if (char == 0x20) { // space to hyphen
                sanitized[len] = 0x2D;
                len++;
            }
            // Ignore invalid chars
        }
        
        // Trim to new length
        assembly { mstore(sanitized, len) }
        return string(sanitized);
    }
    
    /**
     * @dev Main function to create a new group pool with ENS registration
     * @param _name Name of the pool (will be used for ENS label)
     * @param _description Description of the pool purpose
     * @param _members Array of member addresses
     * @param _ensNames Array of ENS names for members (for reputation system)
     * @param _contributionAmount USDC amount each member contributes per interval
     * @param _contributionInterval Frequency of contributions (Daily, Weekly, Monthly)
     * @param _maturityDate Timestamp when pool matures and funds can be distributed
     * @return pool Address of the newly created GroupPool contract
     * 
     * This function:
     * 1. Validates input parameters
     * 2. Sanitizes and checks ENS name availability
     * 3. Creates minimal proxy (cheap deployment)
     * 4. Registers ENS name with resolver data
     * 5. Initializes the pool contract
     * 6. Emits events for frontend tracking
     * 
     * Payable to forward ENS registration fees to Basenames contract
     */
    function createPool(
        string memory _name,
        string memory _description,
        address[] memory _members,
        string[] memory _ensNames,
        uint256 _contributionAmount,
        IGroupPool.ContributionInterval _contributionInterval,
        uint256 _maturityDate
    ) external payable nonReentrant returns (address pool) {
        require(_members.length > 0, "No members provided");
        require(_members.length == _ensNames.length, "Members and ENS names mismatch");
        require(_contributionAmount > 0, "Invalid contribution amount");
        require(_maturityDate > block.timestamp, "Maturity date must be in future");
        
        // Compute label and full ENS name (e.g., "myfamily" -> "myfamily.base.eth")
        string memory label = sanitizeName(_name);
        string memory ensName = string(abi.encodePacked(label, ".base.eth"));
        
        // Check ENS name availability and compute registration price
        require(IRegistrarController(registrarController).available(label), "Name not available");
        uint256 duration = 31557600; // 1 year registration
        uint256 price = IRegistrarController(registrarController).rentPrice(label, duration);
        require(msg.value >= price, "Insufficient registration fee");
        
        // Create minimal proxy (gas-efficient deployment using EIP-1167)
        pool = Clones.clone(implementation);
        
        // Prepare resolver data for ENS record setup
        bytes32 node = keccak256(abi.encodePacked(keccak256(abi.encodePacked("base.eth")), keccak256(abi.encodePacked(label))));
        bytes[] memory data = new bytes[](4);
        
        // Set address record to point to the pool contract
        data[0] = abi.encodeCall(IPublicResolver.setAddr, (node, pool));
        
        // Set name record for the ENS node
        data[1] = abi.encodeCall(IPublicResolver.setName, (node, ensName));
        
        // Set description text record for metadata
        data[2] = abi.encodeCall(IPublicResolver.setText, (node, "description", "SusuChain Group Pool"));
        
        // Set protocol text record for identification
        data[3] = abi.encodeCall(IPublicResolver.setText, (node, "protocol", "SusuChain"));
        
        // Register ENS name with Basenames registrar (external call)
        IRegistrarController(registrarController).register{value: price}(
            label,
            pool, // Pool contract owns the ENS name
            duration,
            publicResolver,
            data,
            true // Set reverse record for discoverability
        );
        
        // Update state after external call (following Checks-Effects-Interactions pattern)
        poolENSNames[pool] = ensName;
        allPools.push(pool);
        
        emit ENSNameRegistered(pool, ensName);
        
        // Initialize the pool contract with all parameters
        IGroupPool(pool).initialize(
            _name,
            _description,
            msg.sender, // Creator becomes pool admin
            _members,
            _ensNames,
            _contributionAmount,
            _contributionInterval,
            _maturityDate,
            usdcToken,
            publicResolver,
            ensName 
        );
        
        emit PoolCreated(pool, _name, msg.sender, ensName);
        
        // Refund excess fee if user sent more than required
        if (msg.value > price) {
            payable(msg.sender).transfer(msg.value - price);
        }
        
        return pool;
    }
    
    /**
     * @dev Get ENS name for a specific pool
     * @param poolAddress Address of the pool contract
     * @return ENS name associated with the pool
     */
    function getPoolENS(address poolAddress) external view returns (string memory) {
        return poolENSNames[poolAddress];
    }
    
    /**
     * @dev Get total number of pools created
     * @return count of all pools created through this factory
     */
    function totalPools() external view returns (uint256) {
        return allPools.length;
    }
    
    /**
     * @dev Get addresses of all created pools
     * @return array of all pool addresses
     * Useful for discovery and analytics dashboards
     */
    function getAllPools() external view returns (address[] memory) {
        return allPools;
    }
    
    // ============ ADMIN FUNCTIONS ============
    // These functions allow protocol upgrades and maintenance
    
    /**
     * @dev Update implementation contract (only owner)
     * @param _newImplementation Address of new GroupPool implementation
     * Allows upgrading pool logic for all future creations
     */
    function updateImplementation(address _newImplementation) external onlyOwner {
        implementation = _newImplementation;
    }
    
    /**
     * @dev Update USDC token address (only owner)
     * @param _newUsdcToken New USDC token address
     * Useful if migrating to different stablecoin or token upgrade
     */
    function updateUsdcToken(address _newUsdcToken) external onlyOwner {
        usdcToken = _newUsdcToken;
    }
    
    /**
     * @dev Update registrar controller (only owner)
     * @param _newRegistrar New Basenames registrar address
     * Required when moving from testnet to mainnet or registrar upgrades
     */
    function updateRegistrarController(address _newRegistrar) external onlyOwner {
        registrarController = _newRegistrar;
    }
    
    /**
     * @dev Update public resolver (only owner)
     * @param _newResolver New ENS resolver address
     * Allows switching to different resolver implementation
     */
    function updatePublicResolver(address _newResolver) external onlyOwner {
        publicResolver = _newResolver;
    }
    
    // Allow contract to receive ETH for ENS registration fees
    receive() external payable {}
}