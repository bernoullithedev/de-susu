// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

interface IPersonalVault {
    function initialize(
        address _owner, 
        uint256 _lockDuration, 
        address _usdc,
        string memory _vaultName
    ) external;
    
    function deposit(uint256 _amount, string memory _cid) external;
    function deposit(uint256 _amount) external;
    function updateCid(uint256 _depositId, string memory _cid) external;
    function withdraw() external;
    function getBalance() external view returns (uint256);
    function getLockEndTime() external view returns (uint256);
    function isMature() external view returns (bool);
    function timeUntilMaturity() external view returns (uint256);
    function getCid(uint256 _depositId) external view returns (string memory);
    function getDepositCount() external view returns (uint256);
}