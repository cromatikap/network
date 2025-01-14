// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/token/ERC20/extensions/ERC20Burnable.sol";

uint256 constant U256_MAX = (2 ** 256) - 1;

contract Network is ERC20, ERC20Burnable {

    mapping(uint256 => bool) public proofs;

    uint256 public maximum = 1;

    constructor()
        ERC20("Network", "NET")
    {}

    function claim(uint256[] calldata secrets) public {
        for (uint i = 0; i < secrets.length; i++) {
            /**
             * Zero-knowledge proof
             */
            uint256 proof = uint256(keccak256(abi.encode(secrets[i])));

            if (proofs[proof])
                continue;

            /**
             * Value is different for each given chain + contract + receiver
             */
            uint256 divisor = uint256(keccak256(abi.encode(block.chainid, address(this), msg.sender, proof)));

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
             * Automatic probabilistic halving
             */
            if (value > maximum) {
                /**
                 * 1%
                 */
                uint256 maximum2 = ((99 * maximum) + value) / 100;

                value = maximum;
                maximum = maximum2;
            }

            _mint(msg.sender, value);
            proofs[proof] = true;
        }
    }

}
