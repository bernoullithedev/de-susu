// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import "@openzeppelin/contracts-upgradeable/proxy/utils/UUPSUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/access/OwnableUpgradeable.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
import "./IGroupPool.sol";
import "../PersonalVault/interfaces/IPublicResolver.sol";

/**
 * @title GroupPool
 * @dev Upgradeable savings pool contract for SusuChain
 * Implements rotating savings and credit association (ROSCA) functionality
 * Key Features:
 * - UUPS upgradeable pattern for future protocol improvements
 * - ENS integration for human-readable identity and reputation tracking
 * - Automated contribution scheduling and enforcement
 * - Transparent fund management with on-chain records
 * - Gas-optimized for Base L2 operations
 */
contract GroupPool is IGroupPool, UUPSUpgradeable, OwnableUpgradeable {
    using SafeERC20 for IERC20;

    // Pool configuration - immutable after initialization
    string public override poolName;
    string public override poolDescription;
    address public override creator;
    uint256 public override contributionAmount;
    ContributionInterval public override contributionInterval;
    uint256 public override maturityDate;
    string public override poolENSName; // Pool's Basename (e.g., "familysavings.base.eth")
    
    // Pool state - updated with contributions and withdrawals
    uint256 public override totalContributors;
    uint256 public override totalFunds;
    
    // USDC token address - stablecoin for contributions
    IERC20 public usdcToken;
    
    // ENS-related - for reputation and identity system
    address public publicResolver; // Upgradeable L2PublicResolver proxy on Base Sepolia: 0x85c87E548091F204c2d0350B39Ce1874f02197c6
    bytes32 public ensNode; // Hash of the ENS node for efficient record updates
    
    // Member tracking - comprehensive state for each participant
    struct MemberInfo {
        bool isMember;
        bool hasContributed;
        bool hasWithdrawn;
        uint256 contributionCount;
        uint256 lastContributionDate;
        string ensName; // Member's ENS identity for reputation
    }
    
    mapping(address => MemberInfo) public members;
    mapping(address => uint256) public contributions;
    address[] public membersList;
    
    // Modifiers for access control and state validation
    
    /**
     * @dev Restricts function to pool members only
     */
    modifier onlyMember() {
        require(members[msg.sender].isMember, "Not a pool member");
        _;
    }
    
    /**
     * @dev Ensures function is called before pool maturity
     */
    modifier beforeMaturity() {
        require(block.timestamp < maturityDate, "Pool has matured");
        _;
    }
    
    /**
     * @dev Ensures function is called after pool maturity
     */
    modifier afterMaturity() {
        require(block.timestamp >= maturityDate, "Pool not matured yet");
        _;
    }
    
    // UUPS upgrade authorization - only owner can upgrade implementation
    function _authorizeUpgrade(address newImplementation) internal override onlyOwner {}
    
    /**
     * @dev Initializes the pool contract (called by factory)
     * @param _name Name of the savings pool
     * @param _description Description of pool purpose
     * @param _creator Address of pool creator (becomes owner)
     * @param _members Array of member addresses
     * @param _ensNames Array of ENS names for reputation tracking
     * @param _contributionAmount USDC amount per contribution
     * @param _contributionInterval Frequency of contributions
     * @param _maturityDate Timestamp when pool matures
     * @param _usdcToken USDC token contract address
     * @param _publicResolver ENS resolver address
     * @param _poolENSName Full ENS name for the pool
     * 
     * This function sets up the entire pool structure and initial ENS records
     * Following UUPS upgradeable pattern initialization requirements
     */
    function initialize(
        string memory _name,
        string memory _description,
        address _creator,
        address[] memory _members,
        string[] memory _ensNames,
        uint256 _contributionAmount,
        ContributionInterval _contributionInterval,
        uint256 _maturityDate,
        address _usdcToken,
        address _publicResolver,
        string memory _poolENSName // Basename passed from Factory
    ) external initializer {
        __Ownable_init(_creator);
        __UUPSUpgradeable_init();
        
        // Set pool configuration
        poolName = _name;
        poolDescription = _description;
        creator = _creator;
        contributionAmount = _contributionAmount;
        contributionInterval = _contributionInterval;
        maturityDate = _maturityDate;
        usdcToken = IERC20(_usdcToken);
        poolENSName = _poolENSName;
        
        // Set ENS resolver for reputation system
        publicResolver = _publicResolver;
        
        // Compute ENS node hash for efficient record updates
        string memory label = _extractLabelFromFullName(_poolENSName);
        require(bytes(label).length > 0, "Invalid ENS name format");
        ensNode = keccak256(abi.encodePacked(keccak256(abi.encodePacked("base.eth")), keccak256(abi.encodePacked(label))));
        
        // Initialize members with their ENS identities
        require(_members.length == _ensNames.length, "Members and ENS names mismatch");
        
        for (uint256 i = 0; i < _members.length; i++) {
            members[_members[i]] = MemberInfo({
                isMember: true,
                hasContributed: false,
                hasWithdrawn: false,
                contributionCount: 0,
                lastContributionDate: 0,
                ensName: _ensNames[i]
            });
            membersList.push(_members[i]);
        }
        
        totalContributors = _members.length;
        
        // Set initial ENS records for transparency
        _setTextRecord("description", _description);
        
        emit PoolCreated(
            address(this),
            _name,
            _description,
            _members,
            _ensNames,
            _contributionAmount,
            uint256(_contributionInterval),
            _maturityDate,
            _poolENSName
        );
    }
    
    /**
     * @dev Extracts label from full ENS name
     * @param fullName Full ENS name (e.g., "familysavings.base.eth")
     * @return label portion (e.g., "familysavings")
     * Internal helper for ENS node computation
     */
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
    
    /**
     * @dev Internal function to set ENS text records
     * @param key Record key (e.g., "description", "totalFunds")
     * @param value Record value
     * Used for reputation tracking and pool transparency
     */
    function _setTextRecord(string memory key, string memory value) internal {
        IPublicResolver(publicResolver).setText(ensNode, key, value);
    }
    
    /**
     * @dev Public function to update ENS records
     * @param key Record key to update
     * @param value New record value
     * Only owner can update records for reputation and attestations
     */
    function setTextRecord(string memory key, string memory value) external onlyOwner {
        _setTextRecord(key, value);
        emit ENSRecordUpdated(poolENSName, key, value);
    }
    
    /**
     * @dev Join the pool (formal membership activation)
     * @param ensName Optional ENS name for reputation tracking
     * Members must explicitly join before contributing
     * Allows updating ENS name during join process
     */
    function joinPool(string memory ensName) external override {
        require(members[msg.sender].isMember, "Not allowed to join this pool");
        require(!members[msg.sender].hasContributed, "Already joined and contributed");
        
        // Update ENS name if provided for reputation system
        if (bytes(ensName).length > 0) {
            members[msg.sender].ensName = ensName;
        }
        
        emit MemberJoined(msg.sender, members[msg.sender].ensName);
    }
    
    /**
     * @dev Update ENS name for reputation tracking
     * @param newENSName New ENS name to associate with member
     * Allows members to update their on-chain identity
     */
    function updateENSName(string memory newENSName) external override onlyMember {
        require(bytes(newENSName).length > 0, "ENS name cannot be empty");
        members[msg.sender].ensName = newENSName;
        emit ENSNameUpdated(msg.sender, newENSName);
    }
    
    /**
     * @dev Make a contribution to the pool
     * Enforces contribution schedule and updates ENS records
     * Uses SafeERC20 for secure token transfers
     * Updates reputation system with contribution data
     */
    function contribute() external override onlyMember beforeMaturity {
        MemberInfo storage member = members[msg.sender];
        
        // Enforce contribution schedule
        if (member.lastContributionDate > 0) {
            uint256 nextContributionDate = getNextContributionDate(msg.sender);
            require(block.timestamp >= nextContributionDate, "Not time for next contribution yet");
        }
        
        // Secure USDC transfer using SafeERC20
        usdcToken.safeTransferFrom(msg.sender, address(this), contributionAmount);
        
        // Update member state
        member.hasContributed = true;
        member.contributionCount++;
        member.lastContributionDate = block.timestamp;
        contributions[msg.sender] += contributionAmount;
        totalFunds += contributionAmount;
        
        // Update ENS reputation records
        _setTextRecord("totalFunds", _uintToString(totalFunds));
        _setTextRecord(
            string(abi.encodePacked("member_", _uintToString(uint256(uint160(msg.sender))))),
            _uintToString(contributions[msg.sender])
        );
        _setTextRecord("totalContributions", _uintToString(totalFunds));
            
        emit ContributionMade(msg.sender, contributionAmount, member.contributionCount);
    }
    
    /**
     * @dev Withdraw funds after pool maturity
     * Calculates proportional share based on contributions
     * Updates ENS records to reflect withdrawal
     * Prevents double-spending with hasWithdrawn flag
     */
    function withdraw() external override onlyMember afterMaturity {
        MemberInfo storage member = members[msg.sender];
        require(member.hasContributed, "No contributions to withdraw");
        require(!member.hasWithdrawn, "Already withdrawn");
        
        uint256 withdrawableAmount = getWithdrawableAmount(msg.sender);
        require(withdrawableAmount > 0, "No funds available to withdraw");
        
        // Mark as withdrawn to prevent re-entrancy
        member.hasWithdrawn = true;
        
        // Secure USDC transfer
        usdcToken.safeTransfer(msg.sender, withdrawableAmount);
        
        totalFunds -= withdrawableAmount;
        
        // Update ENS records post-withdrawal
        _setTextRecord("totalFunds", _uintToString(totalFunds));
        
        emit Withdrawal(msg.sender, withdrawableAmount);
    }
    
    /**
     * @dev Converts uint to string for ENS text records
     * @param value Number to convert
     * @return string representation of the number
     * Internal helper for reputation system data formatting
     */
    function _uintToString(uint256 value) internal pure returns (string memory) {
        if (value == 0) {
            return "0";
        }
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
    
    /**
     * @dev Calculates withdrawable amount for a member
     * @param _user Member address to check
     * @return amount USDC amount available for withdrawal
     * Uses proportional distribution based on contribution ratio
     */
    function getWithdrawableAmount(address _user) public view override returns (uint256) {
        if (!members[_user].hasContributed || members[_user].hasWithdrawn) {
            return 0;
        }
        
        // Calculate total active contributions
        uint256 totalContributions = 0;
        
        for (uint256 i = 0; i < membersList.length; i++) {
            if (members[membersList[i]].hasContributed && !members[membersList[i]].hasWithdrawn) {
                totalContributions += contributions[membersList[i]];
            }
        }
        
        if (totalContributions == 0) {
            return 0;
        }
        
        // Calculate proportional share (contribution ratio * current total funds)
        return (contributions[_user] * totalFunds) / totalContributions;
    }
    
    // ============ VIEW FUNCTIONS ============
    // These functions provide read access to pool state
    
    /**
     * @dev Get contribution count for a member
     */
    function getContributionCount(address _user) external view override returns (uint256) {
        return members[_user].contributionCount;
    }
    
    /**
     * @dev Calculate next contribution due date
     * @param _user Member address to check
     * @return timestamp When next contribution is due
     * Enforces contribution schedule discipline
     */
    function getNextContributionDate(address _user) public view override returns (uint256) {
        MemberInfo memory member = members[_user];
        if (member.lastContributionDate == 0) {
            return block.timestamp; // Can contribute immediately
        }
        
        uint256 intervalSeconds;
        if (contributionInterval == ContributionInterval.WEEKLY) {
            intervalSeconds = 7 days;
        } else if (contributionInterval == ContributionInterval.MONTHLY) {
            intervalSeconds = 30 days;
        } else {
            intervalSeconds = 90 days;
        }
        
        return member.lastContributionDate + intervalSeconds;
    }

    /**
     * @dev Get comprehensive member contribution data
     * @return memberAddresses Array of all member addresses
     * @return ensNames Array of corresponding ENS names
     * @return contributionAmounts Array of total contributions
     * @return contributionCounts Array of contribution frequencies
     * Useful for dashboards and analytics
     */
    function getAllMemberContributions() external view returns (
        address[] memory memberAddresses,
        string[] memory ensNames,
        uint256[] memory contributionAmounts,
        uint256[] memory contributionCounts
    ) {
        memberAddresses = membersList;
        ensNames = new string[](membersList.length);
        contributionAmounts = new uint256[](membersList.length);
        contributionCounts = new uint256[](membersList.length);
        
        for (uint256 i = 0; i < membersList.length; i++) {
            address member = membersList[i];
            ensNames[i] = members[member].ensName;
            contributionAmounts[i] = contributions[member];
            contributionCounts[i] = members[member].contributionCount;
        }
    }

    /**
     * @dev Get detailed contribution information for a member
     * @param member Address to get details for
     * @return ensName Member's ENS identity
     * @return totalContributed Total USDC contributed
     * @return contributionCount Number of contributions made
     * @return lastContributionDate Timestamp of last contribution
     * @return nextContributionDue Timestamp for next contribution
     */
    function getMemberContributionDetails(address member) external view returns (
        string memory ensName,
        uint256 totalContributed,
        uint256 contributionCount,
        uint256 lastContributionDate,
        uint256 nextContributionDue
    ) {
        require(members[member].isMember, "Not a member");
        
        MemberInfo memory memberInfo = members[member];
        return (
            memberInfo.ensName,
            contributions[member],
            memberInfo.contributionCount,
            memberInfo.lastContributionDate,
            getNextContributionDate(member)
        );
    }

    /**
     * @dev Internal function to update member-specific ENS records
     * @param member Address to update records for
     * Part of reputation and attestation system
     */
    function updateMemberENSRecord(address member) internal {
        bytes32 memberNode = keccak256(abi.encodePacked(ensNode, keccak256(abi.encodePacked("members"))));
        IPublicResolver(publicResolver).setText(
            memberNode,
            string(abi.encodePacked("contribution_", _uintToString(uint256(uint160(member))))),
            _uintToString(contributions[member])
        );
    }
    
    // Additional view functions for state access
    function getMemberENS(address _user) external view override returns (string memory) {
        return members[_user].ensName;
    }
    
    function hasContributed(address _user) external view override returns (bool) {
        return members[_user].hasContributed;
    }
    
    function hasWithdrawn(address _user) external view override returns (bool) {
        return members[_user].hasWithdrawn;
    }
    
    function isMember(address _user) external view override returns (bool) {
        return members[_user].isMember;
    }
    
    /**
     * @dev Get all member addresses
     * @return Array of all pool members
     */
    function getMembers() external view returns (address[] memory) {
        return membersList;
    }
    
    /**
     * @dev Get addresses of members who have contributed
     * @return Array of active contributor addresses
     * Useful for tracking participation rates
     */
    function getActiveContributors() external view returns (address[] memory) {
        address[] memory active = new address[](membersList.length);
        uint256 count = 0;
        
        for (uint256 i = 0; i < membersList.length; i++) {
            if (members[membersList[i]].hasContributed) {
                active[count] = membersList[i];
                count++;
            }
        }
        
        address[] memory result = new address[](count);
        for (uint256 i = 0; i < count; i++) {
            result[i] = active[i];
        }
        
        return result;
    }
}