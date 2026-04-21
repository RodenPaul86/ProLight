//
//  WidgetSetupView.swift
//  ProLight
//
//  Created by Paul  on 7/26/25.
//

import SwiftUI

struct WidgetSetupView: View {
    @State private var hideTabBar: Bool = false
    
    var body: some View {
        ScrollView(.vertical, showsIndicators: false) {
            VStack(spacing: 20) {
                
                // MARK: Icon
                Image(systemName: "widget.small")
                    .font(.system(size: 48))
                    .foregroundStyle(Color("darkGreen").gradient)
                    .padding(.bottom, 4)
                
                // MARK: Title and Description
                Text("Add Widgets to Home Screen")
                    .font(.title2)
                    .fontWeight(.semibold)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal)
                
                Text("Follow these simple steps to add \(Bundle.main.appName) widgets to your home screen")
                    .font(.body)
                    .foregroundColor(.gray)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal)
                
                // MARK: Steps
                VStack(alignment: .leading, spacing: 20) {
                    StepView(number: 1,
                             icon: "hand.tap",
                             title: "Long Press Home Screen",
                             description: "Long press on any empty space on your home screen until you enter \"jiggle mode\".")
                    
                    StepView(number: 2,
                             icon: "plus",
                             title: "Tap the Plus or Edit Button",
                             description: "Look for the \"+\" or \"Edit\" button in the top-left corner and tap it")
                    
                    StepView(number: 3,
                             icon: "widget.small.badge.plus",
                             title: "Tap the Add Widget Button",
                             description: "Look for the \"Add Widget\" button top of the menu and tap it")
                    
                    StepView(number: 4,
                             icon: "magnifyingglass",
                             title: "Find \(Bundle.main.appName)",
                             description: "Search for \"\(Bundle.main.appName)\" or scroll down to find our app")
                    
                    StepView(number: 5,
                             icon: "checkmark",
                             title: "Add Widget",
                             description: "Tap \"Add Widget\" to place it on your home screen. You can move it anywhere you like!")
                }
                .padding()
                
                Spacer()
                
                // MARK: Widget Preview
                VStack(alignment: .leading, spacing: 16) {
                    Text("Preview")
                        .font(.headline)
                        .padding(.horizontal)
                    
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 16) {
                            SmallWidgetPreview()
                            MediumWidgetPreview()
                            LargeWidgetPreview()
                        }
                        .padding(.horizontal)
                    }
                }
            }
            .onAppear {
                hideTabBar = true
            }
            .padding()
            .hideFloatingTabBar(hideTabBar)
        }
    }
}

struct StepView: View {
    let number: Int
    let icon: String
    let title: String
    let description: String
    
    var body: some View {
        HStack(alignment: .top, spacing: 12) {
            Text("\(number)")
                .font(.headline)
                .frame(width: 24, height: 24)
                .background(Circle().fill(Color("darkGreen").gradient))
                .foregroundColor(.white)
            
            VStack(alignment: .leading, spacing: 4) {
                HStack {
                    Image(systemName: icon)
                        .foregroundColor(.white)
                    Text(title)
                        .font(.headline)
                }
                
                Text(description)
                    .font(.subheadline)
                    .foregroundColor(.gray)
            }
        }
    }
}

//
// MARK: - Widget Previews
//

struct SmallWidgetPreview: View {
    var body: some View {
        VStack(alignment: .leading) {
            
            // MARK: Time
            Text("12:00")
                .font(.system(size: 46, design: .rounded))
                .bold()
                .foregroundColor(.green)
                .shadow(
                    color: Color(
                        UIColor(
                            displayP3Red: 96/255,
                            green: 252/255,
                            blue: 255/255,
                            alpha: 1
                        )
                    ),
                    radius: 1,
                    x: 1,
                    y: 1
                )
                .padding(.bottom, -10)
            
            Spacer()
            
            // MARK: Day
            Text("Monday")
                .font(.system(size: 20))
                .bold()
                .foregroundColor(.white)
            
            // MARK: Date
            Text("Jun 8, 2026")
                .font(.caption)
                .bold()
                .foregroundColor(.gray)
            
        }
        .padding()
        .frame(width: 170, height: 170, alignment: .leading)
        .background(.black)
        .clipShape(RoundedRectangle(cornerRadius: 28, style: .continuous))
        //.shadow(color: .black.opacity(0.25), radius: 10, y: 5)
        .overlay(
            RoundedRectangle(cornerRadius: 22)
                .stroke(Color.theme.accent, lineWidth: 1)
        )
    }
}

struct MediumWidgetPreview: View {
    var body: some View {
        ZStack {
            
            // MARK: Time (Right Side)
            VStack(alignment: .trailing, spacing: 0) {
                Text("12:00")
                    .font(.system(size: 110, design: .rounded))
                    .bold()
                    .foregroundColor(.green)
                    .shadow(
                        color: Color(
                            UIColor(
                                displayP3Red: 96/255,
                                green: 252/255,
                                blue: 255/255,
                                alpha: 1
                            )
                        ),
                        radius: 1,
                        x: 1,
                        y: 1
                    )
            }
            .padding(.trailing, 10)
            .frame(maxWidth: .infinity, alignment: .trailing)
            
            // MARK: Day + Date (Bottom Left)
            VStack(alignment: .leading) {
                Spacer()
                
                Text("Monday")
                    .font(.largeTitle)
                    .bold()
                    .foregroundColor(.white)
                
                Text("Jun 8, 2026")
                    .font(.subheadline)
                    .bold()
                    .foregroundColor(.gray)
            }
            .padding()
            .frame(maxWidth: .infinity, alignment: .leading)
        }
        .frame(width: 320, height: 170)
        .background(.black)
        .clipShape(RoundedRectangle(cornerRadius: 28, style: .continuous))
        //.shadow(color: .black.opacity(0.25), radius: 10, y: 5)
        .overlay(
            RoundedRectangle(cornerRadius: 22)
                .stroke(Color.theme.accent, lineWidth: 1)
        )
    }
}

struct LargeWidgetPreview: View {
    var body: some View {
        ZStack {
            
            // MARK: Time (Right Side - Stacked)
            VStack(alignment: .trailing, spacing: 0) {
                
                Text("12")
                    .font(.system(size: 140, design: .rounded))
                    .bold()
                    .foregroundColor(.green)
                    .shadow(
                        color: Color(
                            UIColor(
                                displayP3Red: 96/255,
                                green: 252/255,
                                blue: 255/255,
                                alpha: 1
                            )
                        ),
                        radius: 1,
                        x: 1,
                        y: 1
                    )
                    .padding(.bottom, -15)
                
                Text("00")
                    .font(.system(size: 140, design: .rounded))
                    .bold()
                    .foregroundColor(.green)
                    .shadow(
                        color: Color(
                            UIColor(
                                displayP3Red: 96/255,
                                green: 252/255,
                                blue: 255/255,
                                alpha: 1
                            )
                        ),
                        radius: 1,
                        x: 1,
                        y: 1
                    )
                    .padding(.top, -15)
            }
            .padding(.trailing, 10)
            .frame(maxWidth: .infinity, alignment: .trailing)
            
            // MARK: Day + Date (Bottom Left)
            VStack(alignment: .leading) {
                Spacer()
                
                Text("Monday")
                    .font(.system(size: 45))
                    .bold()
                    .foregroundColor(.white)
                
                Text("Jun 8, 2026")
                    .font(.subheadline)
                    .bold()
                    .foregroundColor(.gray)
            }
            .padding()
            .frame(maxWidth: .infinity, alignment: .leading)
        }
        .frame(width: 320, height: 320)
        .background(.black)
        .clipShape(RoundedRectangle(cornerRadius: 28, style: .continuous))
        //.shadow(color: .black.opacity(0.25), radius: 10, y: 5)
        .overlay(
            RoundedRectangle(cornerRadius: 22)
                .stroke(Color.theme.accent, lineWidth: 1)
        )
    }
}

#Preview {
    WidgetSetupView()
}
