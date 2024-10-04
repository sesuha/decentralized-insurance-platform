// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract DecentralizedInsurancePlatform {
    struct Policyholder {
        uint256 premiumPaid;
        bool hasClaimed;
        bool isEligible;
    }

    address public admin;
    uint256 public totalPool;
    uint256 public premiumAmount;
    uint256 public claimAmount;
    
    mapping(address => Policyholder) public policyholders;
    address[] public members;

    event PremiumPaid(address indexed user, uint256 amount);
    event ClaimSubmitted(address indexed user);
    event ClaimApproved(address indexed user, uint256 amount);

    modifier onlyAdmin() {
        require(msg.sender == admin, "Only admin can perform this action");
        _;
    }

    constructor(uint256 _premiumAmount, uint256 _claimAmount) {
        admin = msg.sender;  
        premiumAmount = _premiumAmount;
        claimAmount = _claimAmount;
    }

    function payPremium() external payable {
        require(msg.value == premiumAmount, "Incorrect premium amount");
        require(policyholders[msg.sender].premiumPaid == 0, "Premium already paid");

        totalPool += msg.value;
        policyholders[msg.sender] = Policyholder(msg.value, false, true);
        members.push(msg.sender);

        emit PremiumPaid(msg.sender, msg.value);
    }

    function submitClaim() external {
        require(policyholders[msg.sender].premiumPaid > 0, "No premium paid");
        require(!policyholders[msg.sender].hasClaimed, "Claim already submitted");

        policyholders[msg.sender].hasClaimed = true;
        emit ClaimSubmitted(msg.sender);
    }

    function approveClaim(address _policyholder) external onlyAdmin {
        require(policyholders[_policyholder].hasClaimed, "No claim submitted");
        require(policyholders[_policyholder].isEligible, "Not eligible for claim");
        require(totalPool >= claimAmount, "Insufficient pool funds");

        payable(_policyholder).transfer(claimAmount);
        totalPool -= claimAmount;

        emit ClaimApproved(_policyholder, claimAmount);
    }

    function getPoolBalance() external view returns (uint256) {
        return totalPool;
    }

    function getPolicyholderDetails(address _policyholder) external view returns (uint256, bool, bool) {
        Policyholder memory policyholder = policyholders[_policyholder];
        return (policyholder.premiumPaid, policyholder.hasClaimed, policyholder.isEligible);
    }
}
