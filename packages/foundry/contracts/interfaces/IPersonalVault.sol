// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

interface IPersonalVault {
    function initialize(
        address _owner, 
        uint256 _lockDuration, 
        address _usdc,
        address _publicResolver,
        string memory _vaultENSName
    ) external;
    
    function deposit(uint256 _amount) external;
    function withdraw() external;
    function getBalance() external view returns (uint256);
    function getLockEndTime() external view returns (uint256);
    function isMature() external view returns (bool);
    function timeUntilMaturity() external view returns (uint256);
    function setTextRecord(string memory key, string memory value) external;
}