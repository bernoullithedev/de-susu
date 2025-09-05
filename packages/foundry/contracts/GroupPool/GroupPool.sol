// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import "@openzeppelin/contracts-upgradeable/proxy/utils/UUPSUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/access/OwnableUpgradeable.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
import "./IGroupPool.sol";
import "./IPublicResolver.sol";

contract GroupPool is IGroupPool, UUPSUpgradeable, OwnableUpgradeable {
    using SafeERC20 for IERC20;

    // Pool configuration
    string public override poolName;
    string public override poolDescription;
    address public override creator;
    uint256 public override contributionAmount;
    ContributionInterval public override contributionInterval;
    uint256 public override maturityDate;
    string public override poolENSName; // Pool's Basename (e.g., "familysavings.base.eth")
    
    // Pool state
    uint256 public override totalContributors;
    uint256 public override totalFunds;
    
    // USDC token address
    IERC20 public usdcToken;
    
    // ENS-related
    address public publicResolver; // Upgradeable L2PublicResolver proxy on Base Sepolia: 0x85c87E548091F204c2d0350B39Ce1874f02197c6
    bytes32 public ensNode; // Hash of the ENS node for efficient record updates
    
    // Member tracking
    struct MemberInfo {
        bool isMember;
        bool hasContributed;
        bool hasWithdrawn;
        uint256 contributionCount;
        uint256 lastContributionDate;
        string ensName;
    }
    
    mapping(address => MemberInfo) public members;
    mapping(address => uint256) public contributions;
    address[] public membersList;
    
    // Modifiers
    modifier onlyMember() {
        require(members[msg.sender].isMember, "Not a pool member");
        _;
    }
    
    modifier beforeMaturity() {
        require(block.timestamp < maturityDate, "Pool has matured");
        _;
    }
    
    modifier afterMaturity() {
        require(block.timestamp >= maturityDate, "Pool not matured yet");
        _;
    }
    
    // UUPS upgrade authorization
    function _authorizeUpgrade(address newImplementation) internal override onlyOwner {}
    
    // Initialize function (called by factory)
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
        
        poolName = _name;
        poolDescription = _description;
        creator = _creator;
        contributionAmount = _contributionAmount;
        contributionInterval = _contributionInterval;
        maturityDate = _maturityDate;
        usdcToken = IERC20(_usdcToken);
        poolENSName = _poolENSName;
        
        // Set resolver (checksummed upgradeable proxy for Base Sepolia; update for mainnet)
        // publicResolver = 0x85C87e548091f204C2d0350b39ce1874f02197c6;
        publicResolver = _publicResolver;
        
        // Compute ENS node hash (e.g., for "familysavings.base.eth")
        string memory label = _extractLabelFromFullName(_poolENSName); // Helper to get label
        require(bytes(label).length > 0, "Invalid ENS name format");
        ensNode = keccak256(abi.encodePacked(keccak256(abi.encodePacked("base.eth")), keccak256(abi.encodePacked(label))));
        
        // Initialize members
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
        
        // Initial text record update (e.g., set description)
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
    
    // Internal helper to extract label from full name (e.g., "familysavings" from "familysavings.base.eth")
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
    }
    
    // Public function to update ENS text record (only owner, for reputation/attestations)
    function setTextRecord(string memory key, string memory value) external onlyOwner {
        _setTextRecord(key, value);
        emit ENSRecordUpdated(poolENSName, key, value);
    }
    
    // Join the pool (only allowed members)
    function joinPool(string memory ensName) external override {
        require(members[msg.sender].isMember, "Not allowed to join this pool");
        require(!members[msg.sender].hasContributed, "Already joined and contributed");
        
        // Update ENS name if provided
        if (bytes(ensName).length > 0) {
            members[msg.sender].ensName = ensName;
        }
        
        emit MemberJoined(msg.sender, members[msg.sender].ensName);
    }
    
    // Update ENS name for a member
    function updateENSName(string memory newENSName) external override onlyMember {
        require(bytes(newENSName).length > 0, "ENS name cannot be empty");
        members[msg.sender].ensName = newENSName;
        emit ENSNameUpdated(msg.sender, newENSName);
    }
    
    // Contribute USDC to the pool
    function contribute() external override onlyMember beforeMaturity {
        MemberInfo storage member = members[msg.sender];
        
        // Check if it's time for next contribution
        if (member.lastContributionDate > 0) {
            uint256 nextContributionDate = getNextContributionDate(msg.sender);
            require(block.timestamp >= nextContributionDate, "Not time for next contribution yet");
        }
        
        //  Transfer USDC from member to pool - USDC is standard ERC-20 compliant
        // require(
        //     usdcToken.transferFrom(msg.sender, address(this), contributionAmount),
        //     "USDC transfer failed"
        // );

        //  Transfer USDC from member to pool - USDC is standard ERC-20 compliant
        // Safe transfer
        usdcToken.safeTransferFrom(msg.sender, address(this), contributionAmount);
        
        member.hasContributed = true;
        member.contributionCount++;
        member.lastContributionDate = block.timestamp;
        contributions[msg.sender] += contributionAmount;
        totalFunds += contributionAmount;
        
        // Update ENS text record for totalFunds (reputation example)
        _setTextRecord("totalFunds", _uintToString(totalFunds));

        // Update ENS record for member's individual contribution
        _setTextRecord(
            string(abi.encodePacked("member_", _uintToString(uint256(uint160(msg.sender))))),
            _uintToString(contributions[msg.sender])
        );
        
        // Update total contributions count
        _setTextRecord("totalContributions", _uintToString(totalFunds));
            
        emit ContributionMade(msg.sender, contributionAmount, member.contributionCount);
    }
    
    // Individual withdrawal function
    function withdraw() external override onlyMember afterMaturity {
        MemberInfo storage member = members[msg.sender];
        require(member.hasContributed, "No contributions to withdraw");
        require(!member.hasWithdrawn, "Already withdrawn");
        
        uint256 withdrawableAmount = getWithdrawableAmount(msg.sender);
        require(withdrawableAmount > 0, "No funds available to withdraw");
        
        // Mark as withdrawn
        member.hasWithdrawn = true;
        
        // Transfer funds
        // require(
        //     usdcToken.transfer(msg.sender, withdrawableAmount),
        //     "Withdrawal failed"
        // );

        // Safe transfer
        usdcToken.safeTransfer(msg.sender, withdrawableAmount);
        
        totalFunds -= withdrawableAmount;
        
        // Update ENS text record for totalFunds post-withdrawal
        _setTextRecord("totalFunds", _uintToString(totalFunds));
        
        emit Withdrawal(msg.sender, withdrawableAmount);
    }
    
    // Helper to convert uint to string for text records
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
    
    // View function to check withdrawable amount
    function getWithdrawableAmount(address _user) public view override returns (uint256) {
        if (!members[_user].hasContributed || members[_user].hasWithdrawn) {
            return 0;
        }
        
        // Calculate the user's share based on total contributions
        uint256 totalContributions = 0;
        
        for (uint256 i = 0; i < membersList.length; i++) {
            if (members[membersList[i]].hasContributed && !members[membersList[i]].hasWithdrawn) {
                totalContributions += contributions[membersList[i]];
            }
        }
        
        if (totalContributions == 0) {
            return 0;
        }
        
        // Calculate proportional share
        return (contributions[_user] * totalFunds) / totalContributions;
    }
    
    // View functions
    function getContributionCount(address _user) external view override returns (uint256) {
        return members[_user].contributionCount;
    }
    
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

    // Get all members with their contribution amounts and ENS names
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

    // Get individual member contribution details
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

    // Add helper function for member-specific records
    function updateMemberENSRecord(address member) internal {
        bytes32 memberNode = keccak256(abi.encodePacked(ensNode, keccak256(abi.encodePacked("members"))));
        IPublicResolver(publicResolver).setText(
            memberNode,
            string(abi.encodePacked("contribution_", _uintToString(uint256(uint160(member))))),
            _uintToString(contributions[member])
        );
    }
    
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
    
    // Additional helper functions
    function getMembers() external view returns (address[] memory) {
        return membersList;
    }
    
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