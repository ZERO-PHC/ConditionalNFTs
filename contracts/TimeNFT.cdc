import NonFungibleToken from "./NonFungibleToken.cdc"
import MetadataViews from "./MetadataViews.cdc"


pub contract TimeNFT: NonFungibleToken {

        pub var totalSupply: UInt64
        pub event ContractInitialized()
        pub event Withdraw(id: UInt64, from: Address?)
        pub event Deposit(id: UInt64, to: Address?)
        pub let CollectionStoragePath: StoragePath
        pub let CollectionPublicPath: PublicPath
        pub var expiredNFTs: [UInt64]

         // add nft id to the expiredNFTs array
        pub fun addExpiredNFT(id: UInt64) {
                self.expiredNFTs.append(id)
        }

        pub fun getExpiredIDs(): [UInt64] {
                return self.expiredNFTs
        }

        pub struct NFTMetaData {
            pub let id: UInt64
            pub let name: String
            pub let description: String
            pub let thumbnail: String
            pub let type: String
            pub let timestamp: UFix64
            pub let expirationTime: UFix64

            init(_id: UInt64, _name: String, _description: String, _thumbnail: String, _type: String, _timestamp: UFix64, _expirationTime: UFix64) {
                self.id = _id
                self.name = _name
                self.description = _description
                self.thumbnail = _thumbnail
                self.type = _type
                self.timestamp = _timestamp
                self.expirationTime = _expirationTime
                
            }
        }
        pub resource NFT: NonFungibleToken.INFT, MetadataViews.Resolver {
            pub let id: UInt64
            pub let name: String
            pub let description: String
            pub let thumbnail: String
            pub let type: String
            pub let timestamp: UFix64
            pub let expirationTime: UFix64

            init( name: String, description: String, thumbnail: String, type: String, timestamp: UFix64, expirationTime: UFix64) {
                self.id = self.uuid
                self.name = name
                self.description = description
                self.thumbnail = thumbnail
                self.type = type
                self.timestamp = timestamp
                self.expirationTime = expirationTime

                TimeNFT.totalSupply = TimeNFT.totalSupply + 1
            }
        
            pub fun getViews(): [Type] {
                return [ Type<MetadataViews.Display>(), Type<NFTMetaData>()]
            }

            pub fun resolveView(_ view: Type): AnyStruct? {
                switch view {
                    case Type<MetadataViews.Display>():
                        return MetadataViews.Display(
                            name: self.name,
                            description: self.description,
                            thumbnail: MetadataViews.HTTPFile( url: self.thumbnail )
                        )
                    case Type<NFTMetaData>():
                    return NFTMetaData(
                        _id: self.id,
                        _name: self.name,
                        _description: self.description,
                        _thumbnail: self.thumbnail,
                        _type: self.type,
                        _timestamp: self.timestamp,
                        _expirationTime: self.expirationTime
                    )
                }
                return nil
            }
        }
        

        
        pub resource Collection:  NonFungibleToken.Provider, NonFungibleToken.Receiver, NonFungibleToken.CollectionPublic, MetadataViews.ResolverCollection {
            // dictionary of NFT conforming tokens
            // NFT is a resource type with an \`UInt64\` ID field
            pub var ownedNFTs: @{UInt64: NonFungibleToken.NFT}

            init () {
                self.ownedNFTs <- {}
            }

             
                    // withdraw removes an NFT from the collection and moves it to the caller
            pub fun withdraw(withdrawID: UInt64): @NonFungibleToken.NFT {
                let token <- self.ownedNFTs.remove(key: withdrawID) ?? panic("missing NFT")
                emit Withdraw(id: token.id, from: self.owner?.address)
                return <-token
            }
            // deposit takes a NFT and adds it to the collections dictionary
            // and adds the ID to the id array
            pub fun deposit(token: @NonFungibleToken.NFT) {
                let token <- token as! @TimeNFT.NFT
                let id: UInt64 = token.uuid
                // add the new token to the dictionary which removes the old one
                self.ownedNFTs[id] <-! token
                emit Deposit(id: id, to: self.owner?.address)
            }
            // getIDs returns an array of the IDs that are in the collection
            pub fun getIDs(): [UInt64] { return self.ownedNFTs.keys }

            // borrowNFT gets a reference to an NFT in the collection
            // so that the caller can read its metadata and call its methods
            pub fun borrowNFT(id: UInt64): &NonFungibleToken.NFT { 
                return (&self.ownedNFTs[id] as &NonFungibleToken.NFT?)! 
            }
            pub fun borrowViewResolver(id: UInt64): &AnyResource{MetadataViews.Resolver} {
                let nft = (&self.ownedNFTs[id] as auth &NonFungibleToken.NFT?)!
                let TimeNFT = nft as! &TimeNFT.NFT
                return TimeNFT as &AnyResource{MetadataViews.Resolver}
            }
            destroy() {
                destroy self.ownedNFTs
            }
    }

   

        // public function that anyone can call to create a new empty collection
        pub fun createEmptyCollection(): @NonFungibleToken.Collection {
            return <- create Collection()
        }

        pub fun mintNFT(
                recipient: &TimeNFT.Collection{NonFungibleToken.CollectionPublic},
                name: String, description: String, thumbnail: String, type: String, timestamp: UFix64,
                expirationTime: UFix64,) {
                var newNFT <- create NFT( name: name, description: description, thumbnail: thumbnail, type: type, timestamp: timestamp,
                expirationTime: expirationTime,
                )
                // deposit it in the recipient's account using their reference
                recipient.deposit(token: <-newNFT)
            }

    init() {
        // Initialize the total supply
        self.totalSupply = 0
        self.expiredNFTs = []

        // Set the named paths
        self.CollectionStoragePath = /storage/TimeNFTCollection
        self.CollectionPublicPath = /public/TimeNFTCollection
        emit ContractInitialized()
    }
}