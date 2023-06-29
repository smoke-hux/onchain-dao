// SPDX-Licencer-Identifier: MIT
pragma solidity ^0.8.19;


contract FakeNFTMarketplace {
    // Maintain a mapping of Fake TokenId to owner address
    mapping(uint => address) public tokens;

    // set the purchase price for each Fake Nft

    uint256 nftPrice = 0.1 ether;
    
    // @dev purchase() accepts ETH  and marks the owner of the givern tokenID as the caller of the address

    // @param _tokenID the tokenID of the NFT that is being purchased
    // @param _price the purchase price of the NFT
    // @param _buyer the address of the buyer of the NFT

    function purchase(uint256 _tokenId) external payable {
        require(msg.value == nftPrice, "This NFT costs 0.1 ether");// require the value of the NFT is equal to the purchase price
        tokens[_tokenId] = msg.sender;// set the owner of the NFT to the address of the buyer
    }

    // @dev getPrice() returns the purchase price of the NFT

    function getPrice() external view returns (uint256) {
        return nftPrice;// return the purchase price of the NFT
    }

    // @dev available() checks whether the given tokenID has already beed sold of not

    // @param _tokenID -  the tokenID to check for 

    function available(uint256 _tokenId) external view returns (bool) {
        // address(0) = 0x0000000000000000000000000000000000000000
        // this is the default address in the ERC721 contract and solidity in general 

        if (tokens[_tokenId] == address(0)) {
            return true;

        }
        return false;
    }



}