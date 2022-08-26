import TimeNFT from "../contracts/TimeNFT.cdc"
import NonFungibleToken from "../contracts/NonFungibleToken.cdc"
import MetadataViews from "../contracts/MetadataViews.cdc"

transaction(name: String, description: String, thumbnail: String, type: String) {
    let RecipientCollection: &TimeNFT.Collection{NonFungibleToken.CollectionPublic}
    let timestamp: UFix64
    let expirationTime: UFix64
    

    prepare(signer: AuthAccount) {
    self.timestamp = getCurrentBlock().timestamp
    self.expirationTime = self.timestamp + 60.0
    
  
    //SETUP EXAMPLE NFT COLLECTION
    if signer.borrow<&TimeNFT.Collection>(from: TimeNFT.CollectionStoragePath) == nil {
      signer.save(<- TimeNFT.createEmptyCollection(), to: TimeNFT.CollectionStoragePath)
      signer.link<&TimeNFT.Collection{NonFungibleToken.CollectionPublic, MetadataViews.ResolverCollection}>(TimeNFT.CollectionPublicPath, target: TimeNFT.CollectionStoragePath)
    }
    
    self.RecipientCollection = signer.getCapability(TimeNFT.CollectionPublicPath)
                                .borrow<&TimeNFT.Collection{NonFungibleToken.CollectionPublic}>()!

    }


    execute {
      TimeNFT.mintNFT(recipient: self.RecipientCollection, name: name, description: description, thumbnail: thumbnail, type: type,  timestamp: self.timestamp, expirationTime: self.expirationTime)
    }
  } 
 