


// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import {MerkleProof} from "./lib/MerkleProof.sol";
// credit https://github.com/dmfxyz/murky/blob/main/src/common/MurkyBase.sol
import {MerkleGenerator} from "./lib/MerkleGenerator.sol";
import "@openzeppelin/token/ERC721/ERC721.sol";
import "@openzeppelin/token/ERC20/ERC20.sol";


///     ###############################################
///     TraitbasedOffer Specification
///     ###############################################
///     TraitbasedOffer is a minimal demo for creating a trait-based Offer for ERC721 Token Collection (NFT)
///     Specificially
///     1. Bidder makes offer to a custom list of tokenIds in a collection
///     2. Bidder does this by committing to a standard merkle root
///     3. This merkle root is created by hashing all eligible tokenIds (tokenId converted to bytes32 first)
///     4. When a seller takes the offer, he/she has to provide the merkle proof against the root from the tokenId he/she is selling.
///     5. The linkage of a merkle root to its underlying list of tokenIds should be maintained off-chain (similar to a standard Merkle Distributor)
///     
contract TraitbasedOffer {
    bytes32 public immutable DOMAIN_SEPARATOR;
    address public immutable WETH;
    bytes32 internal constant OFFER_ORDER_HASH = keccak256("Offer(address signer,address collection,uint256 price,bytes32 root)");

    constructor(address _WETH) {
    // Calculate the domain separator
    DOMAIN_SEPARATOR = keccak256(
        abi.encode(
            keccak256("EIP712Domain(string name,string version,uint256 chainId,address verifyingContract)"),
            keccak256("TraitbasedOfferMVP"),
            keccak256(bytes("1")),
            block.chainid,
            address(this)
           )
        );
    WETH = _WETH;    
    }

    struct Offer {
        address signer;
        // assume ERC721 for simplicity
        address collection;
        uint256 price;
        bytes32 root; // merkle root for a specific list of tokenId (traits)
        uint8 v;
        bytes32 r;
        bytes32 s;
    }
    function fulfillTraitbasedOrder(Offer calldata offer, uint256 tokenId, bytes32[] memory proof) external {
        _validateSignature(offer);
        require(offer.root == MerkleProof.processProof(proof, bytes32(tokenId)));
        _fulfilOrder(offer,tokenId);
    }

    function _fulfilOrder(Offer calldata offer, uint256 tokenId) internal {
        ERC20(WETH).transferFrom(offer.signer, msg.sender, offer.price);
        ERC721(offer.collection).transferFrom(msg.sender, offer.signer, tokenId);
    }

    function _validateSignature(Offer calldata offer) internal view {
        bytes32 offerHash = offerDigest(offer);
        bytes32 digest = keccak256(abi.encodePacked("\x19\x01", DOMAIN_SEPARATOR, offerHash));
        address signer = ecrecover(digest, offer.v, offer.r, offer.s);
        require(signer == offer.signer);
    }

    function offerDigest(Offer calldata offer) public view returns (bytes32) {
        return
            keccak256(
                abi.encode(
                    OFFER_ORDER_HASH,
                    offer.signer,
                    offer.collection,
                    offer.price,
                    offer.root
                )
            );
    }

    // helper function to generate root in solidity
    function generateRoot(bytes32[] memory data) public view returns(bytes32) {
        return MerkleGenerator.getRoot(data);
    }
    // helper function to generate proof in solidity
    function generateProofForTokenId(bytes32[] memory data, uint256 tokenIdPosition) public view returns(bytes32[] memory){
        return MerkleGenerator.getProof(data, tokenIdPosition);
    }
    

}

