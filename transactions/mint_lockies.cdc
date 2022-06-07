import Lockies from "../contracts/Lockies.cdc"
import NonFungibleToken from "../contracts/NonFungibleToken.cdc"

transaction(names: [String], descriptions: [String], thumbnails: [String], isLocked: [Bool], recipient: Address) {
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
    var i = 0
    while i < names.length {
      self.Minter.mintNFT(recipient: self.RecipientCollection, name: names[i], description: descriptions[i], thumbnail: thumbnails[i], isLocked[i])
    }
  }
}