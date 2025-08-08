//
//  ActivityCard.swift
//  ProLight
//
//  Created by Paul  on 8/5/25.
//

import SwiftUI

struct cardElements {
    let id: Int
    let title: String
    let subtitle: String
    let image: String
    let tintColor: Color
    let amount: String
}

struct ActivityCard: View {
    @State var activity: cardElements
    
    var body: some View {
        ZStack {
            Color(uiColor: .systemGray6)
                .cornerRadius(15)
            
            VStack(alignment: .leading, spacing: 20) {
                HStack {
                    Image(systemName: activity.image)
                        .font(.system(size: 20))
                        .foregroundStyle(activity.tintColor.gradient)
                        .frame(width: 40, height: 40)
                        .background(
                            RoundedRectangle(cornerRadius: 12, style: .continuous)
                                .fill(Color("darkGray"))
                        )
                    
                    Text(activity.title)
                        .font(.system(size: 20))
                    
                    Spacer()
                }
                
                VStack(alignment: .leading, spacing: 5) {
                    Text(activity.amount)
                        .font(.system(size: 25).bold())
                        .minimumScaleFactor(0.6)
                    
                    Text(activity.subtitle)
                        .font(.system(size: 12))
                        .foregroundStyle(.gray)
                }
            }
            .padding()
        }
    }
}

#Preview {
    UserActivityView()
        .environmentObject(HealthManager())
    
    //ActivityCard(activity: cardElements(id: 0, title: "Daily Steps", subtitle: "Goal: 10,000", image: "figure.walk", tintColor: .green, amount: "6,234"))
}
