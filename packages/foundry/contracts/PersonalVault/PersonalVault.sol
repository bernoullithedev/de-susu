// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts-upgradeable/proxy/utils/Initializable.sol";
import "@openzeppelin/contracts-upgradeable/proxy/utils/UUPSUpgradeable.sol";
import "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
import "@openzeppelin/contracts-upgradeable/utils/ReentrancyGuardUpgradeable.sol";
import "./interfaces/IPublicResolver.sol";

contract PersonalVault is Initializable, UUPSUpgradeable, ReentrancyGuardUpgradeable {
    using SafeERC20 for IERC20;
    address public owner;
    uint256 public lockDuration;
    uint256 public createdAt;
    IERC20 public usdc;
    string public vaultENSName;
    address public publicResolver;
    bytes32 public ensNode;
    
    // Events
    event VaultInitialized(address indexed owner, uint256 lockDuration, string ensName);
    event Deposited(address indexed user, uint256 amount);
    event Withdrawn(address indexed user, uint256 amount);
    event ENSRecordUpdated(string ensName, string key, string value);
    event EarlyWithdrawalAttempt(address indexed user, uint256 attemptedAmount);

    /// @custom:oz-upgrades-unsafe-allow constructor
    constructor() {
        _disableInitializers(); // Lock the implementation contract
    }

    function initialize(
        address _owner, 
        uint256 _lockDuration, 
        address _usdc,
        address _publicResolver,
        string memory _vaultENSName,
        bytes32 _parentNamehash // NEW: Pass the namehash of the parent domain (e.g., namehash("de-susu-demo.base.eth"))
    ) public initializer {
        __UUPSUpgradeable_init();
        __ReentrancyGuard_init();
        owner = _owner;
        lockDuration = _lockDuration;
        createdAt = block.timestamp;
        usdc = IERC20(_usdc);
        publicResolver = _publicResolver;
        vaultENSName = _vaultENSName;
        
        // Compute ENS node hash CORRECTLY for a subdomain
        string memory label = _extractLabelFromFullName(_vaultENSName);
        bytes32 labelHash = keccak256(abi.encodePacked(label));
        // This is the correct way to calculate the node for a subdomain
        ensNode = keccak256(abi.encodePacked(_parentNamehash, labelHash));
        
        // Set initial text records
        _setTextRecord("description", "Personal Savings Vault");
        _setTextRecord("lockDuration", _uintToString(_lockDuration));
        _setTextRecord("maturityDate", _uintToString(createdAt + _lockDuration));
        _setTextRecord("status", "active");
        
        emit VaultInitialized(owner, _lockDuration, _vaultENSName);
    }

    function deposit(uint256 _amount) external {
        require(msg.sender == owner, "Not owner");
        require(_amount > 0, "Amount must be greater than 0");
        
        // Transfer USDC from user to this contract
        usdc.safeTransferFrom(msg.sender, address(this), _amount);
        
        // Update ENS record with new balance
        _setTextRecord("balance", _uintToString(usdc.balanceOf(address(this))));
        _setTextRecord("totalDeposited", _uintToString(usdc.balanceOf(address(this))));
        
        emit Deposited(msg.sender, _amount);
    }

    function withdraw() external nonReentrant {
        require(msg.sender == owner, "Not owner");
        require(block.timestamp >= createdAt + lockDuration, "Funds are locked until maturity");
        
        uint256 balance = usdc.balanceOf(address(this));
        require(balance > 0, "No funds to withdraw");
        
        // Transfer all funds to owner
        usdc.safeTransfer(owner, balance);
        
        // Update ENS records
        _setTextRecord("balance", "0");
        _setTextRecord("status", "withdrawn");
        _setTextRecord("withdrawnAt", _uintToString(block.timestamp));
        _setTextRecord("amountWithdrawn", _uintToString(balance));
        
        emit Withdrawn(msg.sender, balance);
    }

    // View function to check if vault is mature
    function isMature() public view returns (bool) {
        return block.timestamp >= createdAt + lockDuration;
    }

    // View function to get time until maturity
    function timeUntilMaturity() public view returns (uint256) {
        if (isMature()) {
            return 0;
        }
        return (createdAt + lockDuration) - block.timestamp;
    }

    // Internal helper to extract label from full name
    function _extractLabelFromFullName(string memory fullName) internal pure returns (string memory) {
        bytes memory nameBytes = bytes(fullName);
        uint256 dotIndex = nameBytes.length;
        for (uint256 i = 0; i < nameBytes.length; i++) {
            if (nameBytes[i] == ".") {
                dotIndex = i;
                break;
            }
        }
        bytes memory labelBytes = new bytes(dotIndex);
        for (uint256 i = 0; i < dotIndex; i++) {
            labelBytes[i] = nameBytes[i];
        }
        return string(labelBytes);
    }

    // Internal function to set ENS text record
    function _setTextRecord(string memory key, string memory value) internal {
        IPublicResolver(publicResolver).setText(ensNode, key, value);
        emit ENSRecordUpdated(vaultENSName, key, value);
    }

    // Helper to convert uint to string
    function _uintToString(uint256 value) internal pure returns (string memory) {
        if (value == 0) return "0";
        uint256 temp = value;
        uint256 digits;
        while (temp != 0) {
            digits++;
            temp /= 10;
        }
        bytes memory buffer = new bytes(digits);
        while (value != 0) {
            digits -= 1;
            buffer[digits] = bytes1(uint8(48 + uint256(value % 10)));
            value /= 10;
        }
        return string(buffer);
    }

    function getBalance() external view returns (uint256) {
        return usdc.balanceOf(address(this));
    }
    
    function getLockEndTime() external view returns (uint256) {
        return createdAt + lockDuration;
    }

    // Required function for UUPS upgradability
    function _authorizeUpgrade(address newImplementation) internal override onlyOwner {}

    modifier onlyOwner() {
        require(msg.sender == owner, "Not owner");
        _;
    }
}