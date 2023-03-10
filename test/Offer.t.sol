// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import "forge-std/Test.sol";
import "forge-std/Vm.sol";

import "../src/TraitbasedOffer.sol";
import "../src/mock/MOCKERC20.sol";
import "../src/mock/MOCKERC721.sol";

contract OfferTest is Test {
    TraitbasedOffer public traitbasedOffer;
    MOCKERC20 public WETH;
    MOCKERC721 public COLLECTION;

    uint256 buyerPrivateKey = 0xABCD;
    uint256 sellerPrivateKey = 0xABCDE;
    //seller private key is not needed anyway
    address internal buyer = vm.addr(buyerPrivateKey);
    address internal seller = vm.addr(sellerPrivateKey);

    uint256[] internal tokenIdsToAccept = [1,2,3,4,100];
    uint256 internal price = 1 ether;
    

    function setUp() public {
        vm.deal(buyer, 100 ether);
        vm.deal(seller, 100 ether);

        WETH = new MOCKERC20();
        WETH.mint(buyer, 100 ether);

        traitbasedOffer = new TraitbasedOffer(address(WETH));

        COLLECTION = new MOCKERC721();
        
        vm.prank(buyer);
        //buyer approve traitbasedOffer to transfer ERC20
        WETH.approve(address(traitbasedOffer), 2**256 - 1);

        vm.prank(seller);
        // seller approve traitbasedOffer to transfer ERC721
        COLLECTION.setApprovalForAll(address(traitbasedOffer), true);
    }

    function testTakeOffer() public {

        // convert uint256 into bytes32 in order for hashing
        bytes32[] memory tokenIdsInBytes = new bytes32[](tokenIdsToAccept.length);

        for(uint256 i=0;i < tokenIdsToAccept.length;++i) {
            tokenIdsInBytes[i] = bytes32(abi.encodePacked(tokenIdsToAccept[i]));
        }

        // the root that the offer would be committed to
        bytes32 root = traitbasedOffer.generateRoot(tokenIdsInBytes);
        
        // test cases for executing each tokenId in the accept list
        for(uint256 i=0;i < tokenIdsToAccept.length;++i) {
            
            uint256 tokenToSell = tokenIdsToAccept[i];

            COLLECTION.mint(seller, tokenToSell);
            bytes32[] memory proof = traitbasedOffer.generateProofForTokenId(tokenIdsInBytes, i);

            uint8 v;
            bytes32 r;
            bytes32 s;

            TraitbasedOffer.Offer memory offer = TraitbasedOffer.Offer(buyer, address(COLLECTION), price, root, v, r, s);

            (v, r, s) = vm.sign(
            buyerPrivateKey,
            keccak256(abi.encodePacked("\x19\x01", traitbasedOffer.DOMAIN_SEPARATOR(), traitbasedOffer.offerDigest(offer))));
            
            offer.v = v;
            offer.r = r;
            offer.s = s;

            uint256 BuyerBalanceBefore = WETH.balanceOf(buyer);
            uint256 SellerBalanceBefore = WETH.balanceOf(seller);

            vm.prank(seller);
            traitbasedOffer.fulfillTraitbasedOrder(offer, tokenToSell, proof);

            uint256 BuyerBalanceAfter = WETH.balanceOf(buyer);
            uint256 SellerBalanceAfter = WETH.balanceOf(seller);

            assertEq(BuyerBalanceBefore - price,  BuyerBalanceAfter);
            assertEq(SellerBalanceBefore + price, SellerBalanceAfter);
            assertEq(COLLECTION.ownerOf(tokenToSell), buyer);
        }
        
    }

}
