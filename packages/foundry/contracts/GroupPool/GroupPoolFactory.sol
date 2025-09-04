// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import "@openzeppelin/contracts/proxy/Clones.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/ReentrancyGuard.sol";
import "./GroupPool.sol";
import "./IGroupPool.sol";
import "./IPublicResolver.sol";


// Interface for Basenames RegistrarController (from Base repo)
interface IRegistrarController {
    function available(string calldata name) external view returns (bool);
    function rentPrice(string calldata name, uint256 duration) external view returns (uint256);
    function register(
        string calldata name,
        address owner,
        uint256 duration,
        address resolver,
        bytes[] calldata data,
        bool reverseRecord
    ) external payable;
}

// Interface for PublicResolver
// interface IPublicResolver {
//     function setAddr(bytes32 node, address addr) external;
//     function setName(bytes32 node, string calldata name) external;
//     function setText(bytes32 node, string calldata key, string calldata value) external;
// }

contract GroupPoolFactory is Ownable, ReentrancyGuard {
    using Clones for address;
    
    // Implementation contract address
    address public implementation;
    
    // USDC token address
    address public usdcToken;
    
    // Basenames contracts on Base Sepolia (update for mainnet if needed)
    address public registrarController = 0x49aE3cC2e3AA768B1e5654f5D3C6002144A59581;
    address public publicResolver = 0x85C87e548091f204C2d0350b39ce1874f02197c6;
    
    // Track all created pools
    address[] public allPools;
    
    // Mapping from pool address to ENS name
    mapping(address => string) public poolENSNames;
    
    // Events
    event PoolCreated(address indexed poolAddress, string name, address creator, string ensName);
    event ENSNameRegistered(address indexed poolAddress, string ensName);
    
    constructor(
        address _usdcToken,
        address initialOwner
    ) Ownable(initialOwner) {
        usdcToken = _usdcToken;
        implementation = address(new GroupPool());
    }
    
    // Sanitize name for ENS compatibility (lowercase, alphanumeric + hyphen)
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
    
    // Create a new group pool with ENS registration (payable to forward fee)
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
        
        // Compute label and full ENS name
        string memory label = sanitizeName(_name);
        string memory ensName = string(abi.encodePacked(label, ".base.eth"));
        
        // Check availability and compute price
        require(IRegistrarController(registrarController).available(label), "Name not available");
        uint256 duration = 31557600; // 1 year
        uint256 price = IRegistrarController(registrarController).rentPrice(label, duration);
        require(msg.value >= price, "Insufficient registration fee");
        
        // Create minimal proxy
        pool = Clones.clone(implementation);
        
        // Prepare resolver data (encoded calls to set records)
        bytes32 node = keccak256(abi.encodePacked(keccak256(abi.encodePacked("base.eth")), keccak256(abi.encodePacked(label))));
        bytes[] memory data = new bytes[](4);
        
        // setAddr(node, pool)
        data[0] = abi.encodeCall(IPublicResolver.setAddr, (node, pool));
        
        // setName(node, ensName)
        data[1] = abi.encodeCall(IPublicResolver.setName, (node, ensName));
        
        // setText(node, "description", "SusuChain Group Pool")
        data[2] = abi.encodeCall(IPublicResolver.setText, (node, "description", "SusuChain Group Pool"));
        
        // Additional texts
        data[3] = abi.encodeCall(IPublicResolver.setText, (node, "protocol", "SusuChain"));
        
        // Register ENS name (external call first)
        IRegistrarController(registrarController).register{value: price}(
            label,
            pool, // Owner is the pool
            duration,
            publicResolver,
            data,
            true // Set reverse record
        );
        
        // Update state after external call (Checks-Effects-Interactions pattern)
        poolENSNames[pool] = ensName;
        allPools.push(pool);
        
        emit ENSNameRegistered(pool, ensName);
        
        // Initialize the pool (trusted call after state updates)
        IGroupPool(pool).initialize(
            _name,
            _description,
            msg.sender,
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
        
        // Refund excess fee if any
        if (msg.value > price) {
            payable(msg.sender).transfer(msg.value - price);
        }
        
        return pool;
    }
    
    // Get ENS name for a pool
    function getPoolENS(address poolAddress) external view returns (string memory) {
        return poolENSNames[poolAddress];
    }
    
    // Get total number of pools created
    function totalPools() external view returns (uint256) {
        return allPools.length;
    }
    
    // Get all pools
    function getAllPools() external view returns (address[] memory) {
        return allPools;
    }
    
    // Update implementation (only owner)
    function updateImplementation(address _newImplementation) external onlyOwner {
        implementation = _newImplementation;
    }
    
    // Update USDC token address (only owner)
    function updateUsdcToken(address _newUsdcToken) external onlyOwner {
        usdcToken = _newUsdcToken;
    }
    
    // Update registrar controller (only owner, e.g., for mainnet switch)
    function updateRegistrarController(address _newRegistrar) external onlyOwner {
        registrarController = _newRegistrar;
    }
    
    // Update public resolver (only owner)
    function updatePublicResolver(address _newResolver) external onlyOwner {
        publicResolver = _newResolver;
    }
    
    // Allow contract to receive ETH for registration fees
    receive() external payable {}
}