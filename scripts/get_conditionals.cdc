
import ConditionalNFTs  from "../contracts/ConditionalNFTs.cdc"
import MetadataViews from "../contracts/MetadataViews.cdc"

pub fun main(address: Address): [ConditionalNFTs.NFTMetaData] {
  let collection = getAccount(address).getCapability(ConditionalNFTs.CollectionPublicPath)
                    .borrow<&{MetadataViews.ResolverCollection}>()
                    ?? panic("Could not borrow a reference to the nft collection")
  let ids = collection.getIDs()
  let answer: [ConditionalNFTs.NFTMetaData] = []
  for id in ids {
    
    let nft = collection.borrowViewResolver(id: id)
    let view = nft.resolveView(Type<ConditionalNFTs.NFTMetaData>())!
    let display = view as! ConditionalNFTs.NFTMetaData
    answer.append(display)
  }
    
  return answer
}