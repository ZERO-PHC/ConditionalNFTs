import MetadataViews from "../contracts/MetadataViews.cdc"

pub fun main(): [Type]{
    let address: Address = 0x02
    let id: UInt64 = 0
    
    let account = getAccount(address)

    let collection = account
        .getCapability(/public/sampleNFTCollection)
        .borrow<&{MetadataViews.ResolverCollection}>()
        ?? panic("Could not borrow a reference to the collection")

    let nft = collection.borrowViewResolver(id: id)

    // Get the basic display information for this NFT


    return nft.getViews()
}