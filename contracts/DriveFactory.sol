//SPDX-License-Identifier: Unlicense
pragma solidity ^0.8.4;

/// @author shayshay

/**
@notice an all or nothing donation contract that triggers a donation to the receipient address only once the target number has been reached.
the donation period expires in a given amount of days after which anyone can trigger a refund process
*/

contract DriveFactory {
    struct Drive {
        string purpose;
        address recipient;
        bool completed;
        uint expiry;
        uint target;
        uint maxDonors;
        uint balance;
        uint refundIndex;
    }

    Drive[] public drives;
    mapping (uint => address) private addressForDrive;

    function getDrives() view external returns (Drive[] memory _drives){
        return drives;
    }

    function startDrive(
        string memory _purpose,
        address _recipient,
        uint _expiryDays,
        uint _target,
        uint _maxDonors
    ) external returns (uint _driveId, Drive memory _drive){
        Drive memory newDrive = Drive(_purpose, _recipient, false, block.timestamp + (_expiryDays * 1 days), _target, _maxDonors, 0, 0);
        drives.push(newDrive);
        uint id = drives.length - 1;
        addressForDrive[id] = msg.sender;
        return (id, newDrive);
    }
}
