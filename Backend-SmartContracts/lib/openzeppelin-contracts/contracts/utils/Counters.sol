// Custom Counters.sol
// This is a basic implementation and you might need to add more functions if required.

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

library Counters {
    struct Counter {
        uint256 _value; // This is the current count
    }

    function current(Counter storage counter) internal view returns (uint256) {
        return counter._value;
    }

    function increment(Counter storage counter) internal {
        counter._value += 1;
    }

    function decrement(Counter storage counter) internal {
        counter._value = counter._value > 0 ? counter._value - 1 : 0;
    }
}
