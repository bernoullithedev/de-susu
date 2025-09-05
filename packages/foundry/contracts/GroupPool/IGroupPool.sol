// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

interface IGroupPool {
    // Events
    event PoolCreated(
        address indexed poolAddress,
        string name,
        string description,
        address[] members,
        string[] ensNames,
        uint256 contributionAmount,
        uint256 contributionInterval,
        uint256 maturityDate,
        string poolENSName
    );
    event MemberJoined(address indexed member, string ensName);
    event ContributionMade(address indexed member, uint256 amount, uint256 contributionIndex);
    event Withdrawal(address indexed member, uint256 amount);
    event ENSNameUpdated(address indexed member, string newENSName);
    event ENSRecordUpdated(string ensName, string key, string value); // New event for ENS text record updates
    
    enum ContributionInterval { WEEKLY, MONTHLY, QUARTERLY }
    
    // Pool information
    function poolName() external view returns (string memory);
    function poolDescription() external view returns (string memory);
    function creator() external view returns (address);
    function contributionAmount() external view returns (uint256);
    function contributionInterval() external view returns (ContributionInterval);
    function maturityDate() external view returns (uint256);
    function totalContributors() external view returns (uint256);
    function totalFunds() external view returns (uint256);
    function poolENSName() external view returns (string memory);
    
    // Member functions
    function joinPool(string memory ensName) external;
    function contribute() external;
    function withdraw() external;
    function updateENSName(string memory newENSName) external;
    
    // New function for updating ENS text records (e.g., reputation/attestations)
    function setTextRecord(string memory key, string memory value) external;
    
    // Member status
    function isMember(address _user) external view returns (bool);
    function hasContributed(address _user) external view returns (bool);
    function hasWithdrawn(address _user) external view returns (bool);
    function getContributionCount(address _user) external view returns (uint256);
    function getNextContributionDate(address _user) external view returns (uint256);
    function getMemberENS(address _user) external view returns (string memory);
    function getWithdrawableAmount(address _user) external view returns (uint256);
    
    // Initialize function for factory
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
        string memory _poolENSName
    ) external;
}