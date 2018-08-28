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
        _ = w.coinList
        
        //10.添加币种
        w.addCoin(coin: .callisto)
        
        //11.移除币种
        w.removeCoin(coin: .callisto)
        
        //12.移除所有的币种
        w.removeAllCoins()
        
        //13. 获取HD钱包中指定币种的地址
        var addrress = try! w.adress4HD(coin: .ethereum)
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
        //第一步：创建交易数据
        let rt = RawTransaction.init(value: try! Converter.toWei(ether: "0.00001"),  //需要转出的金额，单位是 以太币，调用方法转换成Wei,
            to: "",//收币方地址
            gasPrice: Converter.toWei(GWei: 10),//该笔交易的价格，调用服务方的接口计算一个基准值，然后在界面上设置一个滑动条，最低值为服务方返回值，增加一个合理范围的值，供用户选择,
            gasLimit: 21000,//调用服务方接口,
            nonce: 0)//调用服务方接口提供
        
        //第二步：用发出方的私钥对交易数据进行签名
        let tx = try! w.sign(rawTransaction: rt, coin: .ethereum, network: CLWalletConfig.network)
        print(tx)//打印签名后的字符串数值
        
        //第三步：把签名后的数据 tx 传给服务方API转发到区块链
        
        //19.收款
        // 一、实质是提供地址给别人，让别人往这个地址上发送交易，参见上面的 13和14获取地址
        // 二、当别人向你钱包中的某个帐号（币种所对应的地址）转帐成功后，服务端会向APP推送消息，
        //此时，APP响应消息做相应的处理
        
        //20.TODO:支持 比特币、EOS等其他币种
        
        #endif
        
        let m = CLWalletManager.default
        
        //let(w,men) = try! m.createWallet(name: "MyWallet", password: "123456")
        //print(men)
        
        
        if m.hasWallet() {
            print("钱包数量：\(m.wallets.count)")
            print(m.wallets)
        }
        
        let w = m.wallets[0] //获取要操作的钱包
 
        let addrress = try! w.adress4HD(coin: .ethereum)
        print(addrress)
        
        let BGFTToken = ERC20(contractAddress: "0xd71c3ae0286286eac90dae97575d21c599ab0ffc", decimal: 18, symbol: "ASD")
        
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
                                           nonce: 0,
                                           data: parameterData)
        
        let tx :String
        do {
            let chainId = Network.private(chainID: 1, testUse: true)
            tx = try w.sign(rawTransaction: rawTransacton, coin: .ethereum, network: chainId)
        } catch let error {
            fatalError("Error:\(error.localizedDescription)")
        }
        print(tx)
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}

