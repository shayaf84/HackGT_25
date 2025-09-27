//
//  ProfileView.swift
//  Heartifacts
//
//  Created by Shaya Farahmand on 9/27/25.
//

import SwiftUI

struct ProfileView: View {
    @State private var userName = "Museum Curator"
    @State private var userLevel = 12
    @State private var totalArtifacts = 47
    @State private var achievements = [
        Achievement(title: "First Discovery", description: "Found your first artifact", isUnlocked: true),
        Achievement(title: "Explorer", description: "Visited 10 different exhibits", isUnlocked: true),
        Achievement(title: "Scholar", description: "Completed 50 research tasks", isUnlocked: false),
        Achievement(title: "Master Curator", description: "Managed 100 artifacts", isUnlocked: false)
    ]
    
    var body: some View {
        VStack(spacing: 20) {
            // Profile Header
            VStack {
                Image(systemName: "person.crop.circle.fill")
                    .font(.system(size: 80))
                    .foregroundColor(.blue)
                
                Text(userName)
                    .font(.title)
                    .fontWeight(.bold)
                    .foregroundColor(.white)
                
                Text("Level \(userLevel)")
                    .font(.headline)
                    .foregroundColor(.blue)
            }
            .padding(.top, 20)
            
            // Stats
            HStack(spacing: 30) {
                VStack {
                    Text("\(totalArtifacts)")
                        .font(.title)
                        .fontWeight(.bold)
                        .foregroundColor(.orange)
                    Text("Artifacts")
                        .font(.caption)
                        .foregroundColor(.white)
                }
                
                VStack {
                    Text("23")
                        .font(.title)
                        .fontWeight(.bold)
                        .foregroundColor(.green)
                    Text("Days Active")
                        .font(.caption)
                        .foregroundColor(.white)
                }
            }
            .padding()
            .background(Color.black.opacity(0.4))
            .cornerRadius(15)
            
            // Achievements
            VStack(alignment: .leading) {
                Text("Achievements")
                    .font(.headline)
                    .foregroundColor(.white)
                    .padding(.horizontal)
                
                ScrollView {
                    LazyVStack(spacing: 10) {
                        ForEach(achievements) { achievement in
                            AchievementRow(achievement: achievement)
                        }
                    }
                    .padding(.horizontal)
                }
                .frame(maxHeight: 200)
            }
            
            Spacer()
        }
        .background(
            Image("sky")
                .resizable()
                .scaledToFill()
                .ignoresSafeArea()
        )
    }
}

struct Achievement: Identifiable {
    let id = UUID()
    let title: String
    let description: String
    let isUnlocked: Bool
}

struct AchievementRow: View {
    let achievement: Achievement
    
    var body: some View {
        HStack {
            Image(systemName: achievement.isUnlocked ? "star.fill" : "star")
                .foregroundColor(achievement.isUnlocked ? .yellow : .gray)
            
            VStack(alignment: .leading) {
                Text(achievement.title)
                    .font(.headline)
                    .foregroundColor(.white)
                
                Text(achievement.description)
                    .font(.caption)
                    .foregroundColor(.white.opacity(0.8))
            }
            
            Spacer()
        }
        .padding()
        .background(Color.black.opacity(0.3))
        .cornerRadius(10)
        .opacity(achievement.isUnlocked ? 1.0 : 0.6)
    }
}
