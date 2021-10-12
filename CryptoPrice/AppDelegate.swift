//
//  AppDelegate.swift
//  CryptoPrice
//
//  Created by 许林 on 2021/09/06.
//

import Cocoa
import SwiftUI

@main
class AppDelegate: NSObject, NSApplicationDelegate {
    let statusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.variableLength)
    var oldPrice: Float = 0.0
    var timer: Timer = Timer()
    let coins: [String] = ["BTCBUSD", "ETHBUSD", "BNBBUSD"]
    let coinNames: [String] = ["BTC", "ETH", "BNB"]
    let coinPrecisions: [Int] = [2, 2, 1]
    var pos: Int = 0

    func applicationDidFinishLaunching(_ aNotification: Notification) {
        if let button = statusItem.button {
            button.title = ""
            button.action = #selector(self.statusBarButtonClicked)
            button.sendAction(on: [.leftMouseDown, .rightMouseDown])
        }
        
        self.timer = Timer.scheduledTimer(timeInterval: 2, target: self, selector: #selector(self.update), userInfo: nil, repeats: true)
        self.timer.fire()
    }

    func applicationWillTerminate(_ aNotification: Notification) {
        // Insert code here to tear down your application
    }
    
    @objc func update() {
        let url = URL(string: String(format: "https://api.binance.com/api/v3/ticker/price?symbol=%@", coins[pos]))!

        let task = URLSession.shared.dataTask(with: url) {(data, response, error) in
            guard let data = data else { return }
            var priceData = [String: String]()
            
            do {
                priceData = try JSONSerialization.jsonObject(with: data, options: .allowFragments) as! [String: String]
                
                DispatchQueue.main.async {
                    if let button = self.statusItem.button {
                        let newPrice: Float = Float(priceData["price"]!)!
                        let formatString: String = String(format: "%%.%df", self.coinPrecisions[self.pos])
                        let myString: String = self.coinNames[self.pos] + " " + String(format: formatString, newPrice)
                        if newPrice > self.oldPrice {
                            let myAttributes: [NSAttributedString.Key: Any] = [
                                .font: NSFont(name: "HelveticaNeue", size: 14),
                                .foregroundColor: NSColor(red: 30.0/255.0, green: 196.0/255.0, blue: 110.0/255.0, alpha: 1.0)
                            ]
                            let myAttrString = NSAttributedString(string: myString, attributes: myAttributes)
                            button.attributedTitle = myAttrString
                        } else if newPrice < self.oldPrice {
                            let myAttributes: [NSAttributedString.Key: Any] = [
                                .font: NSFont(name: "HelveticaNeue", size: 14),
                                .foregroundColor: NSColor(red: 241.0/255.0, green: 44.0/255.0, blue: 75.0/255.0, alpha: 1.0)
                            ]
                            let myAttrString = NSAttributedString(string: myString, attributes: myAttributes)
                            button.attributedTitle = myAttrString
                        }
                        
                        self.oldPrice = newPrice
                    }
                }
            } catch let error as NSError {
                print(error)
            }
        }

        task.resume()
    }
    
    @objc func statusBarButtonClicked(sender: NSStatusBarButton) {
        let event = NSApp.currentEvent!
        
        if event.clickCount == 1 {
            if event.type == NSEvent.EventType.leftMouseDown {
                self.pos = (self.pos + 1) % self.coins.count
                self.timer.fire()
            } else if event.type == NSEvent.EventType.rightMouseDown {
                if let url = URL(string: String(format: "https://cn.tradingview.com/chart?symbol=BINANCE:%@", coins[self.pos])) {
                    NSWorkspace.shared.open(url)
                }
            }
        } else if event.clickCount == 2 {
            NSApp.terminate(self)
        }
    }
}

