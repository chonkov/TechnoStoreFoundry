// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

import {Test, console2} from "forge-std/Test.sol";
import {Token} from "../src/ERC20.sol";
import {TechnoStore} from "../src/TechnoStore.sol";

contract TechnoStoreTest is Test {
    bytes32 private constant _PERMIT_TYPEHASH =
        keccak256(
            "Permit(address owner,address spender,uint256 value,uint256 nonce,uint256 deadline)"
        );
    Token public token;
    TechnoStore public store;
    address public owner = address(1);
    address public customer;
    uint256 constant _CUSTOMER_PRIVATE_KEY = 123456;

    function setUp() public {
        vm.startPrank(owner);
        token = new Token();
        store = new TechnoStore(address(token));
        vm.stopPrank();

        customer = vm.addr(_CUSTOMER_PRIVATE_KEY);

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

    function testBuyProduct() public {
        string memory product = "Keyboard";
        uint quantity = 10;
        uint price = 50;

        vm.startPrank(owner);

        token.transfer(customer, 1000);
        store.addProduct(product, quantity, price);

        vm.stopPrank();

        uint initBalance = token.balanceOf(customer);

        console2.logUint(token.balanceOf(owner));
        console2.logUint(token.balanceOf(customer));

        uint i = 0;
        uint amount = price;
        uint deadline = block.timestamp + 1 days;

        bytes32 hash = _getPermitHash(
            address(customer),
            address(store),
            amount,
            token.nonces(customer),
            deadline
        );
        (uint8 v, bytes32 r, bytes32 s) = vm.sign(_CUSTOMER_PRIVATE_KEY, hash);

        vm.prank(customer);

        store.buyProduct(i, amount, deadline, v, r, s);

        assertEq(store.getQuantityOf(product), quantity - 1);
        assertEq((store.getBuyersOf(product)).length, 1);
        assertEq((store.getBuyersOf(product))[0], customer);
        assertEq(token.balanceOf(customer), initBalance - amount);
        assertEq(token.balanceOf(address(store)), amount);
    }

    function _getPermitHash(
        address _owner,
        address _spender,
        uint256 _value,
        uint256 _nonce,
        uint256 _deadline
    ) private view returns (bytes32) {
        return
            keccak256(
                abi.encodePacked(
                    "\x19\x01",
                    token.DOMAIN_SEPARATOR(),
                    keccak256(
                        abi.encode(
                            _PERMIT_TYPEHASH,
                            _owner,
                            _spender,
                            _value,
                            _nonce,
                            _deadline
                        )
                    )
                )
            );
    }

    // function testGetters() public {
    //     assertEq(store.getQuantityOf("Laptop"), 0);
    // }

    // function testFuzz_SetNumber(uint256 x) public {
    //     counter.setNumber(x);
    //     assertEq(counter.number(), x);
    // }
}
