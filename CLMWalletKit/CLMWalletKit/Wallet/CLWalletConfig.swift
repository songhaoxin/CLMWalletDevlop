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

}
