// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

import {Test, console2} from "forge-std/Test.sol";
import {Token} from "../src/ERC20.sol";
import {TechnoStore} from "../src/TechnoStore.sol";

contract TechnoStoreTest is Test {
    Token public token;
    TechnoStore public store;
    address public owner = address(1);
    address public customer;
    uint256 public customerPrivateKey = 123456;

    function setUp() public {
        vm.startPrank(owner);
        token = new Token();
        store = new TechnoStore(address(token));
        vm.stopPrank();

        customer = vm.addr(customerPrivateKey);

        assertEq(address(store.token()), address(token));
        assertEq(token.balanceOf(owner), 10000);
    }

    function testAddProduct() public {
        string memory product = "Keyboard";
        uint quantity = 10;
        uint price = 50;

        vm.prank(owner);
        store.addProduct(product, quantity, price);

        assertEq(store.products(0), product);
        assertEq(store.getAmountOfProducts(), 1);
        assertEq(store.getPriceOf(product), price);
        assertEq(store.getQuantityOf(product), quantity);

        vm.prank(owner);
        store.addProduct(product, quantity, price);

        assertEq(store.getAmountOfProducts(), 1);
        assertEq(store.getQuantityOf(product), quantity * 2);
    }

    function testAddProductRevert() public {
        string memory product = "Keyboard";
        uint quantity = 10;
        uint price = 50;

        vm.startPrank(owner);

        vm.expectRevert("Library__InvalidInputs");
        store.addProduct(product, quantity, 0);

        vm.expectRevert("Library__InvalidInputs");
        store.addProduct(product, 0, price);

        vm.expectRevert("Library__InvalidInputs");
        store.addProduct(product, 0, 0);

        vm.stopPrank();
    }

    // function testGetters() public {
    //     assertEq(store.getQuantityOf("Laptop"), 0);
    // }

    // function testFuzz_SetNumber(uint256 x) public {
    //     counter.setNumber(x);
    //     assertEq(counter.number(), x);
    // }
}
