// SPDX-License-Identifier: BSD
pragma solidity ^0.8.4;

import "forge-std/Test.sol";
import { ExampleClone } from "../ExampleClone.sol";
import { ExampleCloneFactory } from "../ExampleCloneFactory.sol";

contract ExampleCloneTest is Test {
    ExampleClone internal clone;
    ExampleCloneFactory internal factory;

    function setUp() public {
        ExampleClone implementation = new ExampleClone();
        factory = new ExampleCloneFactory(implementation);
        clone = factory.createClone(
            address(this),
            type(uint256).max,
            8008,
            bytes32(type(uint256).max),
            69
        );
    }

    /// -----------------------------------------------------------------------
    /// Gas benchmarking
    /// -----------------------------------------------------------------------

    function testGas_param1() public view {
        clone.param1();
    }

    function testGas_param2() public view {
        clone.param2();
    }

    function testGas_param3() public view {
        clone.param3();
    }

    function testGas_param4() public view {
        clone.param4();
    }

    function testGas_param5() public view {
        clone.param5();
    }
}
