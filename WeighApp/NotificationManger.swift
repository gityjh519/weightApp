//
//  NotificationManger.swift
//  WeighApp
//
//  Created by yaojinhai on 2020/8/28.
//  Copyright © 2020 yaojinhai. All rights reserved.
//

import UIKit
import UserNotifications

struct NotificationManger {
    
    
    static func addNotification()  {
        let content = UNMutableNotificationContent()
        content.badge = 1;
        content.title = "今天改称体重了哦"
        content.subtitle = ""
        if let first = UserModel.init().dataList.first {
            content.body = "上次称重时间：\(first.date)\n\(first.kgValue)";
        }else {
            content.body = "每次记录都会直接保存的哦";
        }
        content.sound = UNNotificationSound.default;
        
        var resultComponts = DateComponents();
        resultComponts.calendar = .init(identifier: .gregorian)
        resultComponts.hour = 20;
        resultComponts.minute = 0;
        resultComponts.second = 0;
        resultComponts.day = UserConfig.dayIndex;
//        resultComponts.w
        
        let trigger = UNCalendarNotificationTrigger(dateMatching: resultComponts, repeats: true);
        let request = UNNotificationRequest.init(identifier: "id", content: content, trigger: trigger)
        
        
        
        UNUserNotificationCenter.current().add(request) { (error) in
        }
        
        let open = UNNotificationAction(identifier: "open", title: "打开", options: .destructive);
        let catorgy = UNNotificationCategory(identifier: "openBack", actions: [open], intentIdentifiers: [], options: .customDismissAction);
        UNUserNotificationCenter.current().setNotificationCategories(Set([catorgy]))
        
    }
    static func removeNotifiation() {
        UNUserNotificationCenter.current().removeAllPendingNotificationRequests();
        UNUserNotificationCenter.current().removeAllDeliveredNotifications();
    }
    
    func createDate() {
        
    }
}

@propertyWrapper struct UserConfigDelegate<T: Codable> {
    
    var defultValue: T
    let key: String
    
    public var wrappedValue: T {
        get {
            defultValue
        }
        set {
            defultValue = newValue;
            UserDefaults.standard.setValue(newValue, forKey: key)
        }
    }
    
    init(key: String,value: T) {
        self.key = key
        if let tempValue = UserDefaults.standard.value(forKey: key) as? T {
            self.defultValue = tempValue;
        }else{
            self.defultValue = value;
        }
    }
}

struct UserConfig {
    @UserConfigDelegate(key: "notificaitonDayIndex", value: 1)
    static var dayIndex: Int
    
    @UserConfigDelegate(key: "isOpenNotificaition", value: true)
    static var isOpenNotifiy
    
    @UserConfigDelegate(key: "weightIndex", value: 10)
    static var weightIndex: Int
}
