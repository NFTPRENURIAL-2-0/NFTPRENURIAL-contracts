// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

contract ContributerModule {


    event ContributerCreated(address contributer);

    //This address is not a verified contributer
    error NotAContributer();

    //This function cannot be called by smart-contracts
    error NonEOA();

    //This Contributer already exists
    error ContributerAlreadyExists();

  
    //Counter for contributer ID
    uint256 public contributerCtr;


    //Struct for contributer data
    struct Contributer {
        //Total accumulated feedback
        uint256 feedback;
        //Number of completed jobs
        uint256 completedJobs;
        //Shows if contributer exists
        bool exists;
    }

    
    //Map address to contributer data
    mapping(address => Contributer) contributers;

   



    /**
     *  Create a new contributer
     *
     * Requirements:
     *
     * - The caller must be not be a contributer
     * - The caller must not be a smart-contract
     */
    function createContributer() external {
        if (msg.sender != tx.origin) revert NonEOA();
        if (contributers[msg.sender].exists) revert ContributerAlreadyExists();
        contributers[msg.sender].exists = true;
        emit ContributerCreated(msg.sender);
    }
}
