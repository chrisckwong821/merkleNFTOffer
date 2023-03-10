## TraitbasedNFTOffer
[![tests](https://github.com/chrisckwong821/TraitbasedNFTOffer/actions/workflows/unitTest.yml/badge.svg)](https://github.com/chrisckwong821/TraitbasedNFTOffer/actions/workflows/unitTest.yml)

A demo contract to offer bid for a custom list of tokenIds through merkle root

### Problem

There is not yet a way for a bidder to bid for a specific list of NFT within a collection, they can only make collection offer; or individual offer.

### Solution

1. Allow bidder to sign an offer with a merkle root, which comes from hashes of a custom list of tokenIds. This list consists of the Ids that The bidder is willing to accept.

2. Seller has to provide a merkle proof when accepting this offer.


### Build using Foundry

```forge install```

```forge test```

### Merkle Generator From
---
[https://github.com/dmfxyz/murky](https://github.com/dmfxyz/murky)