import ConditionalNFTs from "../contracts/ConditionalNFTs.cdc"
import NonFungibleToken from "../contracts/NonFungibleToken.cdc"
import MetadataViews from "../contracts/MetadataViews.cdc"

transaction(name: String, description: String, thumbnail: String, type: String, timestamp: UFix64, expirationTime:UFix64) {
    let RecipientCollection: &ConditionalNFTs.Collection{NonFungibleToken.CollectionPublic}

    

    prepare(signer: AuthAccount) {
  
    
    //SETUP EXAMPLE NFT COLLECTION
    if signer.borrow<&ConditionalNFTs.Collection>(from: ConditionalNFTs.CollectionStoragePath) == nil {
      signer.save(<- ConditionalNFTs.createEmptyCollection(), to: ConditionalNFTs.CollectionStoragePath)
      signer.link<&ConditionalNFTs.Collection{NonFungibleToken.CollectionPublic, MetadataViews.ResolverCollection}>(ConditionalNFTs.CollectionPublicPath, target: ConditionalNFTs.CollectionStoragePath)
    }
    
    self.RecipientCollection = signer.getCapability(ConditionalNFTs.CollectionPublicPath)
                                .borrow<&ConditionalNFTs.Collection{NonFungibleToken.CollectionPublic}>()!

    }


    execute {
      ConditionalNFTs.mintNFT(recipient: self.RecipientCollection, name: name, description: description, thumbnail: thumbnail, type: type,  timestamp: timestamp, expirationTime: expirationTime)
    }
  } 