// SPDX-License-Identifier: MIT

pragma solidity ^0.8.19;

import {Test, console} from "../../lib/forge-std/src/Test.sol";
import {Vm} from "../../lib/forge-std/src/Vm.sol";
import {NFTMarketplace} from "../../src/NFTMarketplace.sol";
import "../../lib/openzeppelin-contracts/contracts/token/ERC721/IERC721Receiver.sol";

// import {ERC721} from "../../lib/openzeppelin-contracts/contracts/token/ERC721/ERC721.sol";

error Unauthorized();

contract NFTMarketplaceTest is Test, IERC721Receiver {
    NFTMarketplace nftMarketplace;

    address payable marketplaceOwner;
    address payable not_marketplaceOwner;
    uint256 listPrice;
    address public anotherAddr = address(1);
    uint256 public constant ANOTHERADDR_BALANCE = 10 ether;
    uint256 public expectedAmount = 0.1 ether;
    string tokenURI;
    string tokenURI1;
    string tokenURI2;

    // event Transaction(address receiving, address sender, uint value, uint256 tokenId );

    function setUp() public {
        nftMarketplace = new NFTMarketplace();
        marketplaceOwner = payable(msg.sender);
        listPrice = 0.01 ether;
        vm.deal(anotherAddr, ANOTHERADDR_BALANCE);
        tokenURI = "https://ipfs.io/ipfs/Qm...";tokenURI1;tokenURI2;

        // Create a token for testing purposes
        // uint256 price =   1   ether;
        // uint256 tokenId = nftMarketplace.createToken{value: listPrice}(tokenURI, price);

    } 

    receive() external payable {}

    fallback() external payable {}

    // helper functions
    function onERC721Received(address, address, uint256, bytes calldata) public pure override returns (bytes4) {
        return this.onERC721Received.selector;
    }

    function getBalance() public view returns (uint) {
        return address(this).balance;
    }


    // TESTS
    function test_UpdateListPrice() public{
        if(msg.sender != marketplaceOwner) {
            revert Unauthorized();
        }
        listPrice = 0.02 ether;
        assertEq(listPrice, 0.02 ether);
        console.log('msg.sender', msg.sender);
        console.log('marketplaceOwner', marketplaceOwner);
    }

    function test_getListPrice() public {
        uint256 value = nftMarketplace.getListPrice();
        assertEq(value, listPrice); // Replace with the expected value
        console.log(value);
    }

    function test_getLatestIdToListedToken() public {
        // create test token
        tokenURI;
        uint256 price = 1 ether;
        uint256 tokenId = nftMarketplace.createToken{value: listPrice}(tokenURI, price);

        //calling the getLatestIdToListedToken function 
        NFTMarketplace.ListedToken memory latestToken = nftMarketplace.
        getLatestIdToListedToken();

        // checking if it worked correctly
        assertEq(latestToken.tokenId, tokenId);
    }

    function test_getListedTokenForId() public {
        // Set up the token details
        tokenURI;
        uint256 price = 1 ether;

        // test token
        uint256 tokenId = nftMarketplace.createToken{value: listPrice}(tokenURI, price);

        // Get the details of the token
        NFTMarketplace.ListedToken memory listedToken = nftMarketplace.getListedTokenForId(tokenId);

        // Check that the details match the expected values
        assertEq(listedToken.tokenId, tokenId, "Token ID does not match");
        assertEq(listedToken.price, price, "Token price does not match");
        assertTrue(listedToken.currentlyListed, "Token should be listed");
        assertEq(listedToken.owner, address(nftMarketplace), "Token owner does not match");
        assertEq(listedToken.seller, address(this), "Token seller does not match");
    }

    function test_getCurrentToken() public {
        // Set up the token details
        tokenURI;
        uint256 price = 1 ether;

        // test token
        uint256 tokenId = nftMarketplace.createToken{value: listPrice}(tokenURI, price);

        // Get the current token ID
        uint256 currentTokenId = nftMarketplace.getCurrentToken();

        // Check that the current token ID matches the token ID of the token we just created
        assertEq(currentTokenId, tokenId, "Current token ID does not match the token ID of the newly created token");
    }

    function test_createToken() public {
        // Set up the token details
        tokenURI;
        uint256 price = 1 ether;

        uint256 tokenId = nftMarketplace.createToken{value: listPrice}(tokenURI, price);

        // Get the current token ID
        uint256 currentTokenId = nftMarketplace.getCurrentToken();

        // Check that the token ID returned by createToken is the same as the current token ID
        assertEq(tokenId, currentTokenId, "Token ID returned by createToken does not match the current token ID");

        // Get the details of the token
        NFTMarketplace.ListedToken memory listedToken = nftMarketplace.getListedTokenForId(tokenId);

        // Check that the token's details match the expected values
        assertEq(listedToken.tokenId, tokenId, "Token ID does not match");
        assertEq(listedToken.price, price, "Token price does not match");
        assertTrue(listedToken.currentlyListed, "Token should be listed");
        assertEq(listedToken.owner, address(nftMarketplace), "Token owner does not match");
    }

    function test_getAllNFTs() public {
        // Set up the token details
        tokenURI1;
        tokenURI2;
        uint256 price1 = 1 ether;
        uint256 price2 = 2 ether;

        // first token
        uint256 tokenId1 = nftMarketplace.createToken{value: listPrice}(tokenURI1, price1);
        // second token
        uint256 tokenId2 = nftMarketplace.createToken{value: listPrice}(tokenURI2, price2);

        // Get all the NFTs
        NFTMarketplace.ListedToken[] memory tokens = nftMarketplace.getAllNFTs();

        // Check that the array contains the correct tokens
        assertEq(tokens.length, 2, "Array should contain 2 tokens");
        assertEq(tokens[0].tokenId, tokenId1, "First token ID does not match");
        assertEq(tokens[0].price, price1, "First token price does not match");
        assertEq(tokens[1].tokenId, tokenId2, "Second token ID does not match");
        assertEq(tokens[1].price, price2, "Second token price does not match");
    }


    function test_getMyNFTs() public {
        // Set up the token details
        tokenURI1;
        tokenURI2;
        uint256 price1 = 1 ether;
        uint256 price2 = 2 ether;

        // Create the first token as the test contract
        uint256 tokenId1 = nftMarketplace.createToken{value: listPrice}(tokenURI1, price1);

        // Emulate another address
        address payable anotherAddress = payable(address(anotherAddr)); // Replace with an actual address
        vm.prank(anotherAddress);

        uint256 tokenId2 = nftMarketplace.createToken{value: listPrice}(tokenURI2, price2);
        console.log(tokenId2);

        // Get the NFTs owned by the test contract
        NFTMarketplace.ListedToken[] memory tokens = nftMarketplace.getMyNFTs();

        // Check that the array contains the correct tokens
        assertEq(tokens.length, 1, "Array should contain 1 token");
        assertEq(tokens[0].tokenId, tokenId1, "First token ID does not match");
        assertEq(tokens[0].price, price1, "First token price does not match");
    }

    function test_executeSale() public {
        // Set up the token details
        tokenURI;
        uint256 price = 1 ether;

        // Create a token as the test contract
        uint256 tokenId = nftMarketplace.createToken{value: listPrice}(tokenURI, price);

        // Prank the test contract to execute the sale
        vm.prank(address(anotherAddr), address(nftMarketplace)); 

        nftMarketplace.executeSale{value: price + listPrice}(tokenId);

        // Check that the token is no longer listed
        assertTrue(nftMarketplace.getListedToken(tokenId).currentlyListed, "Token should no longer be listed");

        // Check that the seller is the buyer
        assertEq(nftMarketplace.getListedToken(tokenId).seller, payable(address(nftMarketplace.getListedToken(tokenId).seller)), "Seller should be the buyer");

        // Check that the token transfer was successful
        assertEq(address(nftMarketplace.ownerOf(tokenId)), payable(address(anotherAddr)), "Token owner should be the buyer");
    }


}