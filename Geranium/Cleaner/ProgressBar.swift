//
//  ProgressBar.swift
//  Geranium
//
//  Created by cclerc on 15.12.23.
//

import SwiftUI

struct ProgressBar: View {
    var value: CGFloat
    
    var body: some View {
        Spacer()
        Spacer()
        VStack {
            GeometryReader { geometry in
                VStack() {
                    Text("Deleting... \(self.getPercentage(self.value))")
                        .padding()
                    ZStack(alignment: .leading) {
                        Rectangle()
                            .opacity(0.1)
                            .cornerRadius(25)
                        Rectangle()
                            .frame(minWidth: 0, idealWidth:self.getProgressBarWidth(geometry: geometry),
                                   maxWidth: self.getProgressBarWidth(geometry: geometry))
                            .opacity(0)
                            .background(Color.accentColor)
                            .animation(.default)
                            .cornerRadius(25)
                    }
                    .frame(height: 10)
                }.frame(height: 10)
            }
        }
        Spacer()
    }
    
    func getProgressBarWidth(geometry: GeometryProxy) -> CGFloat {
        let frame = geometry.frame(in: .global)
        if value == 0.9 {
            return frame.size.width * 1
        }
        else {
            return frame.size.width * value
        }
    }
    
    func getPercentage(_ value: CGFloat) -> String {
        let intValue = Int(ceil(value * 100))
        // in case roothelper fucks up!
        if intValue == -9900 {
            return "99 %"
        }
        // it's done
        if intValue == 90 {
            return "100 %"
        }
        else {
            return "\(intValue) %"
        }
    }
}

// Source : https://sarunw.com/posts/swiftui-checkbox/#swiftui-checkbox-on-ios
struct checkboxiOS: ToggleStyle {
    func makeBody(configuration: Configuration) -> some View {
        Button(action: {
            configuration.isOn.toggle()
        }, label: {
            HStack {
                Image(systemName: configuration.isOn ? "checkmark.square" : "square")
                configuration.label
            }
        })
    }
}
