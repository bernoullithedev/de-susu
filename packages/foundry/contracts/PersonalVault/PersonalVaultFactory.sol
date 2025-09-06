// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import "@openzeppelin/contracts/proxy/Clones.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "./PersonalVault.sol";

contract PersonalVaultFactory is Ownable {
    using Clones for address;
    
    address[] public allVaults;
    mapping(address => address[]) public userVaults;
    address public immutable implementation;
    address public immutable usdc;
    
    event VaultCreated(address indexed user, address vaultAddress, string vaultName);

    constructor(address _usdc) Ownable(msg.sender) {
        implementation = address(new PersonalVault());
        usdc = _usdc;
    }

    function createVault(uint256 _lockDuration, string memory _vaultName) external returns (address) {
        require(bytes(_vaultName).length > 0, "Empty vault name");
        
        address vault = implementation.clone();
        
        PersonalVault(vault).initialize(
            msg.sender,
            _lockDuration,
            usdc,
            _vaultName
        );

        allVaults.push(vault);
        userVaults[msg.sender].push(vault);
        
        emit VaultCreated(msg.sender, vault, _vaultName);
        return vault;
    }

    function getUserVaults(address _user) external view returns (address[] memory) {
        return userVaults[_user];
    }
    
    function getVaultCount() external view returns (uint256) {
        return allVaults.length;
    }
}