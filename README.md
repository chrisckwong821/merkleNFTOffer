## TraitbasedNFTOffer
[![tests](https://github.com/chrisckwong821/merkleNFTOffer/actions/workflows/unittest.yml/badge.svg)](https://github.com/chrisckwong821/merkleNFTOffer/actions/workflows/unittest.yml)


A demo contract to offer bid for a custom list of tokenIds through merkle root

### Problem

There is not yet a way for a bidder to bid for a specific list of NFT within a collection, so far they can only make collection offer; or individual offer in most NFT marketplaces

### Solution

1. Allow bidder to sign an offer with a merkle root, which is constructed from hashes of a custom list of tokenIds. This list consists of the Ids that The bidder is willing to accept.

2. Seller has to provide a merkle proof, constructed from the position of his NFT's tokenId, when accepting this offer.


SudoCode Example
```
Bidder wants to bid for any token in this list [1,2,3,4,100]

Bidder commit an offer of 1 ether for this list, represented in a root (0x7a0125739370474a561386a8e25ba7c5df592d9a16cfc0aedc6ad6c2ca7d04cc)

Seller A wants to sell his NFT with tokenId 2. He then construct a merkle proof from the position (1), together with tokenId to take this offer

acceptOffer(tokenId 2, merkleProof 
0x0000000000000000000000000000000000000000000000000000000000000001,0x2e174c10e159ea99b867ce3205125c24a42d128804e4070ed6fcc8cc98166aa0,0xfe61ef965cf1e53f5466e990b0025336f1fc98844e4eaec8566fe3cbdaf18ef3])

Seller B has only tokenId 6, he would have no ways to accept this offer.

```


### Build using Foundry

```forge install```

```forge test```

### Merkle Generator From
---
[https://github.com/dmfxyz/murky](https://github.com/dmfxyz/murky)
