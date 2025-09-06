// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts-upgradeable/proxy/utils/Initializable.sol";
import "@openzeppelin/contracts-upgradeable/proxy/utils/UUPSUpgradeable.sol";
import "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
import "@openzeppelin/contracts-upgradeable/utils/ReentrancyGuardUpgradeable.sol";

contract PersonalVault is Initializable, UUPSUpgradeable, ReentrancyGuardUpgradeable {
    using SafeERC20 for IERC20;
    
    address public owner;
    uint256 public lockDuration;
    uint256 public createdAt;
    IERC20 public usdc;
    string public vaultName;
    uint256 public totalDeposited;
    
    // CID storage for Filecoin metadata
    mapping(uint256 => string) public depositCids;
    uint256 public depositCount;
    
    // Events
    event VaultInitialized(address indexed owner, uint256 lockDuration, string vaultName);
    event Deposited(address indexed user, uint256 amount, string cid, uint256 depositId);
    event Withdrawn(address indexed user, uint256 amount);
    event EarlyWithdrawalAttempt(address indexed user, uint256 attemptedAmount);
    event CidUpdated(uint256 depositId, string cid);

    /// @custom:oz-upgrades-unsafe-allow constructor
    constructor() {
        _disableInitializers();
    }

    function initialize(
        address _owner, 
        uint256 _lockDuration, 
        address _usdc,
        string memory _vaultName
    ) public initializer {
        __UUPSUpgradeable_init();
        __ReentrancyGuard_init();
        owner = _owner;
        lockDuration = _lockDuration;
        createdAt = block.timestamp;
        usdc = IERC20(_usdc);
        vaultName = _vaultName;
        depositCount = 0;
        
        emit VaultInitialized(owner, _lockDuration, _vaultName);
    }

    function deposit(uint256 _amount, string memory _cid) external {
        require(msg.sender == owner, "Not owner");
        require(_amount > 0, "Amount must be greater than 0");
        require(bytes(_cid).length > 0, "CID cannot be empty");
        
        usdc.safeTransferFrom(msg.sender, address(this), _amount);
        totalDeposited += _amount;
        
        // Store CID for Filecoin reference
        depositCids[depositCount] = _cid;
        
        emit Deposited(msg.sender, _amount, _cid, depositCount);
        depositCount++;
    }

    // Alternative deposit without CID (backward compatibility)
    function deposit(uint256 _amount) external {
        require(msg.sender == owner, "Not owner");
        require(_amount > 0, "Amount must be greater than 0");
        
        usdc.safeTransferFrom(msg.sender, address(this), _amount);
        totalDeposited += _amount;
        
        emit Deposited(msg.sender, _amount, "", depositCount);
        depositCount++;
    }

    function updateCid(uint256 _depositId, string memory _cid) external {
        require(msg.sender == owner, "Not owner");
        require(_depositId < depositCount, "Invalid deposit ID");
        require(bytes(_cid).length > 0, "CID cannot be empty");
        
        depositCids[_depositId] = _cid;
        emit CidUpdated(_depositId, _cid);
    }

    function withdraw() external nonReentrant {
        require(msg.sender == owner, "Not owner");
        require(block.timestamp >= createdAt + lockDuration, "Funds are locked until maturity");
        
        uint256 balance = usdc.balanceOf(address(this));
        require(balance > 0, "No funds to withdraw");
        
        usdc.safeTransfer(owner, balance);
        emit Withdrawn(msg.sender, balance);
    }

    function getCid(uint256 _depositId) external view returns (string memory) {
        require(_depositId < depositCount, "Invalid deposit ID");
        return depositCids[_depositId];
    }

    function getDepositCount() external view returns (uint256) {
        return depositCount;
    }

    function isMature() public view returns (bool) {
        return block.timestamp >= createdAt + lockDuration;
    }

    function timeUntilMaturity() public view returns (uint256) {
        if (isMature()) {
            return 0;
        }
        return (createdAt + lockDuration) - block.timestamp;
    }

    function getBalance() external view returns (uint256) {
        return usdc.balanceOf(address(this));
    }
    
    function getLockEndTime() external view returns (uint256) {
        return createdAt + lockDuration;
    }

    function _authorizeUpgrade(address newImplementation) internal override onlyOwner {}

    modifier onlyOwner() {
        require(msg.sender == owner, "Not owner");
        _;
    }
}