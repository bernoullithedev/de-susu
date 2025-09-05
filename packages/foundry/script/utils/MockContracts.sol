// script/utils/MockContracts.sol
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";

contract MockUSDC is ERC20 {
    // Add a constructor that sets decimals to 6
    constructor() ERC20("USD Coin", "USDC") {
        _mint(msg.sender, 1000000 * 10 ** decimals());
    }
    
    // Override the decimals function
    function decimals() public view virtual override returns (uint8) {
        return 6;
    }
    
    function mint(address to, uint256 amount) public {
        _mint(to, amount);
    }
}

contract MockRegistrarController {
    mapping(string => bool) public availableNames;
    mapping(string => uint256) public prices;
    
    constructor() {
        // Make all names available by default
        availableNames["familysavings"] = true;
        availableNames["familyemergency"] = true;
        availableNames["groupfund"] = true;
        
        // Set fixed prices
        prices["familysavings"] = 0.001 ether;
        prices["familyemergency"] = 0.001 ether; 
        prices["groupfund"] = 0.001 ether;
    }
    
    function available(string calldata name) external view returns (bool) {
        return availableNames[name];
    }
    
    function rentPrice(string calldata name, uint256) external view returns (uint256) {
        return prices[name];
    }
    
    function register(
        string calldata,
        address,
        uint256,
        address,
        bytes[] calldata,
        bool
    ) external payable {
        // Mock registration - just accept payment
        require(msg.value > 0, "Must pay registration fee");
    }
}

contract MockPublicResolver {
    mapping(bytes32 => mapping(string => string)) public textRecords;
    mapping(bytes32 => address) public addresses;
    
    function setAddr(bytes32 node, address addr) external {
        addresses[node] = addr;
    }
    
    function setName(bytes32 node, string calldata name) external {
        textRecords[node]["name"] = name;
    }
    
    function setText(bytes32 node, string calldata key, string calldata value) external {
        textRecords[node][key] = value;
    }
    
    function text(bytes32 node, string calldata key) external view returns (string memory) {
        return textRecords[node][key];
    }
    
    function addr(bytes32 node) external view returns (address) {
        return addresses[node];
    }
}