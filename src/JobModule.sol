// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;
import "./TeamModule.sol";

contract JobModule is TeamModule {
    //Array of jobIDs that are open for bidding
    uint256[] openJobs;

    //Counter for jobID
    uint256 public jobCtr;

    //Counter for contributer bid ID
    uint256 public bidCtr;

    //Counter for teamBid ID
    uint256 public teamBidCtr;

    //Map jobIDs to Job Struct
    mapping(uint256 => Job) public jobs;
    
    //map job creator to job ID
    mapping(address => uint256) createdJobs;

    //Job Data Struct
    struct Job {
        bool isTeam;
        bool isCompleted;
        uint256 selectedBid;
        uint256[] indivBids;
        uint256[] teamBids;
    }

    //Struct for individual contributer's bid
    struct Bid {
        uint256 value;
        address contributer;
    }

    //Struct for team bid
    struct TeamBid {
        uint256 value;
        uint256 teamID;
    }

    //Map jobID to array of bidIDs
    mapping(uint256 => Bid) public bids;

    //Map bidID to bidID
    mapping(uint256 => TeamBid) public teamBids;

    //  bid(jobId: uint128, bid: eth/wei) external {
    // 	    require(contributers[msg.sender].teamID === 0)
    //      require bid > 0
    // 	    bids[bidCtr]= bid(bid,
    // 	    jobBids[jobID] = pack(jobBids[jobID], bidCtr)
    // 	    bidCtr++
    // }

    ///teamBid(jobId: uint256, bid: eth/wei) external (not callable if not head of team)
    // value > 0

    //     createJob() external ----
  

    // acceptBid(jobId: uint128, bidId: uint128) external payable(callable by job creator)----
    // require msg.sender === creator
    // require job.bidID === 0
    // stake eth
    // set bid id

    // completeJob(jobId: uint256, feedback: uint) external {
    // 	require msg.sender === job.creator
    // 	require !job.completed
    // 	set job completed
    // 	set feedback on contributer(s)
    // 	payout contributer/team ???
    // 	distribute b tokens to contributer/team ???
    // }

    //view
    // function getContributerBids() external view returns (uint256[] memory) {

    // function getTeamBids() external view returns (uint256[] memory) {


    // getAllBids(jobId: uint256) external view {
    // Loop through bids
    // 	Get feedback for contributer
    // 	Get contributer B token balance
    // 	(Bid / (( Avg Feedback / 5 ) * B Tokens) ^ 1/2) -- Basic starting point
    // 	sort lowest to highest and return
}
