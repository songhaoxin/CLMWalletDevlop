// Copyright © 2017-2018 Trust.
//
// This file is part of Trust. The full Trust copyright notice, including
// terms governing use, modification, and redistribution, is contained in the
// file LICENSE at the root of the source code distribution tree.

import Foundation

/// Supported coins.
/// Index based on https://github.com/satoshilabs/slips/blob/master/slip-0044.md
public enum Coin: UInt32 {
    case bitcoin = 0
    case ethereum = 60
    case ethereumClassic = 61
    case poa = 178
    case callisto = 820
    case gochain = 6060
}


public struct TokenObject {
    public var coin: Coin
    //public var index: UInt32
    public var type: TokenObjectType
    public var contract: String = ""
    //public var name: String = ""
    public var symbol: String = ""
    public var decimals: Int = 0
    //public var value: String = ""
    //public var createdAt: Date = Date()
    public var imagePath: String
    
    public init(coin:Coin,type:TokenObjectType,contract:String,symbol:String,decimals:Int,imagePath:String) {
        self.coin = coin
        self.type = type
        self.contract = contract
        self.symbol = symbol;
        self.decimals = decimals
        self.imagePath = imagePath
    }
}

public enum TokenObjectType: String {
    case coin
    case ERC20
}
