// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import {Script} from "../lib/forge-std/src/Script.sol";
import {console} from "../lib/forge-std/src/console.sol";
import {NFTMarketplace} from "../src/NFTMarketplace.sol";

contract DeployNFTMarketplace is Script {
   uint256 deployerPrivateKey;
   address deployerAccount;
   NFTMarketplace public nftMarketplace;

    function setUp() public {
       deployerPrivateKey = vm.envUint("DEV_PRIVATE_KEY");
       deployerAccount = vm.addr(deployerPrivateKey);
       vm.startBroadcast(deployerPrivateKey);
    }

//    function run() external {
//        nftMarketplace = new NFTMarketplace();
//        nftMarketplace.transferOwnership(deployerAccount);
//        vm.stopBroadcast();
//    }

    function run() external returns (NFTMarketplace) {
        nftMarketplace = new NFTMarketplace();
        // Your deployment code...
        return nftMarketplace;
    }
}
