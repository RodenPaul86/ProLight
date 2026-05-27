//
//  ActivityCard.swift
//  ProLight
//
//  Created by Paul  on 8/5/25.
//

import SwiftUI
import Charts

// MARK: - Model
struct cardElements: Identifiable, Equatable {
    let id: Int
    let title: String
    let subtitle: String
    let image: String
    let tintColor: Color
    let amount: String
    var weeklyData: [Double] = []
}

// MARK: - Activity Card
struct ActivityCard: View {
    @State var activity: cardElements

    // Pair each value with a day label
    private var chartData: [(day: String, label: String, value: Double)] {
        let days = ["M", "T", "W", "T", "F", "S", "S"]
        let ids  = ["1", "2", "3", "4", "5", "6", "7"]  // unique keys
        return activity.weeklyData.prefix(7).enumerated().map { i, v in
            (day: ids[i], label: days[i], value: v)
        }
    }

    var body: some View {
        ZStack {
            Color(uiColor: .systemGray6)
                .cornerRadius(15)

            VStack(alignment: .leading, spacing: 12) {
                // MARK: - Top: icon + title
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
                        .font(.headline)

                    Spacer()
                }

                // MARK: - Amount + subtitle
                VStack(alignment: .leading, spacing: 4) {
                    Text(activity.amount)
                        .font(.title2.bold())
                        .minimumScaleFactor(0.6)
                    
                    // MARK: - Bar chart
                    if !chartData.isEmpty {
                        Chart {
                            ForEach(chartData, id: \.day) { entry in
                                BarMark(
                                    x: .value("Day", entry.day),
                                    y: .value("Value", entry.value)
                                )
                                .foregroundStyle(activity.tintColor.gradient)
                                .cornerRadius(3)
                            }
                        }
                        .chartXAxis {
                            AxisMarks(values: ["1","2","3","4","5","6","7"]) { value in
                                AxisValueLabel {
                                    let labels = ["M","T","W","T","F","S","S"]
                                    let i = Int(value.as(String.self) ?? "1")! - 1
                                    Text(labels[i])
                                        .font(.system(size: 9))
                                }
                            }
                        }
                        .chartYAxis(.hidden)
                        .frame(height: 50)
                        .padding(.vertical)
                    }
                    
                    Text(activity.subtitle)
                        .font(.caption)
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

// MARK: - Drop Delegate
struct DropViewDelegate: DropDelegate {
    let item: cardElements
    @Binding var activities: [cardElements]
    @Binding var draggingItem: cardElements?
    var onReorder: () -> Void
    
    func performDrop(info: DropInfo) -> Bool {
        draggingItem = nil
        onReorder()
        return true
    }
    
    func dropEntered(info: DropInfo) {
        guard let draggingItem = draggingItem,
              draggingItem != item,
              let fromIndex = activities.firstIndex(of: draggingItem),
              let toIndex = activities.firstIndex(of: item) else { return }
        
        withAnimation {
            activities.move(fromOffsets: IndexSet(integer: fromIndex),
                            toOffset: toIndex > fromIndex ? toIndex + 1 : toIndex)
        }
    }
}
