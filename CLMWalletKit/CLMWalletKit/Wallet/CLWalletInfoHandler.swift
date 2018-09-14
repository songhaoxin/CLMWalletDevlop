//
//  CLWalletInfoHandler.swift
//  CLMWalletKit
//
//  Created by admin on 2018/9/7.
//  Copyright © 2018年 admin. All rights reserved.
//

import UIKit

class CLWalletInfoHandler: NSObject {
    let timer = DispatchSource.makeTimerSource(flags: [], queue: DispatchQueue.global())
    
    public func sendWalletInfo2NetIfUnsended() {
 
        DispatchTimer(timeInterval: 10 * 60) { _ in
            
        }
        
    }

    // GCD定时器循环操作
    ///   - timeInterval: 循环间隔时间
    ///   - handler: 循环事件
    public func DispatchTimer(timeInterval: Double, handler:@escaping (DispatchSourceTimer?)->())
    {
        let timer = DispatchSource.makeTimerSource(flags: [], queue: DispatchQueue.global())
        timer.schedule(deadline: .now(), repeating: timeInterval)
        timer.setEventHandler {
            DispatchQueue.global().async {
                handler(timer)
            }
        }
        timer.resume()
    }
}
