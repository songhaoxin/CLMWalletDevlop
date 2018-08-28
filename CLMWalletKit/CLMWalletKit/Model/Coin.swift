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

public struct CoinObject {
    let coin:Coin
    let index:Int
    
}



enum TokenObjectType: String {
    case coin
    case ERC20
}

/*
 final class TokenObject: Object, Decodable {
 static let DEFAULT_BALANCE = 0.00
 static let DEFAULT_ORDER = 100000
 
 @objc dynamic var contract: String = ""
 @objc dynamic var name: String = ""
 
 @objc private dynamic var rawCoin = -1
 public var coin: Coin {
 get { return Coin(rawValue: rawCoin)! }
 set { rawCoin = newValue.rawValue }
 }
 
 @objc private dynamic var rawType = ""
 public var type: TokenObjectType {
 get { return TokenObjectType(rawValue: rawType)! }
 set { rawType = newValue.rawValue }
 }
 
 @objc dynamic var symbol: String = ""
 @objc dynamic var decimals: Int = 0
 @objc dynamic var value: String = ""
 @objc dynamic var isCustom: Bool = false
 @objc dynamic var isDisabled: Bool = false
 @objc dynamic var balance: Double = DEFAULT_BALANCE
 @objc dynamic var createdAt: Date = Date()
 @objc dynamic var order: Int = DEFAULT_ORDER
 
 convenience init(
 contract: String = "",
 name: String = "",
 coin: Coin,
 type: TokenObjectType,
 symbol: String = "",
 decimals: Int = 0,
 value: String,
 isCustom: Bool = false,
 isDisabled: Bool = false,
 order: Int = DEFAULT_ORDER
 ) {
 */

/*
 extension Coin {
 public func derivationPath(at index: Int) -> DerivationPath {
 switch self {
 case .bitcoin:
 return DerivationPath(purpose: 44, coinType: self.rawValue, account: 0, change: 0, address: index)
 case .ethereum,
 .poa,
 .ethereumClassic,
 .callisto,
 .gochain:
 return DerivationPath(purpose: 44, coinType: self.rawValue, account: 0, change: 0, address: index)
 }
 }
 }
 
 static let current: Config = Config()
 var servers: [Coin] {
 return [
 Coin.ethereum,
 Coin.ethereumClassic,
 Coin.poa,
 Coin.callisto,
 Coin.gochain,
 ]
 }
 */
