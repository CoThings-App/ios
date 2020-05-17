//
//  RoomRow.swift
//  CoThings
//
//  Created by Umur Gedik on 2020/05/04.
//  Copyright © 2020 Umur Gedik. All rights reserved.
//

import SwiftUI
import DateHelper

struct RoomRow: View {
    @Environment(\.colorScheme) var colorScheme
    
    let room: Room
    
    static let titleFont = Font.system(size: 16).bold()
    static let occupiedFont = Font.custom("SF Pro Text", size: 14)
    static let timeFont = Font.custom("SF Pro Text", size: 12)
    
    var occupation: String {
        room.population == 0 ? "Empty" : "Occupied: \(room.population) of \(room.capacity)"
    }
    
    var body: some View {
        HStack {
            VStack(alignment: .leading) {
                Text(room.name.uppercased())
                    .font(RoomRow.titleFont)
                    .foregroundColor(Color.primary)
                
                Text(occupation)
                    .font(RoomRow.occupiedFont)
                    .foregroundColor(Color.secondary)
                
                Text("Updated \(room.lastUpdated.toStringWithRelativeTime())")
                    .font(RoomRow.timeFont)
                    .foregroundColor(Color(UIColor.tertiaryLabel))
                    .padding(EdgeInsets(top: 5, leading: 0, bottom: 0, trailing: 0))
            }
            
            Spacer()
            
            HStack {
                if room.population > 0 {
                    Button(action: {}) {
                        Image("minusIcon")
                            .resizable()
                            .scaledToFill()
                    }
                    .buttonStyle(CircularButton(colorScheme: colorScheme))
                }
                
                RoomFullnessView(percentage: Float(room.population) / Float(room.capacity))
                
                Button(action: {}) {
                    Image("plusIcon")
                    .resizable()
                    .scaledToFill()
                }
                .buttonStyle(CircularButton(colorScheme: colorScheme))
            }
        }
        .fixedSize(horizontal: false, vertical: true)
    }
}

struct CircularButton: ButtonStyle {
    var colorScheme: ColorScheme
    
    var borderColor: Color {
        colorScheme == .light ? Color(hex: "E6E6E6") : Color.black
    }
    
    var topColor: Color {
        colorScheme == .light ? Color(hex: "F7F7F7") : Color(hex: "333333")
    }
    
    var bottomColor: Color {
        colorScheme == .light ? Color(hex: "F0F0F0") : Color(hex: "222222")
    }
    
    func makeBody(configuration: ButtonStyleConfiguration) -> some View {
        return ZStack {
            Circle()
                .fill(LinearGradient(gradient: Gradient(colors: [topColor, bottomColor]),
                                     startPoint: .top,
                                     endPoint: .bottom))
            
            Circle()
                .stroke(borderColor, lineWidth: 1)
        }
        .frame(width: 35, height: 35)
        .overlay(configuration.label)
            
    }
}

struct RoomRow_Previews: PreviewProvider {
    static let lastUpdated = Date().adjust(.minute, offset: -5)
    static let sampleRoom = Room(id: 4,
                                   name: "Kitchen",
                                   group: "Common Area",
                                   population: 3,
                                   capacity: 4,
                                   lastUpdated: lastUpdated)
    
    static var previews: some View {
        var emptyRoom = sampleRoom
        emptyRoom.population = 0
        
        return Group {
            RoomRow(room: sampleRoom)
                .padding()
                .previewLayout(.sizeThatFits)
            
            RoomRow(room: emptyRoom)
                .padding()
                .previewLayout(.sizeThatFits)
            
            RoomRow(room: sampleRoom)
                .padding()
                .background(Color(hex: "111111"))
                .previewLayout(.sizeThatFits)
                .colorScheme(.dark)
        }
    }
}
