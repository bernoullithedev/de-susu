// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import "@openzeppelin/contracts/proxy/Clones.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/token/ERC721/utils/ERC721Holder.sol";
import "./PersonalVault.sol";
import "./interfaces/IENSRegistry.sol";
import "./interfaces/IPublicResolver.sol";

contract PersonalVaultFactory is Ownable, ERC721Holder {
    using Clones for address;
    
    address[] public allVaults;
    mapping(address => address[]) public userVaults;
    address public immutable implementation;
    address public immutable usdc;
    
    IENSRegistry public ensRegistry;
    IPublicResolver public publicResolver;

    bytes32 public parentNamehash;
    string public parentName;
    bool public domainOwnershipTransferred;

    event VaultCreated(address indexed user, address vaultAddress, string ensName);
    event OwnershipTransferredToFactory();

    constructor(
        address _usdc,
        address _ensRegistry,
        address _publicResolver,
        string memory _parentName,
        bytes32 _parentNamehash
    ) Ownable(msg.sender) {
        implementation = address(new PersonalVault());
        usdc = _usdc;
        ensRegistry = IENSRegistry(_ensRegistry);
        publicResolver = IPublicResolver(_publicResolver);
        parentName = _parentName;
        parentNamehash = _parentNamehash;
        domainOwnershipTransferred = false;
    }

    // Function to transfer domain ownership to factory
    function acceptDomainOwnership() external onlyOwner {
        require(!domainOwnershipTransferred, "Domain ownership already transferred");
        
        // Check current owner - should be the deployer initially
        address currentOwner = ensRegistry.owner(parentNamehash);
        require(currentOwner == msg.sender, "Caller is not current domain owner");
        
        // Transfer ownership to this factory contract
        ensRegistry.setOwner(parentNamehash, address(this));
        
        // Verify transfer was successful
        require(ensRegistry.owner(parentNamehash) == address(this), "Ownership transfer failed");
        
        domainOwnershipTransferred = true;
        emit OwnershipTransferredToFactory();
    }

    function createVault(uint256 _lockDuration, string memory _vaultName) external returns (address) {
        require(domainOwnershipTransferred, "Factory not domain owner. Call acceptDomainOwnership() first.");
        require(ensRegistry.owner(parentNamehash) == address(this), "Factory lost domain ownership");
        
        string memory label = sanitizeName(_vaultName);
        require(bytes(label).length > 0, "Empty label");

        string memory fullENSName = string(abi.encodePacked(label, ".", parentName));
        address vault = implementation.clone();

        _createSubnameForVault(label, vault);

        PersonalVault(vault).initialize(
            msg.sender,
            _lockDuration,
            usdc,
            address(publicResolver),
            fullENSName,
            parentNamehash
        );

        allVaults.push(vault);
        userVaults[msg.sender].push(vault);
        emit VaultCreated(msg.sender, vault, fullENSName);

        return vault;
    }

    function _createSubnameForVault(string memory _label, address _vaultAddress) internal {
        bytes32 labelHash = keccak256(abi.encodePacked(_label));
        ensRegistry.setSubnodeOwner(parentNamehash, labelHash, _vaultAddress);
        bytes32 vaultNamehash = keccak256(abi.encodePacked(parentNamehash, labelHash));
        ensRegistry.setResolver(vaultNamehash, address(publicResolver));
    }

    function sanitizeName(string memory _name) internal pure returns (string memory) {
        bytes memory nameBytes = bytes(_name);
        bytes memory sanitized = new bytes(nameBytes.length);
        uint256 len = 0;
        
        for (uint256 i = 0; i < nameBytes.length; i++) {
            bytes1 char = nameBytes[i];
            if (char >= 0x41 && char <= 0x5A) {
                sanitized[len] = bytes1(uint8(char) + 32);
                len++;
            } else if (
                (char >= 0x30 && char <= 0x39) ||
                (char >= 0x61 && char <= 0x7A) ||
                char == 0x2D
            ) {
                sanitized[len] = char;
                len++;
            } else if (char == 0x20) {
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

    function adminSetSubnodeOwner(bytes32 _labelHash, address _newOwner) external onlyOwner {
        require(domainOwnershipTransferred, "Factory not domain owner");
        ensRegistry.setSubnodeOwner(parentNamehash, _labelHash, _newOwner);
    }

    function transferDomainOwnership(address _newOwner) external onlyOwner {
        require(domainOwnershipTransferred, "Factory not domain owner");
        ensRegistry.setOwner(parentNamehash, _newOwner);
        domainOwnershipTransferred = false;
    }
}