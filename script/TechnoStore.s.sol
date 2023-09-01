// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;

import {Script, console2} from "forge-std/Script.sol";
import {Token} from "../src/ERC20.sol";
import {TechnoStore} from "../src/TechnoStore.sol";

contract TechnoStoreScript is Script {
    function setUp() public {}

    function run() public {
        uint256 privKey = vm.envUint("PRIVATE_KEY");
        vm.startBroadcast(privKey);

        Token token = new Token();

        TechnoStore store = new TechnoStore(address(token));

        vm.stopBroadcast();
    }
}
