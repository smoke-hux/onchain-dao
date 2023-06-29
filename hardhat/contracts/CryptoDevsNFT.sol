// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import "@openzeppelin/contracts/token/ERC721/extensions/ERC721Enumarable.sol";

contract CryptoDevsNFT is ERC721Enumarable{
    // contract variables for the ERC-721 contract
    constructor() ERC721("CryptoDevs", "CD") {}

    // Have a public mint function anyone can call to get NFT 
    fuction mint() public {
    _safeMint(msg.sender, totalsupply())
    }
}