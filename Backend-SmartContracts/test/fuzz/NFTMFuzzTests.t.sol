// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import {NFTMarketplace} from "../../src/NFTMarketplace.sol";
import {DeployNFTMarketplace} from "../../script/DeployNFTMarketplace.s.sol";
// import {Counters} from "../../lib/openzeppelin-contracts/contracts/utils/Counters.sol";
import {Ownable} from "../../lib/openzeppelin-contracts/contracts/access/Ownable.sol";
import {ERC721URIStorage} from "../../lib/openzeppelin-contracts/contracts/token/ERC721/extensions/ERC721URIStorage.sol";
import {ERC721} from "../../lib/openzeppelin-contracts/contracts/token/ERC721/ERC721.sol";
import {Test} from "forge-std/Test.sol";
import {console} from "../../lib/forge-std/src/console.sol";
import {Vm} from "../../lib/forge-std/src/Vm.sol";


/////// Still in Progress /////////////

contract NFTMFuzzTest is Test {
    DeployNFTMarketplace deployer;
    NFTMarketplace nftMarketplace;

    // using Counters for Counters.Counter;

    uint256 private nonce =  0;
    address payable marketplaceOwner;
    uint256 listPrice;

    // function beforeEach() public {  
    //     nftMarketplace = new NFTMarketplace();

    //     nftMarketplace.transferOwnership(address(this));

    //     nftMarketplace.createToken(generateRandomTokenURI(), generateRandomPrice());
    //     console.log('listPrice after beforeEach: ', nftMarketplace.listPrice());
    // }

    function beforeEach() public {
        deployer = new DeployNFTMarketplace();
        deployer.setUp();
        nftMarketplace = deployer.run();

        marketplaceOwner = payable(address(nftMarketplace));
        listPrice =   0.01   ether;
        uint256 tokenId = nftMarketplace.createToken{value: nftMarketplace.listPrice()}(generateRandomTokenURI(), listPrice);
        vm.assume(nftMarketplace.getListedToken(tokenId).currentlyListed);
    }

    function generateRandomTokenURI() public view returns (string memory) {
        // Generate a random tokenURI
        // return "randomTokenURI";

        // Generate a unique tokenURI by appending the nonce to a base URI
        return string(abi.encodePacked("baseURI", nonce));
    }

    function incrementNonce() private {
        nonce++;
    }

    function generateRandomPrice() public pure returns (uint256) {
        // Generate a random price greater than listPrice
        return 0.01 ether;
    }

    function test_getListPrice() public {
        uint256 value = nftMarketplace.getListPrice();
        // assertEq(value, listPrice); // Replace with the expected value
        console.log(value);
    }

    function test_FuzzCreateToken() public payable {
        // Generate a random tokenURI
        string memory tokenURI = generateRandomTokenURI();

        console.log('tokenURI: ', tokenURI);

        // Generate a random price greater than listPrice
        uint256 price = generateRandomPrice();

        console.log('price: ', price);

        // Ensure that the tokenURI is not empty
        vm.assume(bytes(tokenURI).length > 0);

        // console.log(nftMarketplace.getListPrice());

        // Send the exact amount of Ether required to create a token
        (bool success, ) = address(nftMarketplace).call{value: nftMarketplace.listPrice()}(
        abi.encodeWithSignature("createToken(string,uint256)", tokenURI, price));
        require(success, "Failed to create token");

        uint256 newTokenId = nftMarketplace.getCurrentToken();
        console.log('newTokenId', newTokenId);

        // Increment the nonce for the next tokenURI generation
        incrementNonce();
        console.log('nonce, ', nonce);

        assertTrue(newTokenId > 0, 'New token ID should be greater than 0');
        assertEq(nftMarketplace.publicGetTokenURI(newTokenId), tokenURI, 'Token URI does not match');
    }


    // function test_FuzzExecuteSale() public payable {
    //     // Generate a valid tokenId
    //     uint256 tokenId = 1;

    //     // Ensure that the tokenId exists
    //     vm.assume(nftMarketplace.getListedToken(tokenId).currentlyListed);

    //     // Calculate the total price
    //     uint256 totalPrice = nftMarketplace.getListedToken(tokenId).price + nftMarketplace.listPrice();

    //     // Send the total price in Ether
    //     (bool success, ) = address(nftMarketplace).call{value: totalPrice}(abi.encodeWithSignature("executeSale(uint256)", tokenId));
    //     require(success, "Failed to execute sale");

    //     // Check that the token is no longer listed
    //     assertFalse(nftMarketplace.getListedToken(tokenId).currentlyListed, 'Token should no longer be listed');
    // }

    function test_FuzzExecuteSale() public payable {
        // Generate a valid tokenId
        uint256 tokenId = 1;

        // Ensure that the tokenId exists and is owned by the marketplaceOwner
        vm.assume(nftMarketplace.getListedToken(tokenId).currentlyListed && nftMarketplace.getListedToken(tokenId).owner == marketplaceOwner);

        // Calculate the total price
        uint256 totalPrice = nftMarketplace.getListedToken(tokenId).price + nftMarketplace.listPrice();

        // Send the total price in Ether
        (bool success, ) = address(nftMarketplace).call{value: totalPrice}(abi.encodeWithSignature("executeSale(uint256)", tokenId));
        require(success, "Failed to execute sale");

        // Check that the token is no longer listed
        assertFalse(nftMarketplace.getListedToken(tokenId).currentlyListed, 'Token should no longer be listed');
    }

}

