//
//  SettingRow.swift
//  readable page
//
//  Created by Najd Alsabi on 09/06/1447 AH.
//

import SwiftUI

struct SettingRow: View {
    let title: String
    @Binding var value: CGFloat
    let step: CGFloat
    let range: ClosedRange<CGFloat>
    
    var body: some View {
        HStack {
            Text(title)
                .font(.system(size: 18, weight: .semibold))
                .foregroundColor(Color.dbroun)
            
            Spacer()
            
            HStack(spacing: 12) {
                Button {
                    if value > range.lowerBound { value -= step }
                } label: {
                    Text("-")
                        .font(.title2)
                        .foregroundColor(.black)
                        .frame(width: 45, height: 35)
                        .background(Color.white)
                        .cornerRadius(10)
                }
                
                Button {
                    if value < range.upperBound { value += step }
                } label: {
                    Text("+")
                        .font(.title2)
                        .foregroundColor(.black)
                        .frame(width: 45, height: 35)
                        .background(Color.white)
                        .cornerRadius(10)
                }
            }
        }
    }
}
