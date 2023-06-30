// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import "@openzeppelin/contracts/access/Ownable.sol";

//Interfaces for the fakeMarketplace

interface IFakeNFTMarketplace {
    // @dev getPrice() returns the purchase price of the NFT from the fakeMarketplace
    // @return Returns the price in Wei for the NFT
    function getPrice() external view returns (uint256);
    // @dev available() returns whether or not the given _tokenID has already been sold 
    // @return Returns a boolean valye - true if the NFT has been sold, false otherwise

    function available(uint256 _tokenId) external view returns (bool); // @dev available() returns whether or not the given _tokenID has already been sold

    // @dev purchase() purchases an NFT from the fakeMarketplace
    // @param _tokenID - the tokenID of the NFT to purchase

    function purchase(uint256 _tokenId) external payable ;

}

interface ICryptoDevsNFT {
    //@dev balanceOf returns the number of NFTs owned by the given adddress

    // @ param owner - address to fetch number of NFTs for given address

    // @return Returns the number of owned NFTs
    function tokenOfOwnerByIndex(address owner, uint256 index) 
    external 
    view 
    returns (uint256);
}

contract CryptoDevsDAO is Ownable {
    // We will write contract code here

    /*
    now let's think about what functionns we need in the DAO contract
    and that will be the following
        store created proposals in the contract
        allow holders of cryptoDevs NFT to create new proposals 
        allow holders of cryptoDevs NFT to vote on proposals
        allow holders of cryptoDevs NFT to execute a proposal after deadline has passed if the proposal if the proposal passed 
    now we will need to call fakeMarketplace contract , 
    */

    //Create a struct named Proposal containing all relevant information about a proposal

    struct Proposal {
        // nftTokenID the tokenID of the NFT to puchase from FakeMarketplace if the proposal passes
        uint256 nftTokenId;
        // deadline - the UNIX timestamp which this proposal is active. Propasal can be executed after the deadline has been exceeded.
        uint256 deadline;

        // yayVoters - Number of yay votes for the proposal 
        uint256 yayVoters;

        //noyeVoters - Number of nay votes for the proposal
        uint256 noyeVoters;

        // executed - whether of not this proposal has been executed yet . Cannot be executed before the deadline has been exeded.

        bool executed;

        // voters - mapping of CryptoDevNFT tokenID to booleans indicating whether that NFT has already need used to cast a vote or not

        mapping(uint256 => bool) voters;

       


    }
     // Let's also create a mapping from proposal ID  to Proposal  to hold all created proposals and counter to cound the number of proposals that exist.

     mapping(uint256 => Proposal) public proposals;
     // the number of proposals the have been created

     uint256 public numProposals;

     // we are going to call the functions from the fakeMarketplace contract and the cryptoDevsNFT contract
     // we need to create a variable to store theose contracts.
     IFakeNFTMarketplace nftMarketplace;
     ICryptoDevsNFT cryptoDevsNFT;

     // Create a constructor function that will initialize those contract variables , and also accept an ETH deposit from the deployer to fill the DAO ETH treasury.
     //since we imported the Ownable contrac, this will also saet the contract deployer as the owner of this contract ;

     // create a payable constructor function which initializes the contract

     // instances for FakeMarketplace and CryptoDevsNFT contract

     // The payable for allows this constructor to accept an ETH deposit when it is being deployed

     constructor(address _nftMarketplace, address _cryptoDevsNFT) payable {
         nftMarketplace = IFakeNFTMarketplace(_nftMarketplace);// set the address of the FakeMarketplace contract
         cryptoDevsNFT = ICryptoDevsNFT(_cryptoDevsNFT);
     }

     // we will need to create modifier to avoid duplicate code.

     // Create a modifier which only allows a function to be
     // called by someone who owns at least 1 CryptoDevsNFT

     modifier nftHolderOnly() {
        require(cryptoDevsNFT.balanceOf(msg.sender) > 0, "NOT_A_DAO_MEMBER");
        _;
    }
    // allow members to create new proposals

    /// @dev createProposal allows a CryptoDevsNFT holder to create a new proposal in the DAO
    // @param _nftTokenId - the tokenID of the NFT to be purchased from FakeNFTMarketplace if this proposal passes
    /// @return Returns the proposal index for the newly created proposal

    function createProposal(uint256 _nftTokenId) 
    external
    nftHolderOnly
    returns (uint256)
    {
        require(nftMarketplace.available(_nftTokenId), "NFT_NOT_FOR_SALE");
        Proposal storage proposal = propasals[numProposals];
        proposal.nftTokenId = _nftTokenId;
        // set the proposal's voting deadline to be the(current time + 5 minutes)

        proposal.deadline = block.timestamp + 5 * 60;
        numProposals++;
        return numProposals - 1;


    }

    // now we can add a restriction that the proposal being voted on must not have had a deadline exceeded

    // to do so we will add a second modifier

    // create a modifier which only allows a function to be called if the given proposal's deadline has not been exceeded 

    modifier activeProposalOnly(uint256 proposalIndex) {
        require(proposals[proposalIndex].deadline > block.timestamp, "Deadline_exceeded"); // we need to check if the deadline has not been exceeded
        _;
    }


    // we are going to vote and with this we need to create two values (yay and noy) for the proposal
    // we will create a enum for this 

    enum Vote{
        YAY,  // YAY =0
        NAY // NAY =1
    }// end of enum

    // vote on proposal function

    fucntion voteOnProposal(uint256 proposalIndex, Vote vote)
    external
    nftHolderOnly
    activeProposalOnly(proposalIndex){
        Proposal storage proposal = proposals[proposalIndex];
        uint256 voterNFTBalance = cryptoDevsNFT.balanceOf(msg.sender);
        uint256 numVotes = 0;

        // calculate how many NFT are owned by the voter that have not been used for voting of the proposal
        for (uint256 i = 0; i < voterNFTBalance; i++){
            uint256 tokenId = cryptoDevsNFT.tokenOfOwnerByIndex(msg.sender, i);
            if (proposal.voters[tokenId] == false){
                numVotes++;
                proposal.voters[tokenId] = true;// set the NFT to be used for voting

            }
        }

        require(numVotes > 0, "already_voted");
        if (vote == Vote.YAY){
            proposal.yayVoters += numVotes;

        }else {
            proposal.nayVotes += numVotes;
        }
    }


    // final modifier

    modifier inactiveProposalOnly(uint256 proposalIndex) {
        require(proposals[proposalIndex].deadline <= block.timestamp, "Deadline_not_exceeded"
        _;
    }

}