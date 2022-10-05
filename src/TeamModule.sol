// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;
import "./ContributerModule.sol";

contract TeamModule is ContributerModule {
    //Call failed, already on team
    error AlreadyOnTeam();

    //Cannot create an invite because contributer has
    //already been invited to this team.
    error AlreadyInvited();

    //Cannot vote as you have
    //already voted for this member
    error AlreadyVotedForMember();

    //Cannot remove vote if you have
    //nots voted for this member
    error HaveNotVotedForMember();

    //Cannot execute as the vote has
    //not passed
    error VoteNotPassed();

    //Cannot pass leadership as you are not on the same team
    error NotOnSameTeam();

    //You are not on a team.
    error NotOnTeam();

    //Function may only be called by the leader of a team.
    error NotLeader();

    //Cannot vote  as you are already the leader.
    error AlreadyLeader();

    //Team does not exist
    error TeamDoesNotExist();

    //Leader can not leave the team, please pass ownership to another team member
    error YouAreTheLeader();

    //Can not vote to kick leader.
    error CannotKickLeader();

    //Cannot accept invite as you have not been invited.
    error NotInvited();

    //Counter for teamID
    uint256 public teamCtr;

    //Map teamID to array of addresses
    //The first address in the array is the leader
    mapping(uint256 => address[]) public teams;

    //Member to teamID map
    mapping(address => uint256) public members;

    //Map contributer to mapping of teamIDs that they are invited to.
    mapping(address => mapping(uint256 => bool)) public teamInvites;


    //Map member to be kicked, to voter, to boolean
    mapping(address => mapping(address => bool)) public votesToBeKicked;

   
    //Map member to be leader, to voter, to boolean
    mapping(address => mapping(address => bool)) public votesForLeader;


    /**
     *  Create a new team
     *
     * Requirements:
     *
     * - The caller must be a contributer
     * - The caller must not be a team member
     */
    function createTeam() external {
        if (!contributers[msg.sender].exists) revert NotAContributer();
        if (members[msg.sender] > 0) revert AlreadyOnTeam();
        teams[++teamCtr] = [msg.sender];
        members[msg.sender] = teamCtr;
    }

    /**
     *  Invite new contributer to team
     *
     * Requirements:
     *
     * - The `member` must be a contributer
     * - The caller must be the leader of a team
     * -
     */
    function invite(address member) external {
        if (!contributers[member].exists) revert NotAContributer();
        uint256 teamID = members[msg.sender];
        if (teamInvites[member][teamID] == true) revert AlreadyInvited();
        if (teams[teamID][0] != msg.sender) revert NotLeader();
        teamInvites[member][teamID] = true;
    }

    // /**
    //  *  Accept invite
    //  *
    //  * Requirements:
    //  *
    //  * - The caller must be a contributer.
    //  * - The caller must be invited.
    //  * - The caller must not be the leader of a team with more than 2 members
    //  */
    function acceptInvite(uint256 teamID) external {
        if (!contributers[msg.sender].exists) revert NotAContributer();
        if (members[msg.sender] > 0) revert AlreadyOnTeam();
        if (!teamInvites[msg.sender][teamID]) revert NotInvited();
        teamInvites[msg.sender][teamID] = false;
        teams[teamID].push(msg.sender);
        members[msg.sender] = teamID;
    }

    /**
     *  Reject invite
     */
    function rejectInvite(uint256 teamID) external {
        if (!teamInvites[msg.sender][teamID]) revert NotInvited();
        teamInvites[msg.sender][teamID] = false;
    }

    /**
     *  Accept invite
     *
     * Requirements:
     *
     * - The caller must be the team leader.
     */
    function cancelInvite(address member) external {
        uint256 teamID = members[msg.sender];
        if (teams[teamID][0] != msg.sender) revert NotLeader();
        teamInvites[member][teamID] = false;
    }

    /**
     *  Pass Leadership
     *
     * Requirements:
     *
     * - The caller must be the leader.
     * - The 'member' must be on the same team as the caller.
     */
    function passLeader(address member) external {
        uint256 teamID = members[msg.sender];
        if (teamID != members[member]) revert NotOnSameTeam();
        address[] memory tempTeam = teams[teamID];
        if (tempTeam[0] != msg.sender) revert NotLeader();
         for (uint256 i = 1; i < tempTeam.length; ) {
            if (tempTeam[i] == member) {
                teams[teamID][i] = tempTeam[0];
                teams[teamID][0] = member;
                return;
            }
            unchecked {
                ++i;
            }
        }
    }

    /**
     *  Leave team
     *
     * Requirements:
     *
     * - The caller must be not be the leader if there are other members.
     */
    function leaveTeam() external {
        uint256 teamID = members[msg.sender];
        uint256 n = teams[teamID].length;
        if (n == 0) revert TeamDoesNotExist();
        if (n > 1) {
            if (teams[teamID][0] == msg.sender) revert YouAreTheLeader();
            else {
                unchecked {
                    for (uint256 i = 1; i < n - 1; ++i) {
                        if (teams[teamID][i] == msg.sender) {
                            teams[teamID][i] = teams[teamID][n - 1];
                            teams[teamID].pop();
                            break;
                        }
                    }
                }
            }
        }
        members[msg.sender] = 0;
    }

    function voteToKick(address member) external {
        uint256 teamID = members[msg.sender];
        if (teamID == 0) revert NotOnTeam();
        if (teamID != members[member]) revert NotOnSameTeam();
        if (teams[teamID][0] == member) revert CannotKickLeader();
        if (votesToBeKicked[member][msg.sender]) revert AlreadyVotedForMember();
        votesToBeKicked[member][msg.sender] = true;
    }

    function removeVoteToKick(address member) external {
        uint256 teamID = members[msg.sender];
        if (teamID != members[member]) revert NotOnSameTeam();
        if (!votesToBeKicked[member][msg.sender]) revert HaveNotVotedForMember();
        votesToBeKicked[member][msg.sender] = false;
    }

    function execKick(address member) external {
        uint256 teamID = members[member];
        uint256 n = teams[teamID].length;
        if (n == 0) revert TeamDoesNotExist();
        if (teamID != members[msg.sender]) revert NotOnSameTeam();
        if (teams[teamID][0] == member) revert CannotKickLeader();
        //will not underflow, n must be greater than 0.
        unchecked {
            uint256 votes;
            uint256 toPass = n % 2 > 0 ? ((n - 1) / 2) : n / 2;
            //modulus ensures safe math.
            for (uint256 i = 0; i < n - 1; ++i) {
                if (votesToBeKicked[member][teams[teamID][i]]) {
                    votesToBeKicked[member][teams[teamID][i]] = false;
                    ++votes;
                }
                if (teams[teamID][i] == member) {
                    teams[teamID][i] = teams[teamID][n - 1];
                    teams[teamID].pop();
                }
            }
            members[member] = 0;
            if (votes > toPass) return;
        }
        revert VoteNotPassed();
    }

    function voteForLeader(address member) external {
        uint256 teamID = members[msg.sender];
        if (teamID == 0) revert NotOnTeam();
        if (teamID != members[member]) revert NotOnSameTeam();
        if (teams[teamID][0] == member) revert AlreadyLeader();
        if (votesForLeader[member][msg.sender]) revert AlreadyVotedForMember();
        votesForLeader[member][msg.sender] = true;
    }

    function removeVoteForLeader(address member) external {
        uint256 teamID = members[msg.sender];
        if (teamID != members[member]) revert NotOnSameTeam();
        if (!votesForLeader[member][msg.sender]) revert HaveNotVotedForMember();
        votesForLeader[member][msg.sender] = false;
    }

    function execLeaderChange(address member) external {
        uint256 teamID = members[member];
        uint256 n = teams[teamID].length;
        if (n == 0) revert TeamDoesNotExist();
        if (teamID != members[msg.sender]) revert NotOnSameTeam();
        if (teams[teamID][0] == member) revert CannotKickLeader();
        //will not underflow, n must be greater than 0.
        unchecked {
            uint256 votes;
            uint256 toPass = n % 2 > 0 ? ((n - 1) / 2) : n / 2;
            //modulus ensures safe math.
            for (uint256 i = 0; i < n - 1; ++i) {
                if (votesForLeader[member][teams[teamID][i]]) {
                    votesForLeader[member][teams[teamID][i]] = false;
                    ++votes;
                }
                if (teams[teamID][i] == member) {
                    teams[teamID][i] = teams[teamID][n - 1];
                    teams[teamID].pop();
                }
            }
            members[member] = 0;
            if (votes > toPass) return;
        }
        revert VoteNotPassed();
    }
    // //view functions
    // function getContributerInvites(address contributer)
    //     external
    //     view
    //     returns (uint256[] memory)
    // {
    //     uint256 count = 0;
    //     for (uint256 i = 1; i < teamCtr + 1; ++i) {
    //         if (teamInvites[contributer][i]) count++;
    //     }
    //     uint256[] memory tempArr = new uint256[](count);
    //     count = 0;
    //     for (uint256 i = 1; i < teamCtr + 1; ++i) {
    //         if (teamInvites[contributer][i]) {
    //             tempArr[count] = i;
    //             count++;
    //         }
    //     }
    //     return tempArr;
    // }

    // function getTeamInvites(uint256 teamID)
    //     external
    //     view
    //     returns (address[] memory)
    // {
    //     uint256 count = 0;
    //     for (uint256 i = 0; i < contributersArr.length; ++i) {
    //         if (teamInvites[contributersArr[i]][teamID]) count++;
    //     }
    //     address[] memory tempArr = new address[](count);
    //     count = 0;
    //     for (uint256 i = 0; i < contributersArr.length; ++i) {
    //         if (teamInvites[contributersArr[i]][teamID]) {
    //             tempArr[count] = contributersArr[i];
    //             count++;
    //         }
    //     }
    //     return tempArr;
    // }

    function getLeader(uint256 teamID) external view returns (address) {
        if (teams[teamID].length == 0) revert TeamDoesNotExist();
        return teams[teamID][0];
    }

 
}
