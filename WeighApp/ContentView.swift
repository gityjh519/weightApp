//
//  ContentView.swift
//  WeighApp
//
//  Created by yaojinhai on 2020/8/28.
//  Copyright © 2020 yaojinhai. All rights reserved.
//

import SwiftUI
import Combine

struct ContentView: View {
    
    @ObservedObject var model = UserModel()
    @State var showSeting = false
    @State var writeDown = false
    
    @State var isAlert = false
    
    @State var currentSet = IndexSet.init()
    
    @State var currentJson: DataJson?
    
    var body: some View {
        NavigationView {
            List {
                ForEach(model.dataList) { (item: DataJson)  in
                    Button(action: { 
                        self.currentJson = item;
                        self.writeDown.toggle()
                    }) { 
                        DataItemView(json: item)
                        
                    }
                }.onDelete { (set) in
                    self.currentSet = set
                    if self.getCurrentJson() != nil {
                        self.isAlert.toggle()
                    }
                }.alert(isPresented: self.$isAlert) { () -> Alert in
                    let item = getCurrentJson()!
                   return Alert(title: Text("提示"), message: Text("是否删除【\(item.date)】记录"), primaryButton: .cancel(), secondaryButton: .default(Text("确定"), action: { 
                        self.model.dataList.removeAll { (remveItem) -> Bool in
                            remveItem.id == item.id
                        }
                    }))
                }
                
                
            }.navigationBarTitle(Text("体重记录"), displayMode: .inline).navigationBarItems(leading: Button(action: { 
                self.showSeting.toggle()
            }, label: {
                Text("设置")
            }), trailing: Button(action: { 
                self.writeDown.toggle()
            }, label: { 
                Text("记录")
            })).sheet(isPresented: $showSeting) { 
                SettingView { 
                    self.showSeting.toggle()
                }
            }
        }.sheet(isPresented: $writeDown) {
            DatePickerView { 
                (value: String) in
                self.writeDown.toggle()
                self.addDateItemToList(value: value);
                
            }
        }
    }
    
    func getCurrentJson() -> DataJson? {
        if let index = currentSet.first {
            return model.dataList[index]
        }
        return nil;
        
    }
    
}



extension ContentView {
    func addDateItemToList(value: String)  {
        if currentJson != nil {
            alterSelectedItem(value: value);
            return;
        }
        
        let first = model.dataList.first;
        let nextModel = DataJson(date: model.currentDate, kg: value);
     
        if first?.date != model.currentDate {
            model.dataList.insert(nextModel, at: 0);
        }else {
            model.dataList[0] = nextModel;
        }
    }
    
    func alterSelectedItem(value: String) -> Void {
        let index = model.dataList.firstIndex { (item) -> Bool in
            item.id == currentJson?.id
        }
        model.dataList[index!] = .init(date: currentJson!.date, kg: value);
        currentJson = nil;
    }
}

struct DataItemView:View {
    let json: DataJson
    
    var body: some View {
        VStack(alignment: .leading) {
            Text(json.date).foregroundColor(Color.init(red: 35.0/255.0, green: 160.0/255.0, blue: 96.0/255.0)).font(Font.system(size: 18, weight: .bold, design: .serif)).padding([.top], 10)
            Text(json.kgValue).padding([.bottom,.top], 10).font(Font.system(size: 17))
            
        }
    }
}

//struct ContentView_Previews: PreviewProvider {
//    static var previews: some View {
//        ContentView()
//    }
//}

// MARK: - 记录体重 视图

struct DatePickerView: View {
    
    @State var intIndex = UserConfig.weightIndex
    @State var decimalIndex = 3
    
    @State var finishedBlock: ((_ value: String)->Void)?
    
    
    var body: some View {
        NavigationView {
            VStack(alignment: .center) {
                Text("当前体重：\(intIndex).\(decimalIndex)kg").padding().font(Font.system(size: 20)).foregroundColor(Color.rgbColor(r: 255, g: 147, b: 89))
                pickerItemsView
                Spacer()
                
            }.navigationBarTitle(Text("选择体重"), displayMode: .inline)
                .navigationBarItems(trailing: Button(action: { 
                    UserConfig.weightIndex = self.intIndex
                    self.finishedBlock?(self.intIndex.description + "." + self.decimalIndex.description)
                }, label: { 
                    Text("确定")
                }))
        }
    }
    

    
    var pickerItemsView: some View {
        
        GeometryReader { (geo: GeometryProxy) in
            HStack(alignment: .center, spacing: 0.0) {
                Picker("kg", selection: self.$intIndex) {
                    ForEach(0..<80) { (idx: Int) in
                        Text(idx.description).font(Font.system(size: 20))
                    }
                    }.pickerStyle(WheelPickerStyle()).frame(width: geo.size.width/2, height: geo.size.height/2 , alignment: .center).clipped().padding(0)
                
                Picker("", selection: self.$decimalIndex) {
                    ForEach(0..<10) { (idx: Int) in
                        Text(idx.description).font(Font.system(size: 20))
                    }
                    }.pickerStyle(WheelPickerStyle()).frame(width: geo.size.width/2, height: geo.size.height/2, alignment: .center).clipped()
                Spacer()
            }.offset(x: 4, y: -90)
        }
    }
}


struct SettingView: View {
    
    @State var isOpen = UserConfig.isOpenNotifiy
    @State var date = Date()
    @State var dayIndex = UserConfig.dayIndex - 1
    @State var finishedBlock: (() -> Void)?
    
    var body: some View {
        NavigationView {
            List {
                Toggle(isOn: $isOpen) { 
                    Text("打开通知")
                }
                if isOpen {
                    dateOfDay
                    datePicker
                    
                }
                
            }.navigationBarTitle(Text("通知设置"), displayMode: .inline).navigationBarItems(trailing: Button(action: { 
                self.finishedBlock?()
            }, label: { 
                Text("确定")
            }))
        }.onDisappear { 
            UserConfig.isOpenNotifiy = self.isOpen
            if self.isOpen {
                UserConfig.dayIndex = self.dayIndex + 1;
                NotificationManger.addNotification()
            }else {
                NotificationManger.removeNotifiation()
            }
        }
    }
    
    var dateOfDay: some View {
        HStack {
            Text("重复提醒")
            Spacer()
            Text("每月\(dayIndex + 1)日20:00")
        }
    }
    
    var datePicker: some View {
        HStack {
            Picker("picker", selection: $dayIndex) {
                ForEach(1..<30) { (index: Int) in
                    Text(index.description)
                }
            }.labelsHidden()
        }
    }
}


extension Color {
    static func rgbColor(rgb: Double) -> Color {
        rgbColor(r: rgb, g: rgb, b: rgb)
    }
    static func rgbColor(r: Double,g: Double,b: Double) -> Color {
        Color(red: r / 255.0, green: g / 255.0, blue: b / 255.0)
    }
    
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
