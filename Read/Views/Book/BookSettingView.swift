//
//  BookSettingView.swift
//  Read
//
//  Created by wanruuu on 13/8/2024.
//

import SwiftUI


struct BookSettingView: View {
    @State private var fontSize: CGFloat
    
    init() {
        let fontSize = UserDefaults.standard.float(forKey: "fontSize")
        self.fontSize = fontSize == 0 ? 21 : CGFloat(fontSize)
    }
    
    var body: some View {
        Form {
            Section("阅读") {
                HStack{
                    Label("字号: ", systemImage: "textformat.size")
                    Stepper("\(Int(fontSize))", value: $fontSize, step: 1)
                }
                
            }
        }
        .onChange(of: fontSize) { _, newValue in
            UserDefaults.standard.set(newValue, forKey: "fontSize")
        }
    }
}
