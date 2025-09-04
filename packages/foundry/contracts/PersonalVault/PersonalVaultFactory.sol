// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import "./interfaces/IPersonalVault.sol";
import "./PersonalVault.sol";
import "@openzeppelin/contracts/proxy/Clones.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "./interfaces/IPublicResolver.sol";
import "./interfaces/IRegistrarController.sol";

contract PersonalVaultFactory is Ownable {
    using Clones for address;
    
    address[] public allVaults;
    mapping(address => address[]) public userVaults;
    address public immutable implementation;
    address public immutable usdc;
    
    // Base Sepolia addresses
    address public registrarController;
    address public publicResolver;
    
    event VaultCreated(address indexed user, address vaultAddress, string ensName);

    constructor(address _usdc, address _registrarController, address _publicResolver) Ownable(msg.sender) {
        // Deploy the implementation contract once
        implementation = address(new PersonalVault());
        usdc = _usdc;
        registrarController = _registrarController;
        publicResolver = _publicResolver;
    }

    function createVault(uint256 _lockDuration, string memory _vaultName) external payable returns (address) {
        // Sanitize name and create ENS name (checks)
        string memory label = sanitizeName(_vaultName);
        string memory ensName = string(abi.encodePacked(label, ".base.eth"));
        
        // Check availability and compute price (checks)
        require(IRegistrarController(registrarController).available(label), "Name not available");
        uint256 duration = 31557600; // 1 year
        uint256 price = IRegistrarController(registrarController).rentPrice(label, duration);
        require(msg.value >= price, "Insufficient registration fee");
        
        // Create a new proxy for the user (effects start)
        address vault = implementation.clone();
        
        // Initialize the vault (safe internal call, as it's our code)
        bytes memory initData = abi.encodeCall(
            IPersonalVault.initialize,
            (msg.sender, _lockDuration, usdc, publicResolver, ensName)
        );
        (bool success, ) = vault.call(initData);
        require(success, "Initialization failed");

        // Store the vault and emit event (effects complete)
        allVaults.push(vault);
        userVaults[msg.sender].push(vault);
        emit VaultCreated(msg.sender, vault, ensName);
        
        // Register ENS name (external interaction)
        bytes32 node = keccak256(abi.encodePacked(keccak256(abi.encodePacked("base.eth")), keccak256(abi.encodePacked(label))));
        bytes[] memory data = new bytes[](3);
        
        data[0] = abi.encodeCall(IPublicResolver.setAddr, (node, vault));
        data[1] = abi.encodeCall(IPublicResolver.setName, (node, ensName));
        data[2] = abi.encodeCall(IPublicResolver.setText, (node, "protocol", "SusuChain Personal Vault"));
        
        IRegistrarController(registrarController).register{value: price}(
            label,
            vault, // Owner is the vault itself
            duration,
            publicResolver,
            data,
            true
        );
        
        // Refund excess ETH (safe last step)
        if (msg.value > price) {
            (bool refundSuccess, ) = payable(msg.sender).call{value: msg.value - price}("");
            require(refundSuccess, "Refund failed");
        }

        return vault;
    }

    // Sanitize name for ENS compatibility
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
        }
        
        assembly { mstore(sanitized, len) }
        return string(sanitized);
    }

    function getUserVaults(address _user) external view returns (address[] memory) {
        return userVaults[_user];
    }
    
    function getVaultCount() external view returns (uint256) {
        return allVaults.length;
    }

    function updateRegistrarController(address _newRegistrar) external onlyOwner {
        registrarController = _newRegistrar;
    }

    function updatePublicResolver(address _newResolver) external onlyOwner {
        publicResolver = _newResolver;
    }

    // Allow contract to receive ETH for registration fees
    receive() external payable {}
}