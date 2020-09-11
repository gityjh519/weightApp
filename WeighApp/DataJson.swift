//
//  DataJson.swift
//  WeighApp
//
//  Created by yaojinhai on 2020/8/28.
//  Copyright © 2020 yaojinhai. All rights reserved.
//

import Foundation
import SwiftUI

class UserModel: ObservableObject {
    
    @Published var dataList = UserModel.readDataFromDisk() {
        didSet{
            saveData()
        }
    }
    
    var currentDate: String {
        let formater = DateFormatter()
        formater.dateFormat = "yyyy年MM月dd日 EEEE";
        formater.locale = Locale(identifier: "zh-Hans_US")
        formater.calendar = .init(identifier: .gregorian);
        return formater.string(from: Date())
    }
    
    func saveData() {
        let path = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0] + "/data";
        
        

        let file = FileManager.default;
        if !file.fileExists(atPath: path) {
            file.createFile(atPath: path, contents: nil, attributes: nil);
        }
        let json = JSONEncoder();
        let data = try? json.encode(dataList);
        try? data?.write(to: URL(fileURLWithPath: path))
        
    }
    
}


struct DataJson: Codable,Identifiable {
    let id: String
    let date: String
    let kg: String
    
    var kgValue: String {
        "体重：" + kg + "kg"
    }
    
    init(date: String,kg: String) {
        self.date = date;
        self.kg = kg;
        let dateFormater = DateFormatter();
        dateFormater.dateFormat = "yyyyMMddHHmmssSSS";
        dateFormater.calendar = .init(identifier: .gregorian)
        self.id = dateFormater.string(from: Date())
    }
}



extension UserModel {
    
    static func readDataFromDisk() -> [DataJson] {
        let path = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0] + "/data";
        print("path =\(path)")
        
        guard let data = try? Data(contentsOf: URL(fileURLWithPath: path)) else{
            return [DataJson]()
        }
        let json = JSONDecoder();
        let list = try? json.decode([DataJson].self, from: data);
        
        return list ?? [DataJson]()
    }
}
