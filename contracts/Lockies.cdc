import NonFungibleToken from "./NonFungibleToken.cdc"

pub contract Lockies: NonFungibleToken {
    // set locktime when the user locks the nft 
  
  pub var lockInitTime: UFix64
  pub var levelOneLock: UFix64
  
  pub fun checkLock(): Bool {
    return getCurrentBlock().timestamp >= (self.lockInitTime + 30.0)
  }

  // mutate the value of lockInitTime to the current block timestamp
  pub fun lockNFT(nftID: UInt64) {
    // self.lockInitTime = getCurrentBlock().timestamp 
    // set nft initlocktime to current time 
    // set nft unlocktime to current time + level of locktime 
  }

  pub fun getLocktime(): UFix64 {
   return  self.lockInitTime
  }

   pub var totalSupply: UInt64

    pub event ContractInitialized()
    pub event Withdraw(id: UInt64, from: Address?)
    pub event Deposit(id: UInt64, to: Address?)

    pub let CollectionStoragePath: StoragePath
    pub let CollectionPublicPath: PublicPath
    pub let MinterStoragePath: StoragePath

    pub resource NFT: NonFungibleToken.INFT {
        pub let id: UInt64

        pub let name: String
        pub let description: String
        pub let thumbnail: String
        pub var isLocked: Bool


        init(
            name: String,
            description: String,
            thumbnail: String,
            isLocked: Bool,
        ) {
            self.id = self.uuid
            self.name = name
            self.description = description
            self.thumbnail = thumbnail
            self.isLocked = isLocked

            Lockies.totalSupply = Lockies.totalSupply + 1
        }
    }

    pub resource interface CollectionPublic {
        pub fun deposit(token: @NonFungibleToken.NFT)
        pub fun getIDs(): [UInt64]
        pub fun borrowNFT(id: UInt64): &NonFungibleToken.NFT
        pub fun borrowLockies(id: UInt64): &NFT
    }

    pub resource Collection: NonFungibleToken.Provider, NonFungibleToken.Receiver, NonFungibleToken.CollectionPublic, CollectionPublic {
        // dictionary of NFT conforming tokens
        // NFT is a resource type with an `UInt64` ID field
        pub var ownedNFTs: @{UInt64: NonFungibleToken.NFT}

        init () {
            self.ownedNFTs <- {}
        }

        // withdraw removes an NFT from the collection and moves it to the caller
        pub fun withdraw(withdrawID: UInt64): @NonFungibleToken.NFT {
            //TODO: check if the isLocked state field, if it is true panic and communicate that the nft is locked
            let token <- self.ownedNFTs.remove(key: withdrawID) ?? panic("missing NFT")

            emit Withdraw(id: token.id, from: self.owner?.address)

            return <-token
        }

        // deposit takes a NFT and adds it to the collections dictionary
        // and adds the ID to the id array
        pub fun deposit(token: @NonFungibleToken.NFT) {
            let token <- token as! @Lockies.NFT

            let id: UInt64 = token.uuid

            // add the new token to the dictionary which removes the old one
            self.ownedNFTs[id] <-! token

            emit Deposit(id: id, to: self.owner?.address)
        }

        // getIDs returns an array of the IDs that are in the collection
        pub fun getIDs(): [UInt64] {
            return self.ownedNFTs.keys
        }

        // borrowNFT gets a reference to an NFT in the collection
        // so that the caller can read its metadata and call its methods
        pub fun borrowNFT(id: UInt64): &NonFungibleToken.NFT {
            return &self.ownedNFTs[id] as &NonFungibleToken.NFT
        }

        pub fun borrowLockies(id: UInt64): &NFT {
            let nft = &self.ownedNFTs[id] as auth &NonFungibleToken.NFT
            return nft as! &NFT
        }

        destroy() {
            destroy self.ownedNFTs
        }
    }

    // public function that anyone can call to create a new empty collection
    pub fun createEmptyCollection(): @NonFungibleToken.Collection {
        return <- create Collection()
    }


    pub resource Minter {
        // mintNFT mints a new NFT with a new ID
        // and deposit it in the recipients collection using their collection reference
        pub fun mintNFT(
            recipient: &Lockies.Collection{NonFungibleToken.Receiver},
            name: String,
            description: String,
            thumbnail: String,
            isLocked: Bool,
        ) {
            // create a new NFT
            var newNFT <- create NFT(
                name: name,
                description: description,
                thumbnail: thumbnail,
                isLocked: isLocked
            )

            // deposit it in the recipient's account using their reference
            recipient.deposit(token: <-newNFT)
        }
    }

  
  init() {
    // Initialize the locks
        self.lockInitTime = 0.0
    
        self.levelOneLock = 60.0
    // Initialize the total supply
        self.totalSupply = 0

    // Set the named paths
        self.CollectionStoragePath = /storage/LockiesCollection
        self.CollectionPublicPath = /public/LockiesCollection
        self.MinterStoragePath = /storage/LockiesMinter

        self.account.save(<- create Minter(), to: self.MinterStoragePath)

        emit ContractInitialized()
  }
  
}
 