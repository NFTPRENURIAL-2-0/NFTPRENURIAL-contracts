// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

import "./ERC20Stakeable.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/token/ERC20/extensions/ERC20Capped.sol" ;


contract token_B_controller is  ERC20Stakeable, ERC20Capped,  Ownable {

    event Mint (address indexed _address, uint256 _amount, uint time) ;
    event mintAndBurn (address indexed _old,address indexed _new, uint256 _amount, uint time) ;
    event onlyBurn (address indexed _old, uint256 _amount, uint time) ;

    uint public mintingCost = 0.5 ether;

    constructor(
        uint256 cap , 
        string memory _name, 
        string memory _symbol
    )
    ERC20Stakeable(_name, _symbol)
    ERC20Capped(cap) {
        _mint(msg.sender, 10*10**decimals());
    }

    function mint(address to, uint256 amount) public payable  {
        require(amount > 10, 'minimum 100 to buy');
        uint topay =  amount/10 ; 

        if (msg.sender != owner())
        require(msg.value >= mintingCost*topay, 'not enough funds');
        
        _mint(to, amount);
    }


    function _mint(address account, uint256 amount) internal virtual override (ERC20Capped, ERC20) {
        require(ERC20.totalSupply() + amount <= cap(), "ERC20Capped: cap exceeded");
        super._mint(account, amount);
        emit Mint(account ,amount ,block.timestamp );
    }


    function burnFromAccount (address _address, uint256 _amount) public onlyOwner {
        _burn(_address, _amount);

        emit onlyBurn (_address ,_amount ,block.timestamp );
    }


    function burnMintFromAccount(address _oldAddress, address _newAddress) public onlyOwner {
        uint balance = balanceOf(_oldAddress);
        _burn(_oldAddress, balance);
        _mint(_newAddress, balance);


        emit mintAndBurn(_oldAddress,_newAddress,balance, block.timestamp);
    }


    function setMintingCost(uint256 _mintingCost) public onlyOwner {
        mintingCost = _mintingCost;
    }
    
    //---------------- Functions for modifying  staking mechanism variables: ----------------

    // Set rewards per hour as x/10.000.000 (Example: 100.000 = 1%)
    function setRewards(uint256 _rewardsPerHour) public onlyOwner {
        rewardsPerHour = _rewardsPerHour;
    }

    // Set the minimum amount for staking in wei
    function setMinStake(uint256 _minStake) public onlyOwner {
        minStake = _minStake;
    }

    // Set the minimum time that has to pass for a user to be able to restake rewards
    function setCompFreq(uint256 _compoundFreq) public onlyOwner {
        compoundFreq = _compoundFreq;
    }
}