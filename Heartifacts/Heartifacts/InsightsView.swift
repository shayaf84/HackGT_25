//
//  InsightsView.swift
//  Heartifacts
//
//  Created by Shaya Farahmand on 9/27/25.
//

import SwiftUI

struct InsightsView: View {
    @State private var weeklyProgress: Double = 0.75
    @State private var monthlyGoal: Int = 85
    @State private var currentProgress: Int = 64
    
    var body: some View {
        VStack(spacing: 30) {
            Text("Insights")
                .font(.largeTitle)
                .fontWeight(.bold)
                .foregroundColor(.white)
                .padding(.top, 20)
            
            // Progress Ring
            VStack {
                ZStack {
                    Circle()
                        .stroke(Color.gray.opacity(0.3), lineWidth: 20)
                        .frame(width: 150, height: 150)
                    
                    Circle()
                        .trim(from: 0, to: weeklyProgress)
                        .stroke(
                            LinearGradient(
                                gradient: Gradient(colors: [.blue, .purple]),
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            ),
                            style: StrokeStyle(lineWidth: 20, lineCap: .round)
                        )
                        .frame(width: 150, height: 150)
                        .rotationEffect(.degrees(-90))
                    
                    VStack {
                        Text("\(Int(weeklyProgress * 100))%")
                            .font(.title)
                            .fontWeight(.bold)
                            .foregroundColor(.white)
                        Text("Weekly")
                            .font(.caption)
                            .foregroundColor(.white.opacity(0.8))
                    }
                }
            }
            
            // Stats Cards
            VStack(spacing: 15) {
                StatCard(title: "Monthly Goal", value: "\(monthlyGoal)%", color: .green)
                StatCard(title: "Current Progress", value: "\(currentProgress)%", color: .blue)
                StatCard(title: "Days Active", value: "23", color: .orange)
            }
            
            Spacer()
        }
        .padding()
        .background(
            Image("sky")
                .resizable()
                .scaledToFill()
                .ignoresSafeArea()
        )
    }
}

struct StatCard: View {
    let title: String
    let value: String
    let color: Color
    
    var body: some View {
        HStack {
            VStack(alignment: .leading) {
                Text(title)
                    .font(.headline)
                    .foregroundColor(.white)
                Text(value)
                    .font(.title)
                    .fontWeight(.bold)
                    .foregroundColor(color)
            }
            Spacer()
        }
        .padding()
        .background(Color.black.opacity(0.4))
        .cornerRadius(15)
    }
}
