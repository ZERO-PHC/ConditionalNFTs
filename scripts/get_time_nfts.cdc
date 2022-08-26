
import TimeNFT  from "../contracts/TimeNFT.cdc"
import MetadataViews from "../contracts/MetadataViews.cdc"

pub fun main(address: Address): [TimeNFT.NFTMetaData] {
  let collection = getAccount(address).getCapability(TimeNFT.CollectionPublicPath)
                    .borrow<&{MetadataViews.ResolverCollection}>()
                    ?? panic("Could not borrow a reference to the nft collection")
  let ids = collection.getIDs()
  let answer: [TimeNFT.NFTMetaData] = []
  for id in ids {
    
    let nft = collection.borrowViewResolver(id: id)
    let view = nft.resolveView(Type<TimeNFT.NFTMetaData>())!
    let display = view as! TimeNFT.NFTMetaData
    answer.append(display)
  }
    
  return answer
}