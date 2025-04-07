// SPDX-License-Identifier: MIT
pragma solidity ^0.8.26;

/**
 * @title AutomatedTaxCollection
 * @dev A simple smart contract for collecting taxes from registered citizens or businesses.
 */

contract AutomatedTaxCollection {
    address public admin;

    struct Payer {
        uint256 totalPaid;
        bool isRegistered;
    }

    mapping(address => Payer) public payers;

    event Registered(address indexed payer);
    event TaxPaid(address indexed payer, uint256 amount);
    event Withdrawn(address indexed admin, uint256 amount);

    modifier onlyAdmin() {
        require(msg.sender == admin, "Only admin can perform this action");
        _;
    }

    modifier onlyRegistered() {
        require(payers[msg.sender].isRegistered, "You must be registered to pay tax");
        _;
    }

    constructor() {
        admin = msg.sender;
    }

    function registerPayer(address _payer) public onlyAdmin {
        require(!payers[_payer].isRegistered, "Payer already registered");
        payers[_payer].isRegistered = true;
        emit Registered(_payer);
    }

    function payTax() public payable onlyRegistered {
        require(msg.value > 0, "Tax amount must be greater than 0");
        payers[msg.sender].totalPaid += msg.value;
        emit TaxPaid(msg.sender, msg.value);
    }

    function getTotalPaid(address _payer) public view returns (uint256) {
        return payers[_payer].totalPaid;
    }

    function withdraw(uint256 _amount) public onlyAdmin {
        require(address(this).balance >= _amount, "Insufficient balance");
        payable(admin).transfer(_amount);
        emit Withdrawn(admin, _amount);
    }

    function getContractBalance() public view returns (uint256) {
        return address(this).balance;
    }
}
