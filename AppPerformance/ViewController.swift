//
//  ViewController.swift
//  AppPerformance
//
//  Created by lisilong on 2018/8/7.
//  Copyright © 2018 lisilong. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
    var timer: DispatchSourceTimer?  // GIF播放定时器
    let infoLabel: UILabel = {      // 展示cpu、内存信息
        let label = UILabel.init(frame: CGRect.init(x: 0, y: 0, width: UIScreen.main.bounds.size.width - 100, height: 30))
        label.textColor = UIColor.white
        label.textAlignment = .center
        label.font = UIFont.init(name: "Menlo", size: 12.0)
        label.backgroundColor = UIColor.black
        return label
    }()
    
    let window: UIWindow = {
        let window = UIWindow.init(frame: CGRect.init(x: 0, y: 64, width: UIScreen.main.bounds.size.width, height: 30))
        window.rootViewController = UIViewController()
        window.backgroundColor = UIColor.black
        window.makeKeyAndVisible()
        window.windowLevel = UIWindowLevelAlert
        return window
    }()
    
    var showFPSBtn: UIButton = {
        let btn = UIButton.init(frame: CGRect.init(x: 80, y: 200, width: 100, height: 30))
        btn.addTarget(self, action: #selector(showFPSVC), for: UIControlEvents.touchUpInside)
        btn.layer.borderWidth = 1
        btn.layer.borderColor = UIColor.lightGray.cgColor
        btn.setTitle("卡顿", for: UIControlState.normal)
        btn.setTitleColor(UIColor.black, for: UIControlState.normal)
        return btn
    }()
    

    override func viewDidLoad() {
        super.viewDidLoad()
        
        window.center.x = self.view.center.x
        // CPU、内存
        window.rootViewController?.view.addSubview(infoLabel)
        // FPS
//        let fpsView = LSLFPSMonitor.init(frame: CGRect.init(x: UIScreen.main.bounds.size.width - 100, y: 0, width: 100, height: 30))
//        window.rootViewController?.view.addSubview(fpsView)
        
        view.addSubview(showFPSBtn)

        //showUsageInfo()
        registerObserver()
    }
    
    private func registerObserver() {
        let observer = CFRunLoopObserverCreateWithHandler(kCFAllocatorDefault, CFRunLoopActivity.beforeWaiting.rawValue | CFRunLoopActivity.beforeSources.rawValue | CFRunLoopActivity.afterWaiting.rawValue, true, 0) { (_, activity) in
            switch activity {
            case .entry:
                NSLog("即将进入RunLoop")
            case .beforeTimers:
                NSLog("即将处理timer")
            case .beforeSources:
                NSLog("即将处理source")
            case .beforeWaiting:
                NSLog("即将进入休眠")
            case .afterWaiting:
                NSLog("从休眠中被唤醒")
            case .exit:
                NSLog("即将退出RunLoop")
            default:
                break
            }
        }
        CFRunLoopAddObserver(CFRunLoopGetMain(), observer, CFRunLoopMode.commonModes)
    }
    
    // MARK: - actions
    
    func showUsageInfo() {
        timer = DispatchSource.makeTimerSource(flags: [], queue: DispatchQueue.global())
        timer?.schedule(deadline: .now(), repeating: 1)
        timer?.setEventHandler(handler: { [weak self] in
            DispatchQueue.main.async {
                let cpu = String.init(format: "%.2f", LSLCpuUsage.getCpuUsage())
                let memory = String.init(format: "%.2f", LSLApplicationMemory.getUsage())
                self?.infoLabel.text = "CPU: \(cpu)%  Memory: \(memory) MB"
            }
        })
        timer?.resume()
    }
    
    @objc func showFPSVC() {
        let fpsVC = LSLFPSTableViewController.init(style: .plain)
        self.navigationController?.pushViewController(fpsVC, animated: true)
    }
}

