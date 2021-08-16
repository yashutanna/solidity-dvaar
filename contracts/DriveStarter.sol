//SPDX-License-Identifier: Unlicense
pragma solidity ^0.8.4;
import "@openzeppelin/contracts/utils/math/SafeMath.sol";
import "./DriveFactory.sol";

/// @author shayshay

/**
@notice an all or nothing donation contract that triggers a donation to the receipient address only once the target number has been reached.
the donation period expires in a given amount of days after which anyone can trigger a refund process
*/

contract DriveStarter is DriveFactory {
    using SafeMath for uint256;

    /// events
    event DonationMade(
        uint _driveId,
        address indexed _from,
        uint _value,
        uint _currentBalance,
        uint _target
    );
    event RecipientPaid(uint _driveId, address indexed _recipient, uint _value);
    event DonorRefunded(uint _driveId, address indexed _donor, uint _amount);

    /// structs
    struct Donation {
        address donor;
        uint amount;
    }

    Donation[] donations;

    modifier notExpired(uint _driveId) {
        Drive memory drive = drives[_driveId];
        require(block.timestamp < drive.expiry && drive.completed == false);
        _;
    }

    modifier expired(uint _driveId) {
        Drive memory drive = drives[_driveId];
        require(block.timestamp >= drive.expiry && drive.completed == false);
        _;
    }

    function _makePayment(
        address payable _recipient,
        uint _amount
    ) internal {
        (bool success, ) = _recipient.call{value: _amount}("");
        require(success, "Payment failed.");
    }

    function donate(uint _driveId) public payable notExpired(_driveId) {
        Drive storage drive = drives[_driveId];
        drive.balance.add(msg.value);
        donations.push(Donation(msg.sender, msg.value));
        emit DonationMade(_driveId, msg.sender, msg.value, drive.balance, drive.target);
        if (drive.balance >= drive.target) {
            _makePayment(payable(drive.recipient), drive.balance);
            emit RecipientPaid(_driveId, drive.recipient, drive.balance);
            drive.completed = true;
        }
    }

    function initiateRefundProcess(uint _driveId) public expired(_driveId) {
        Drive storage drive = drives[_driveId];
        for (uint i = drive.refundIndex; i < drive.maxDonors; i.add(1)) {
            _makePayment(payable(donations[i].donor), donations[i].amount);
            emit DonorRefunded(_driveId, donations[i].donor, donations[i].amount);
            drive.refundIndex.add(1);
        }
        drive.completed = true;
    }
}
