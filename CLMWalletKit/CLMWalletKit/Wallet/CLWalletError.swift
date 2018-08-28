//
//  CLWalletError.swift
//  EthereumKit
//
//  Created by admin on 2018/8/8.
//  Copyright © 2018年 yuzushioh. All rights reserved.
//

import Foundation
public enum CLWalletError: Error {
    case invalidPassword
    case invalidMnemonic
    case invalidType
    case invalidAddressRepeat
    case loadFileError
}
