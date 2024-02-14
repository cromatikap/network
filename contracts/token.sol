// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/token/ERC20/extensions/ERC20Burnable.sol";
import "@openzeppelin/contracts/token/ERC20/extensions/ERC20Permit.sol";

uint256 constant U256_MAX = (2 ** 256) - 1;

contract Net is ERC20, ERC20Burnable {

    mapping(uint256 => bool) hashes;

    uint256 max = 0;

    constructor()
        ERC20("Net", "NET")
    {}

    function claim(uint256[] calldata nonces) public {
        /**
         * Public input as replay protection
         */
        uint256 offset = uint256(keccak256(abi.encode(block.chainid, msg.sender)));

        for (uint i = 0; i < nonces.length; i++) {
            /**
             * Private input as work solution
             */
            uint256 hash = uint256(keccak256(abi.encode(nonces[i])));

            if (hashes[hash])
                continue;
            uint256 divisor;

            /**
             * Zero-knowledge proof
             */
            unchecked {
                divisor = offset + hash;
            }

            if (divisor == 0)
                continue;
            uint256 value;

            /**
             * Rarer hashes yield more coins
             */
            unchecked {
                value = U256_MAX / divisor;
            }

            /**
             * Automatic halving
             */
            if (value > max) {
                uint256 tmp = value;
                value = max;
                max = tmp;
            }

            _mint(msg.sender, value);
            hashes[hash] = true;
        }
    }

}
