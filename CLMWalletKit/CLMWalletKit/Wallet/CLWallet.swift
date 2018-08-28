//
//  CLMWallet.swift
//  EthereumKit
//
//  Created by admin on 2018/8/7.
//  Copyright © 2018年 yuzushioh. All rights reserved.
//

import UIKit

public class CLWallet: NSObject,NSCoding {

    public var id: String = ""
    public var name: String = ""
    public var type: WalletType = .hierarchicalDeterministicWallet
    private var completedBackup: Bool = false
    public var mainWallet: Bool = false
    public var wallet:Wallet? = nil
    public var hdWallet:HDWallet? = nil
    
    public var coinList:[Coin] = [Coin]()
    
    public var userPassword: String = ""
    public var mnemonicWords: [String] = [""]
    public var privateKey:String = ""
    
    private var datadir = CLWalletConfig.dataDir
    
    
    // MARK:- 构造方法
    
    /// 创建普通钱包
    public init(dataDir:String!,wallet:Wallet!,name:String!,password:String!) {
        self.type = .encryptedKey
        
        //对用户的密码进行加密
        let secPassword = CryptTools.Encode_AES_ECB(strToEncode: password, key: CryptTools.secKey)
        self.userPassword = secPassword
        
        self.id = wallet.generateAddress()
        self.name = name
        self.datadir = dataDir
        self.wallet = wallet
        self.hdWallet = nil
        
        //对私钥使用用户的密码进行加密
        let secPrivateKey = CryptTools.Encode_AES_ECB(strToEncode: wallet.dumpPrivateKey(), key:password)
        self.privateKey = secPrivateKey
        
        super.init()
        self.save()
    }
    
    /// 创建HD钱包
    public init(dataDir:String!,HDWallet:HDWallet!,name:String!,password:String!,mnemonic:[String]) {
        self.type = .hierarchicalDeterministicWallet
        
        //对用户的密码进行加密
        let secPassword = CryptTools.Encode_AES_ECB(strToEncode: password, key: CryptTools.secKey)
        self.userPassword = secPassword
        
        
        self.id = try! HDWallet.mainAddress()
        self.wallet = nil
        self.name = name
        self.datadir = dataDir
        self.hdWallet = HDWallet
        
        //对私钥使用用户的密码进行加密
        let secPrivateKey = CryptTools.Encode_AES_ECB(strToEncode: HDWallet.dumpMainPrivateKey(), key:password)
        self.privateKey = secPrivateKey
        
        let mn = mnemonic.map {
            return CryptTools.Encode_AES_ECB(strToEncode: $0, key: password)
        }
        self.mnemonicWords = mn
        
        
        super.init()
        self.save()
    }
 
    /// 创建一个新的钱包
    public init(dataDir:String!, network: Network!,type:WalletType,name:String! ,password:String!,mnemonic:[String]!) {
        
        let seed = try! Mnemonic.createSeed(mnemonic: mnemonic, withPassphrase: password)
        
        
        switch type {
        case .encryptedKey:
            self.wallet = try! Wallet(seed: seed, network: network, debugPrints: true)
            self.id = (wallet?.generateAddress())!
            
            //对私钥使用用户的密码进行加密
            let secPrivateKey = CryptTools.Encode_AES_ECB(strToEncode: (wallet?.dumpPrivateKey())!, key:password)
            self.privateKey = secPrivateKey
        case .hierarchicalDeterministicWallet:
            self.hdWallet =  HDWallet(seed: seed, network: network)
            self.id = (try! self.hdWallet?.mainAddress())!
        }

        self.type = type
        
        //加密助记词
        let mn = mnemonic.map {
            return CryptTools.Encode_AES_ECB(strToEncode: $0, key: password)
        }
        self.mnemonicWords = mn
        
        
        //对用户的密码进行加密
        let secPassword = CryptTools.Encode_AES_ECB(strToEncode: password, key: CryptTools.secKey)
        self.userPassword = secPassword
        
        self.name = name
        self.datadir = dataDir
        super.init()
        
        //持久化到本地文件中
        self.save()
    }
    
    // MARK:- 公有方法
    public func walletPrivateKey() throws -> String? {
        switch type {
        case .encryptedKey:
            guard let w = self.wallet else {
                throw CLWalletError.invalidType
            }
            return w.dumpPrivateKey()
            
        case .hierarchicalDeterministicWallet:
            guard let w = self.hdWallet else {
                throw CLWalletError.invalidType
            }
            return w.dumpMainPrivateKey()
        }
    }
    ///显示HD钱包中某种币种的地址
    public func adress4HD(coin:Coin) throws -> String {
        switch type {
        case .encryptedKey:
            throw CLWalletError.invalidType
        case .hierarchicalDeterministicWallet:
            return (try self.hdWallet?.generateAddress(coin:coin))!
        }
    }
    
    /// 显示钱包的根地址
    public func address()   -> String {
        switch type {
        case .encryptedKey:
            guard let w = self.wallet else {
                return ""
            }
            return w.generateAddress()
        case .hierarchicalDeterministicWallet:
            guard let w = self.hdWallet else {
                return ""
            }
            return try! w.mainAddress()
            
        }
        
    }
    
    /// 导出“助记词”  （如果钱包是HD类型）
    public func exportMnemonic(password:String) throws -> [String] {
        let secPassword = CryptTools.Encode_AES_ECB(strToEncode: password, key: CryptTools.secKey)
        if userPassword != secPassword {
            throw CLWalletError.invalidPassword
        }
        if type != .hierarchicalDeterministicWallet {
            throw CLWalletError.invalidMnemonic
        }
        self.completedBackup = true
        let mn = self.mnemonicWords.map{
            return CryptTools.Decode_AES_ECB(strToDecode: $0, key: password)
        }
        return mn
    }
    
    /// 导出钱包的私钥
    public func exportPrivateKey(password:String) throws -> String{
        //判断密码是否正确，否则直接抛出异常
        switch type {
        case .encryptedKey:
            guard let wlt = self.wallet else {
                throw CLWalletError.invalidType
            }
            self.completedBackup = true
            return wlt.dumpPrivateKey()
            
        case .hierarchicalDeterministicWallet:
            guard let hdWlt = self.hdWallet else {
                throw CLWalletError.invalidType
            }
            self.completedBackup = true
            return hdWlt.dumpMainPrivateKey()
            
        }
    }
    
    /// 导出HD钱包中的一种币种的私钥
    public func exportPrivateKey(coin:Coin) throws -> String {
        switch type {
        case .encryptedKey:
            throw CLWalletError.invalidType
        case .hierarchicalDeterministicWallet:
            guard let hdWlt = self.hdWallet else {
                throw CLWalletError.invalidType
            }
            return try hdWlt.generatePrivateKey(coin: coin).raw.toHexString()
        }
    }
    
    /// 增加一种币种
    public func addCoin(coin:Coin) {
        if coinList.count == 0 { coinList = [Coin]() }
        coinList.append(coin)
        
    }
    
    /// 删除一种币种
    public func removeCoin(coin:Coin) {
        if coinList.count == 0 {return}
        if let index = coinList.index(of: coin) {
            coinList.remove(at: index)
        }
    }
    
    /// 移除所有的币种
    public func removeAllCoins() {
        coinList.removeAll()
    }
    
    /// 删除持久化的文件
    public func deleteFile() {
        let fileManger = FileManager.default
        let filePath = self.datadir + id + ".plist"
        if fileManger.fileExists(atPath: filePath) {
            try! fileManger.removeItem(atPath: filePath)
        }
    }

    // MARK:- CODING 协议方法
    /// 归档方法
    public func encode(with aCoder: NSCoder){
        //获取用户的密码
        
        aCoder.encode(id, forKey: "id")
        aCoder.encode(name,forKey:"name")
        aCoder.encode(type.rawValue, forKey: "type")
        
        aCoder.encode(privateKey, forKey: "privateKey")
        aCoder.encode(mnemonicWords, forKey: "mnemonicWords")
        aCoder.encode(userPassword, forKey: "userPassword")
    }
    
    /// 解档方法
    required public init(coder aDecoder: NSCoder){
        super.init()
        id = aDecoder.decodeObject(forKey: "id") as! String
        name = aDecoder.decodeObject(forKey: "name") as! String
        type = WalletType(rawValue: aDecoder.decodeObject(forKey: "type") as! WalletType.RawValue)!
        
        privateKey = aDecoder.decodeObject(forKey: "privateKey") as! String
        mnemonicWords = aDecoder.decodeObject(forKey: "mnemonicWords") as! [String]
        userPassword = aDecoder.decodeObject(forKey: "userPassword") as! String
    }
    
    
    // MARK:- 签名相关方法
    public func sign(rawTransaction: RawTransaction,coin:Coin,network:Network) throws -> String {
        var privateSignKey: String = ""
        if type == .encryptedKey {
            //解密password
            let pass = CryptTools.Decode_AES_ECB(strToDecode: self.userPassword, key: CryptTools.secKey)
            
            privateSignKey = CryptTools.Encode_AES_ECB(strToEncode: self.privateKey, key: pass)
        } else if type == .hierarchicalDeterministicWallet {
            privateSignKey = try self.exportPrivateKey(coin: coin)
        }
        
        ///这个地方需要重构，以适应所有的币种签名（因为不同的币种签名方法是不一样的），目前只考虑以太坊一种情况
        let signWallet = Wallet(network: network, privateKey: privateSignKey, debugPrints: false)
        return try signWallet.sign(rawTransaction: rawTransaction)
    }

    // MARK:- 私有方法
    /// 持久化钱包
    private func save() {
        checkFileDir()
        NSKeyedArchiver.archiveRootObject(self, toFile: datadir + id + ".plist")
    }
    
    private func checkFileDir() {
        let fileManager = FileManager.default
        if !fileManager.fileExists(atPath: datadir) {
            try? fileManager.createDirectory(atPath: datadir, withIntermediateDirectories: true, attributes: nil)
        }
    }

}

extension Coin {
    
}
