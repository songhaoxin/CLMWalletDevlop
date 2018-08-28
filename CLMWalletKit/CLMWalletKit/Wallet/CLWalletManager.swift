//
//  CLWalletManager.swift
//  EthereumKit
//
//  Created by admin on 2018/8/8.
//  Copyright © 2018年 yuzushioh. All rights reserved.
//

import UIKit

public class CLWalletManager: NSObject {

    // MARK:- 属性
    // 单例
    public static let `default` = CLWalletManager()
    
    // 归档钱包的路径
    public var dataDir = CLWalletConfig.dataDir
    
    // 请求的网络
    public var network: Network = CLWalletConfig.network

    //钱包列表
    public var wallets: [CLWallet]! = [CLWallet]()
    
    // 获取主钱包
    public var mainWallet:CLWallet? {
        get {
            if wallets.count == 0 { return nil }
            for item in wallets {
                if item.mainWallet == true { return item }
            }
            return nil
        }
        set {
            if newValue != mainWallet {
                mainWallet?.mainWallet = false
                newValue?.mainWallet = true   
            }
        }
    }
    
    // MARK:- 构造函数
    public override init() {
        super.init()
        self.checkFileDir()
        self.loadWallets()
    }
    
    // MARK:- 公有方法
    /// 创建钱包
    public func createWallet(name:String!,password:String) throws -> (CLWallet,[String]){
        return try createWallet(name: name, password: password, language: .chinese)
    }
    
    public func createWallet(name:String!,password:String,language:WordList) throws -> (CLWallet,[String]){
        let mnemonic = Mnemonic.create(strength: .normal, language: language)
        let wallet = CLWallet(dataDir:dataDir ,network: network, type: .hierarchicalDeterministicWallet, name: name, password: password,mnemonic:mnemonic)
        for item in wallets {
            if item.id == wallet.id {
                throw CLWalletError.invalidAddressRepeat
            }
        }
        if wallets.count == 0 { wallet.mainWallet = true }
        self.wallets.append(wallet)
        return (wallet,mnemonic)
    }
    
 
    /// 判断是否已经存在钱包账户
    public func hasWallet() -> Bool {
        if self.wallets.count > 0 {
            return true
        }
        return false
    }
    
    // 选择主钱包
    
    
    
    

    /// 从助记词中导入钱包HD
    public func `import`(mnemonic:[String],password:String,name:String!) throws -> CLWallet? {

        //let seed = try! Mnemonic.createSeed(mnemonic: mnemonic, withPassphrase: password)
        // 为了兼容安卓目前的代码，临时去掉通过密码生成助记词
        
        let seed = try! Mnemonic.createSeed(mnemonic: mnemonic)
        let wallet = HDWallet(seed: seed, network: .mainnet)
        let mWallet = CLWallet(dataDir: dataDir, HDWallet: wallet, name: name, password: password,mnemonic: mnemonic)
        if exist(wallet: mWallet) {
            throw CLWalletError.invalidAddressRepeat
        }
        self.wallets.append(mWallet)
        return mWallet
    }
    
    
    /// 从私钥中导入钱包
    public func `import`(privateKey:String!,password:String,name:String!)  -> CLWallet{
        let w = Wallet(network: network, privateKey: privateKey, debugPrints: false)
        let cw = CLWallet(dataDir: dataDir, wallet: w, name: name, password: password)
        self.wallets.append(cw)
        return cw
    }
    
    /// 删除指定的钱包
    public func remove(clwallet:CLWallet!) {
        clwallet.deleteFile()
        if self.wallets.count == 0 {return}
        if let index = self.wallets.index(of: clwallet) {
            self.wallets.remove(at: index)
        }
    }
    
    // MARK:- 私有方法
    /// 从归档文件中加载钱包
    private func loadWallets()  {
        let fileManager = FileManager.default
        let dataDirURL = URL(fileURLWithPath: dataDir, isDirectory: true)
        try? fileManager.createDirectory(at: dataDirURL, withIntermediateDirectories: true, attributes: nil)
        
        let accountURLs = try? fileManager.contentsOfDirectory(at: dataDirURL, includingPropertiesForKeys: [], options: [.skipsHiddenFiles])
        for url in accountURLs! {
            let w = NSKeyedUnarchiver.unarchiveObject(withFile: url.path) as? CLWallet
            if w != nil  {
                if exist(wallet: w) {
                    try? fileManager.removeItem(at: url)
                } else {
                    //解密私钥
                    let depassword = CryptTools.Decode_AES_ECB(strToDecode: (w?.userPassword)!, key: CryptTools.secKey)
                    //解密助记词
                    let mn = w?.mnemonicWords.map {
                        return CryptTools.Decode_AES_ECB(strToDecode: $0, key: depassword)
                    }
                    switch w!.type {
                    case .encryptedKey:
                        let deprivateKey = CryptTools.Decode_AES_ECB(strToDecode: (w?.privateKey)!, key: depassword)
                        w?.wallet = Wallet(network: network, privateKey: deprivateKey, debugPrints: false)
                        
                    case .hierarchicalDeterministicWallet:
                        let seed = try! Mnemonic.createSeed(mnemonic: mn!, withPassphrase: depassword)
                        w?.hdWallet =  HDWallet(seed: seed, network: network)
                    }
                    wallets.append(w!)
                }
            } else {
                try? fileManager.removeItem(at: url)
            }
        }
    }
    
    /// 检查指定的钱包是否已经存在
    private func exist(wallet:CLWallet!) -> Bool {
        for itm in wallets {
            if itm.id == wallet.id {
                return true
            }
        }
        return false
    }
    
    private func checkFileDir() {
        let fileManager = FileManager.default
        if !fileManager.fileExists(atPath: dataDir) {
            try? fileManager.createDirectory(atPath: dataDir, withIntermediateDirectories: true, attributes: nil)
        }
    }

}
