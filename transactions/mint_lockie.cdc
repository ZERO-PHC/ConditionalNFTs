import Lockies from "../contracts/Lockies.cdc"
import NonFungibleToken from "../contracts/NonFungibleToken.cdc"

transaction(name: String, description: String, thumbnail: String, recipient: Address, isLocked: Bool) {
  let Minter: &Lockies.Minter
  let RecipientCollection: &Lockies.Collection{NonFungibleToken.Receiver}
  
  prepare(signer: AuthAccount) {
    self.Minter = signer.borrow<&Lockies.Minter>(from: Lockies.MinterStoragePath)
                    ?? panic("This is not the Minter")

    self.RecipientCollection = getAccount(recipient).getCapability(Lockies.CollectionPublicPath)
                                .borrow<&Lockies.Collection{NonFungibleToken.Receiver}>()
                                ?? panic("Receiver does not have an NFT Collection")
  }

  execute {
    self.Minter.mintNFT(recipient: self.RecipientCollection, name: name, description: description, thumbnail: thumbnail, isLocked: isLocked)
  }
}