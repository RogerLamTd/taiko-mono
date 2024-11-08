// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import "./TaikoL2Test.sol";

contract TestLibEIP1559 is TaikoL2Test {
    using LibMath for uint256;

    function test_ethQty() external {
        assertEq(LibEIP1559.ethQty(0, 60_000_000 * 8), 1);
        assertEq(LibEIP1559.ethQty(60_000_000, 60_000_000 * 8), 1);
        assertEq(LibEIP1559.ethQty(60_000_000 * 100, 60_000_000 * 8), 268_337);
        assertEq(LibEIP1559.ethQty(60_000_000 * 200, 60_000_000 * 8), 72_004_899_337);
    }

    function test_basefee() external pure {
        uint256 basefee;
        console2.log("excess, basefee");
        // 1_0000_000 is 0.01 gwei
        for (uint256 i; basefee <= 10_000_000;) {
            // uint 0.01 gwei
            uint256 excess = i * 5_000_000;
            uint256 target = 5_000_000 * 8;

            basefee = LibEIP1559.basefee(excess, target);
            if (basefee != 0) {
                console2.log(
                    string.concat(Strings.toString(excess), ", ", Strings.toString(basefee))
                );
            }
            i += 1;
        }
    }

    function test_mainnet_min_basefee() external pure {
        console2.log("Mainnet minimal basefee: ", LibEIP1559.basefee(1_340_000_000, 5_000_000 * 8));
    }

    function test_change_of_quotient_and_gasIssuancePerSecond() public {
        uint64 excess = 150 * 2_000_000;
        uint64 target = 4 * 2_000_000;
        uint256 unit = 10_000_000; // 0.01 gwei

        // uint 0.01 gwei
        uint256 baselineBasefee = LibEIP1559.basefee(excess, target) / unit;
        console2.log("baseline basefee: ", baselineBasefee);

        uint256 basefee = LibEIP1559.basefee(excess, target * 2) / unit;
        console2.log("basefee will decrease if target increases:", basefee);

        basefee = LibEIP1559.basefee(excess, target / 2) / unit;
        console2.log("basefee will increase if target decreases:", basefee);

        console2.log("maintain basefee when target increases");
        {
            uint64 newTarget = 5 * 2_000_000;
            uint64 newExcess = LibEIP1559.adjustExcess(excess, target, newTarget);
            basefee = LibEIP1559.basefee(newExcess, newTarget) / unit;
            console2.log("old gas excess: ", excess);
            console2.log("new gas excess: ", newExcess);
            console2.log("basefee: ", basefee);
            assertEq(baselineBasefee, basefee);
        }

        console2.log("maintain basefee when target decreases");
        {
            uint64 newTarget = 3 * 2_000_000;
            uint64 newExcess = LibEIP1559.adjustExcess(excess, target, newTarget);
            basefee = LibEIP1559.basefee(newExcess, newTarget) / unit;
            console2.log("old gas excess: ", excess);
            console2.log("new gas excess: ", newExcess);
            console2.log("basefee: ", basefee);
            assertEq(baselineBasefee, basefee);
        }
    }

    function test_change_of_quotient_and_gasIssuancePerSecond2() public {
        uint64 excess = 1;
        uint64 target = 60_000_000 * 8;
        uint256 unit = 10_000_000; // 0.01 gwei

        // uint 0.01 gwei
        uint256 baselineBasefee = LibEIP1559.basefee(excess, target) / unit;
        console2.log("baseline basefee: ", baselineBasefee);

        console2.log("maintain basefee when target changes");
        uint64 newTarget = 5_000_000 * 8;
        uint64 newExcess = LibEIP1559.adjustExcess(excess, target, newTarget);
        uint256 basefee = LibEIP1559.basefee(newExcess, newTarget) / unit;
        console2.log("old gas excess: ", excess);
        console2.log("new gas excess: ", newExcess);
        console2.log("basefee: ", basefee);
        assertEq(baselineBasefee, basefee);
    }
}
