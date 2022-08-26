
 import TimeNFT  from "../contracts/TimeNFT.cdc"

 
 pub fun main (): [UInt64] {
        return TimeNFT.expiredNFTs
 }