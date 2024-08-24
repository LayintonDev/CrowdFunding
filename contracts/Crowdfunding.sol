// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;
contract Crowdfunding {
    address payable public _owner;
    constructor() {
        _owner = payable(msg.sender);
    }
    modifier onlyOwner() {
        require(_owner == msg.sender, "Only owner can call this function");
        _;
    }
    struct Campaign {
        string title;
        string id;
        string description;
        address payable benefactor;
        uint256 goal;
        uint256 deadline;
        uint256 amountRaised;
    }

    //check if campaign exists
    modifier checkExistingCampaign(string memory _campaignId) {
        require(existingCampaign[_campaignId], "Campaign does not exist");
        _;
    }
    mapping(string => Campaign) public campaigns;
    mapping(string => bool) public existingCampaign;
    mapping(string => bool) public fundSentToBenefactor;

    // event to be emitted after creating a campaign and indexing important kwy for faster lookup
    event CampaignCreated(
        string indexed _title,
        string indexed _id,
        string _description,
        address indexed _benefactor,
        uint256 _goal,
        uint256 _deadline,
        uint256 _amountRaised
    );
    // event to be emitted after donation has been recei
    event DontaionReceived(string indexed _campaignId, uint256 _amount);
    event CampaignEnded(string _campaignId);

    function createCampaign(
        string memory _title,
        string memory _id,
        string memory _description,
        address payable _benefactor,
        uint256 _goal,
        uint256 _deadline
    ) public {
        // check if campaign already exists
        require(!existingCampaign[_id], "Campaign already exists");
        // cal actual deadline by adding the deadline to the current block timestamp
        uint deadline = block.timestamp + _deadline;
        require(deadline > block.timestamp, "Deadline must be in the future");
        campaigns[_id] = Campaign(
            _title,
            _id,
            _description,
            _benefactor,
            _goal,
            deadline,
            0
        );
        // add campaign to list of existing campaigns
        existingCampaign[_id] = true;
        emit CampaignCreated(
            _title,
            _id,
            _description,
            _benefactor,
            _goal,
            deadline,
            0
        );
    }

    function donateToCampaign(
        string memory _campaignId
    ) public payable checkExistingCampaign(_campaignId) {
        require(
            campaigns[_campaignId].deadline > block.timestamp,
            "Deadline reached"
        );
        require(msg.value > 0, "You cannot donate zero amount");
        // require(campaigns[_campaignId].amountRaised + _amount <= campaigns[_campaignId].goal, "Goal reached");
        campaigns[_campaignId].amountRaised += msg.value;
        emit DontaionReceived(_campaignId, msg.value);
    }

    function endCampaign(
        string memory _campaignId
    ) public onlyOwner checkExistingCampaign(_campaignId) {
        require(
            campaigns[_campaignId].deadline <= block.timestamp,
            "Deadline not reached"
        );
        campaigns[_campaignId].benefactor.transfer(
            campaigns[_campaignId].amountRaised
        );
        // campaigns[_campaignId] = 0;
        fundSentToBenefactor[_campaignId] = true;
        emit CampaignEnded(_campaignId);
    }

    function withdrawLeftOvers(
        string memory _campaignId
    ) public checkExistingCampaign(_campaignId) onlyOwner {
        require(
            campaigns[_campaignId].deadline <= block.timestamp,
            "Deadline not reached"
        );
        //makes sure campaign has ended and the funds has been sent to the benefactor before leftover can be withdraw
        require(
            fundSentToBenefactor[_campaignId],
            "Campaign has  not ended yet "
        );
        payable(msg.sender).transfer(address(this).balance);
    }
}
