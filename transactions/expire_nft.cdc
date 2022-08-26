import TimeNFT from "../contracts/TimeNFT.cdc"

    transaction(id: UInt64) {

        prepare () {

        }
        
        execute {
                TimeNFT.addExpiredNFT(id: id)
        }
    }