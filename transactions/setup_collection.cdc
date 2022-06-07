import Lockies from "../contracts/Lockies.cdc"
import NonFungibleToken from "../contracts/NonFungibleToken.cdc"

transaction() {
  
  prepare(signer: AuthAccount) {
    if signer.borrow<&Lockies.Collection>(from: Lockies.CollectionStoragePath) == nil {
      signer.save(<- Lockies.createEmptyCollection(), to: Lockies.CollectionStoragePath)
      signer.link<&Lockies.Collection{NonFungibleToken.CollectionPublic, NonFungibleToken.Receiver, Lockies.CollectionPublic}>(Lockies.CollectionPublicPath, target: Lockies.CollectionStoragePath)
    }
  }

  execute {
    log("setted")
  }
}
 