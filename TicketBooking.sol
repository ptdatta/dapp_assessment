// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract TicketBooking {
    mapping(uint => bool) private tickets;
    mapping(address => uint256) private userTicketsBitmap;

    constructor() {
        for (uint i = 1; i <= 20; i++) {
            tickets[i] = false;
        }
    }

    function bookSeats(uint[] memory seatNumbers) public {
        require(seatNumbers.length > 0, "SeatNumbers must not be empty");
        require((seatNumbers.length + popCount(userTicketsBitmap[msg.sender])) <= 4, "SeatNumber must be less than 4");
        for (uint i = 0; i < seatNumbers.length; i++) {
            require(seatNumbers[i] > 0 && seatNumbers[i] <= 20, "Invalid ticket");
            require(!tickets[seatNumbers[i]], "Tickets are booked");
            tickets[seatNumbers[i]] = true;
            userTicketsBitmap[msg.sender] |= 1 << (seatNumbers[i] - 1);
        }
    }

    function showAvailableSeats() public view returns (uint[] memory) {
        uint[] memory availableTickets = new uint[](20);
        uint index = 0;

        for (uint i = 1; i <= 20; i++) {
            if (!tickets[i]) {
                availableTickets[index] = i;
                index++;
            }
        }

        uint[] memory result = new uint[](index);
        for (uint i = 0; i < index; i++) {
            result[i] = availableTickets[i];
        }

        return result;
    }

    function checkAvailability(uint seatNumber) public view returns (bool) {
        require(seatNumber > 0 && seatNumber <= 20, "Number invalid");
        return !tickets[seatNumber];
    }

    function myTickets() public view returns (uint[] memory) {
        uint256 bitmap = userTicketsBitmap[msg.sender];
        uint count = popCount(bitmap);
        uint[] memory result = new uint[](count);

        uint index = 0;
        for (uint i = 1; i <= 20; i++) {
            if ((bitmap & (1 << (i - 1))) != 0) {
                result[index] = i;
                index++;
            }
        }

        return result;
    }

    function popCount(uint256 bitmap) internal pure returns (uint count) {
        uint256 val = bitmap;
        while (val > 0) {
            count += val & 1;
            val >>= 1;
        }
    }
}
