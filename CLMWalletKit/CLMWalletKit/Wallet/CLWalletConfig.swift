//
//  CLWalletConfig.swift
//  EthereumKit
//
//  Created by admin on 2018/8/9.
//  Copyright © 2018年 yuzushioh. All rights reserved.
//

import Foundation

public struct CLWalletConfig {
    //网络类型
    public static let network: Network = .mainnet
    //Network.private(chainID: 10, testUse: true)
    
    // 钱包的持久化路径
    public static let dataDir = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0] + "/data/"
    
    public static var supportTokens: [TokenObject] {
        return [
            TokenObject(coin: .bitcoin,  type: .coin, contract: "", symbol: "", decimals: 0, imagePath: ""),
            TokenObject(coin: .ethereum, type: .coin, contract: "", symbol: "ETH", decimals: 0, imagePath: ""),
            TokenObject(coin: .ethereum,  type: .ERC20, contract: "0x39ACa4347248873842dDfB91948aaAC3268682bD", symbol: "BGFT", decimals: 18, imagePath: "")
        ]
    }

}
