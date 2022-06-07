import Lockies from "../contracts/Lockies.cdc"

pub fun main(address: Address): [&Lockies.NFT] {
  let collection = getAccount(address).getCapability(Lockies.CollectionPublicPath)
                    .borrow<&Lockies.Collection{Lockies.CollectionPublic}>()
                    ?? panic("Could not borrow a reference to the collection")
  let ids = collection.getIDs()

  let answer: [&Lockies.NFT] = []
  for id in ids {
    let nft = collection.borrowLockies(id: id)
    answer.append(nft)
  }

  log(answer)

  return answer
}