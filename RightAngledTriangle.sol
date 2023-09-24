// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract RightAngledTriangle {
    // To check if a triangle with side lengths a, b, c is a right-angled triangle
    function check(uint256 a, uint256 b, uint256 c) public pure returns (bool) {
        if (a == 0 || b == 0 || c == 0) {
            return false;
        }

        uint256 hypotenuse = a;

        if (hypotenuse < b) {
            hypotenuse = b;
        }

        if (hypotenuse > c) {
            a = c;
            c = hypotenuse;
        }

        return (a * a + b * b) == c * c;
    }
}
