//
//  ViewController.swift
//  Demo
//
//  Created by admin on 2018/8/13.
//  Copyright © 2018年 admin. All rights reserved.
//

import UIKit
import CLMWalletKit

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        
        #if false
        /// 使用例子
        #if false
        //1.设置保存钱包数据的文件路径，一个钱包对应一个单独的文件
        //默认为（可选）
        //CLWalletConfig.dataDir = XXXXX
        //2.设置APP支持的币种（可选）
        
        //3. CLWalletManager 的单例对象来管理整个钱包
        // 单例实例化过程中，会从“本地文件”中加载已经存在的钱包到“钱包列表”中
        let m = CLWalletManager.default
        
        // 4.判断是否已经存在钱包
        if m.hasWallet() {
            print("钱包数量：\(m.wallets.count)")
            print(m.wallets)
        }
        
        //5.创建钱包 并获取 助记词（默认是中文的助词）
        let (_,mem) = try! m.createWallet(name: "wallet2", password: "123456")
        print(mem)
        
        //6.如果要选择助词的语言，使用另一个版本，目前只支持中文、英文、日文
        //try! m.createWallet(name:"walletname", password: "123", language: .chinese)
        
        let w = m.wallets[0] //获取要操作的钱包
        //7.根据助记词导出钱包
        let mnemonic = try! w.exportMnemonic(password: "123456")
        print(mnemonic)
        
        //8.导出钱包的私钥（HD钱包是指根私钥，非HD钱包是指币种对应的私钥）
        let privateKeyString = try! w.exportPrivateKey(coin: .ethereum)
        print(privateKeyString)
        
        //9.获取钱包的所有的币种列表
        _ = w.tokenList
        
        //10.添加币种
        //配置文件中已经默认设置了三种币种
        // ---> 0：比特币 1：以太币 3:BGFT 代币
        // 10-1：
        // 从配置文件中获取
        /*
        var BGFT = CLWalletConfig.supportTokens[3]
        BGFT.imagePath = "someimagename.png" //设置这个币对应的图片全名称
        w.addToken(token: BGFT)
        */
        //或者自己创建一个币
        let ethToken = TokenObject(coin: .ethereum, type: .coin, contract: "", symbol: "", decimals: 0, imagePath: "") //以太币
        
        let someToken = TokenObject(coin: .ethereum,type: .ERC20, contract: "0x39ACa4347248873842dDfB91948aaAC3268682bD", symbol: "BGFT", decimals: 18, imagePath: "")
        // 其中：
        // coin 表示所属的主币种 (查看Coin枚举类型）
        // index:表示在主币种的序号，同一主币种的各种代币的序号必须唯一，因为它决定了地址的生成。如果是主币应设为0
        // type: (coin/ERC20)分别表示是主币还是代币
        // contract: 当币为代币时，表示该代币对应的 智能合约地址 ，主币时为空
        // symbol: 币的名称，如果是代币，会有唯一的确定的名字， 可用于显示在界面上名称
        // decimals:代币的最小单位（小数点后位数）比如18，则其最小能表示的数值为0.00000001(小数点后18位）
        // imagePath:表示币的图片名称，用于显示在界面上
        
        // 10-2:增加币到钱包的币种列表中
        w.addToken(token: ethToken)
        w.addToken(token: someToken)
        
        
 
        
        //11.移除币种
        //w.removeToken(token: someToken)
        
        //12.移除所有的币种
        //w.removeAllTokens()
        
        //13. 获取HD钱包中指定币种的地址
        var addrress = try! w.address4HD(token: someToken)
        print(addrress)
        
        //14.获取非HD钱包的地址或者HD钱包的根地址
        addrress = w.address()
        print(addrress)
        
        //15.获取钱包名称
        print(w.name)
        
        //16.获取钱包交易密码
        print(w.userPassword)
        
        //17.切换钱包（多个钱包时）TODO:
        /* 钱包保存在m.wallets 数组中，由业务方自行决定操作哪一个 */
        /* 在下一版中，会增加currentWallet属性，表示当前正在操作的钱包，并提供切换功能 */
        
        //18.转账
        // 18-1 以太币的转帐
        //第一步：创建交易数据
        let rt = RawTransaction.init(value: try! Converter.toWei(ether: "0.00001"),  //需要转出的金额，单位是 以太币，调用方法转换成Wei,
            to: "",//收币方地址
            gasPrice: Converter.toWei(GWei: 10),//该笔交易的价格，调用服务方的接口计算一个基准值，然后在界面上设置一个滑动条，最低值为服务方返回值，增加一个合理范围的值，供用户选择,
            gasLimit: 21000,//调用服务方接口,
            nonce: 0)//调用服务方接口提供
        
        //第二步：用发出方的私钥对交易数据进行签名
        var tx = try! w.sign(rawTransaction: rt, token: someToken, network: CLWalletConfig.network)
        print(tx)//打印签名后的字符串数值
        
        //第三步：把签名后的数据 tx 传给服务方API转发到区块链
        
        // 18-2 代币的转帐
        //第一步：创建交易数据
        let BGFTERC20 = ERC20(contractAddress: someToken.contract, decimal: someToken.decimals, symbol: someToken.symbol)
        let parameterData : Data
        do {
            parameterData = try BGFTERC20.generateDataParameter(toAddress: "0x99c075e934df0183323750e141d4588b085e8f37", amount: "10")
            // toAddress为转帐对方的地址
        } catch let error {
            fatalError("Error:\(error.localizedDescription)")
        }
        
        let rawTransacton = RawTransaction(wei: "0",
                                           to: BGFTERC20.contractAddress,
                                           gasPrice: Converter.toWei(GWei: 10), // 从服务器获取合理值
                                           gasLimit: 210000,    // 从服务器获取合理值
                                           nonce: 0,    // 从服务器获取合理值
                                           data: parameterData)
        
        // 第二步：签名
        do {
            let chainId = Network.private(chainID: 1, testUse: true) //chainID 由服务端接口返回
            tx = try w.sign(rawTransaction: rawTransacton, token: someToken, network: chainId)
        } catch let error {
            fatalError("Error:\(error.localizedDescription)")
        }
        print(tx)
        
        //第三步：把签名后的数据 tx 传给服务方API转发到区块链
        
        
        //19.收款
        // 一、实质是提供地址给别人，让别人往这个地址上发送交易，参见上面的 13和14获取地址
        // 二、当别人向你钱包中的某个帐号（币种所对应的地址）转帐成功后，服务端会向APP推送消息，
        //此时，APP响应消息做相应的处理
        
        //20.TODO:支持 比特币、EOS等其他币种
        
        #endif
        
        #if true
        let m = CLWalletManager.default
        
        //let(w,men) = try! m.createWallet(name: "MyWallet", password: "123456")
        //print(men)
        
        
        if m.hasWallet() {
            print("钱包数量：\(m.wallets.count)")
            print(m.wallets)
        }
        //let address = try! w.adress4HD(coin: .ethereum)
        //print(address)
        
        //let w = m.wallets[0] //获取要操作的钱包
 
        
        let mns = ["浅", "勾", "停", "饮", "窝", "树", "尾", "引", "抽", "号", "奶", "味"]
        
        let w = try! m.import(mnemonic:mns, password: "123456", name: "abc")
        //let address = try! w?.adress4HD(coin: .ethereum)
        let bgftToken = CLWalletConfig.supportTokens[2] //BGFT代币
        var address = try! w?.address4HD(token: bgftToken)
        //print(address!)
        
        //address = try! w.adress4HD(coin: .ethereum)
        
        print(address)
        
        
        let BGFTToken = ERC20(contractAddress: "0xd71c3ae0286286eac90dae97575d21c599ab0ffc", decimal: 18, symbol: "ASD")
        
       
        
        /*
        
        let parameterData : Data
        do {
            parameterData = try BGFTToken.generateDataParameter(toAddress: "0x99c075e934df0183323750e141d4588b085e8f37", amount: "10")
        } catch let error {
            fatalError("Error:\(error.localizedDescription)")
        }
        
        let rawTransacton = RawTransaction(wei: "0",
                                           to: BGFTToken.contractAddress,
                                           gasPrice: Converter.toWei(GWei: 10),
                                           gasLimit: 210000,
                                           nonce: 1,
                                           data: parameterData)
        
        
        
        let tx :String
        do {
            //let chainId = Network.private(chainID: 1, testUse: true)
            tx = try w.sign(rawTransaction: rawTransacton, token: bgftToken, network: .ropsten)
        } catch let error {
            fatalError("Error:\(error.localizedDescription)")
        }
        print(tx)
 */
    #endif
        #endif
        
        let wm = CLWalletManager.default
        let (w,m) = try! CLWalletManager.default.createWallet(name: "abc", password: "123", language: .chinese)
        
        print(wm.wallets.count)
        print(try! w.adress4HD(coin: .bitcoin))
        /*
        //let w = wm.wallets[0]
        //printLog(message: m)
        //print(try! w.adress4HD(coin: .ethereum))
        let words = ["滴","啊","滴","啊","滴","啊","滴","啊","滴","啊","滴","滴"]
        
        let w = try! wm.import(mnemonic: words, password: "ys591166", name: "abc")
        print(try! w!.adress4HD(coin: .ethereum))
        
        print(try! w!.exportPrivateKey(coin: .ethereum))
        */
        
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}

