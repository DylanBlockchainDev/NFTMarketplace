// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import {Test} from "forge-std/Test.sol";
import {DeployNFTMarketplace} from "../../script/DeployNFTMarketplace.s.sol";
import {NFTMarketplace} from "../../src/NFTMarketplace.sol";

contract TestDeployNFTMarketplace is Test {
  DeployNFTMarketplace deploymentScript;
  NFTMarketplace nftMarketplace;
  uint256 deployerPrivateKey = vm.envUint("DEV_PRIVATE_KEY");
  address deployerAccount = vm.addr(deployerPrivateKey);

  function setUp() public {
      deploymentScript = new DeployNFTMarketplace();
      deploymentScript.setUp();
  }

  function testRun() public {
      deploymentScript.run();

      // Assert that the ownership of the NFTMarketplace contract was transferred to the deployer account
      nftMarketplace = deploymentScript.nftMarketplace();
      assertEq(nftMarketplace.owner(), deployerAccount, "Ownership was not transferred correctly");
  }
}
