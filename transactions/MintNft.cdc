import NonFungibleToken from "../contracts/NonFungibleToken.cdc"
import Samples from "../contracts/Samples.cdc"


// This script uses the NFTMinter resource to mint a new NFT
// It must be run with the account that has the minter resource
// stored in /storage/NFTMinter

transaction{

    // local variable for storing the minter reference
    let minter: &Samples.NFTMinter

    prepare(signer: AuthAccount) {
        // borrow a reference to the NFTMinter resource in storage
        self.minter = signer.borrow<&Samples.NFTMinter>(from: Samples.MinterStoragePath)
            ?? panic("Could not borrow a reference to the NFT minter")
    }

    execute {
        // Borrow the recipient's public NFT collection reference
        let receiver = getAccount(0x9b19adaf4947d5b5)
            .getCapability(Samples.CollectionPublicPath)
            .borrow<&{NonFungibleToken.CollectionPublic}>()
            ?? panic("Could not get receiver reference to the NFT Collection")

        // Mint the NFT and deposit it to the recipient's collection
        self.minter.mintNFT(
            recipient: receiver,
            name: "Second NFT",
            description: "The Best NFT",
            thumbnail: "NFT: Thumbnail",
            power: "The best",
            will: "The strongest",
            determination: "unbeatable"
        )

        log("Minted an NFT")
    }
}