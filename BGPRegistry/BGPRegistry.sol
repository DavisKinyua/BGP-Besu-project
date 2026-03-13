// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract BGPRegistry {
    address public rirAdmin;
    
    // ROA: Prefix -> Origin AS
    mapping(string => uint256) public prefixRegistry; 
    
    // ASPA: Customer AS -> (Provider AS -> Allowed?)
    mapping(uint256 => mapping(uint256 => bool)) public authorizedProviders;

    constructor() { rirAdmin = msg.sender; }

    // --- WRITE FUNCTIONS (RIR Only) ---
    function registerPrefix(string memory _prefix, uint256 _ownerAS) public {
        require(msg.sender == rirAdmin, "Only RIR can register prefixes");
        prefixRegistry[_prefix] = _ownerAS;
    }

    function authorizeProvider(uint256 _customerAS, uint256 _providerAS) public {
        require(msg.sender == rirAdmin, "Only RIR can update topology");
        authorizedProviders[_customerAS][_providerAS] = true;
    }

    function revokeProvider(uint256 _customerAS, uint256 _providerAS) public {
        require(msg.sender == rirAdmin, "Only RIR can update topology");
        authorizedProviders[_customerAS][_providerAS] = false;
    }

    // --- READ FUNCTIONS (University Guard) ---
    function isOriginValid(string memory _prefix, uint256 _originAS) public view returns (bool) {
        if (prefixRegistry[_prefix] == 0) return true; // Fail-open if not registered
        return prefixRegistry[_prefix] == _originAS;
    }

    function isPathPairValid(uint256 _customerAS, uint256 _providerAS) public view returns (bool) {
        // Enforce ASPA universally for all AS hops.
        // If the provider was not explicitly authorized by the customer, return false.
        return authorizedProviders[_customerAS][_providerAS];
    }
}