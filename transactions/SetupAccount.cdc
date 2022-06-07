import NonFungibleToken from "../contracts/NonFungibleToken.cdc"
import MetadataViews from "../contracts/MetadataViews.cdc"
import Samples from "../contracts/Samples.cdc"
// This transaction is what an account would run
// to set itself up to receive NFTs

transaction {

    prepare(signer: AuthAccount) {
        // Return early if the account already has a collection
        if signer.borrow<&Samples.Collection>(from: Samples.CollectionStoragePath) != nil {
            return
        }

        // Create a new empty collection
        let collection <- Samples.createEmptyCollection()

        // save it to the account
        signer.save(<-collection, to: Samples.CollectionStoragePath)

        // create a public capability for the collection
        signer.link<&{NonFungibleToken.CollectionPublic, MetadataViews.ResolverCollection}>(
            Samples.CollectionPublicPath,
            target: Samples.CollectionStoragePath
        )
    }

    execute {
      log("Setup account")
    }
}