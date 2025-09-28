//
//  ContentView.swift
//  Heartifacts
//
//  Created by Shaya Farahmand on 9/27/25.
//

import SwiftUI

// MARK: - Main Content View

struct ContentView: View {
    @State private var selectedTab = 0
    
    var body: some View {
        ZStack {
            // Main content with TabView for swiping
            TabView(selection: $selectedTab) {
                // 1. Home Tab
                TabItemView(imageName: "museum", viewName: "Home", textColor: .white) {
                    HomeView()
                }
                .tag(0)

                // 2. Tasks Tab
                TabItemView(imageName: "task", viewName: "Tasks", textColor: .white) {
                    TasksView()
                }
                .tag(1)

                // 3. Gallery Tab
                TabItemView(imageName: "museum", viewName: "Gallery", textColor: .white) {
                    GalleryView()
                }
                .tag(2)

                // 4. Insights Tab
                TabItemView(imageName: "sky", viewName: "Insights", textColor: .white) {
                    InsightsView()
                }
                .tag(3)

                // 5. Profile Tab
                TabItemView(imageName: "sky", viewName: "Profile", textColor: .white) {
                    ProfileView()
                }
                .tag(4)
            }
            .tabViewStyle(PageTabViewStyle())
            .ignoresSafeArea()
            
            // Bottom Navigation Bar
            VStack {
                Spacer()
                BottomNavigationBar(selectedTab: $selectedTab)
            }
        }
    }
}

//---

// MARK: - Home View

/// The unique content for the "Home" tab, including a chandelier, a list, and counters.
struct HomeView: View {
    // State variables for the counters
    @State private var sleepScore = 87
    @State private var stressLevel = 23
    @State private var exerciseScore = 92
    
    // Weekly data for the graph
    @State private var weeklyData = [
        WeeklyData(day: "Mon", sleep: 85, stress: 25, exercise: 88),
        WeeklyData(day: "Tue", sleep: 82, stress: 30, exercise: 92),
        WeeklyData(day: "Wed", sleep: 90, stress: 20, exercise: 85),
        WeeklyData(day: "Thu", sleep: 88, stress: 28, exercise: 95),
        WeeklyData(day: "Fri", sleep: 83, stress: 35, exercise: 78),
        WeeklyData(day: "Sat", sleep: 92, stress: 15, exercise: 100),
        WeeklyData(day: "Sun", sleep: 89, stress: 18, exercise: 90)
    ]

    var body: some View {
        VStack {
            // 1. Chandelier Element (using SF Symbol for simplicity)
            // It's positioned at the top of the Vstack to simulate a hanging light.
            Image(systemName: "light.ceiling.fill")
                .resizable()
                .scaledToFit()
                .frame(width: 100, height: 100)
                .foregroundColor(.yellow)
                .padding(.top, 0) // Push it down from the top of the screen

            // 2. Title Over the Chandelier
            Text("Heartifacts")
                .font(.system(size: 36, weight: .black, design: .default))
                .foregroundColor(.white)
                .shadow(radius: 5)
                .padding(.bottom, 20)

            // 3. Counter Elements
            HStack(spacing: 20) {
                CounterView(label: "Sleep Score", count: sleepScore, color: .blue)
                CounterView(label: "Stress", count: stressLevel, color: .red)
                CounterView(label: "Exercise", count: exerciseScore, color: .green)
            }
            .padding()

            // 4. Weekly Graph
            WeeklyHealthGraph(data: weeklyData)
                .padding(.horizontal, 20)
                .padding(.bottom, 20)

            Spacer() // Pushes content up
        }
    }
}

//---

// MARK: - Helper Views

/// A reusable component for a counter display with museum aesthetic.
struct CounterView: View {
    let label: String
    var count: Int? = nil
    var value: String? = nil // For values that aren't simple integers (like percentages)
    let color: Color

    var body: some View {
        VStack(spacing: 8) {
            Text(value ?? "\(count!)")
                .font(.system(size: 32, weight: .black, design: .rounded))
                .foregroundColor(color)
                .shadow(color: .black.opacity(0.3), radius: 2, x: 0, y: 1)
            
            Text(label)
                .font(.system(.caption, design: .serif))
                .fontWeight(.medium)
                .foregroundColor(.white)
                .multilineTextAlignment(.center)
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 16)
        .background(
            RoundedRectangle(cornerRadius: 16, style: .continuous)
                .fill(.ultraThinMaterial)
                .overlay(
                    RoundedRectangle(cornerRadius: 16, style: .continuous)
                        .stroke(
                            LinearGradient(
                                gradient: Gradient(colors: [color.opacity(0.4), .cyan.opacity(0.2)]),
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            ),
                            lineWidth: 1
                        )
                )
                .shadow(color: .black.opacity(0.2), radius: 8, x: 0, y: 4)
        )
    }
}

/// A reusable component for a list row with museum aesthetic.
struct MuseumTaskRow: View {
    let task: String

    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: "checkmark.circle.fill")
                .foregroundColor(.cyan)
                .font(.title3)
                .shadow(color: .cyan.opacity(0.3), radius: 2, x: 0, y: 1)
            
            Text(task)
                .font(.system(.body, design: .serif))
                .fontWeight(.medium)
                .foregroundColor(.white)
                .shadow(color: .black.opacity(0.3), radius: 1, x: 0, y: 1)
            
            Spacer()
            
            // Subtle decorative element
            Circle()
                .fill(
                    LinearGradient(
                        gradient: Gradient(colors: [.gold.opacity(0.3), .cyan.opacity(0.2)]),
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .frame(width: 6, height: 6)
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
        .background(
            RoundedRectangle(cornerRadius: 12, style: .continuous)
                .fill(.ultraThinMaterial)
                .overlay(
                    RoundedRectangle(cornerRadius: 12, style: .continuous)
                        .stroke(
                            LinearGradient(
                                gradient: Gradient(colors: [.cyan.opacity(0.2), .gold.opacity(0.1)]),
                                startPoint: .leading,
                                endPoint: .trailing
                            ),
                            lineWidth: 0.5
                        )
                )
                .shadow(color: .black.opacity(0.1), radius: 4, x: 0, y: 2)
        )
    }
}

// MARK: - Weekly Data Model
struct WeeklyData {
    let day: String
    let sleep: Int
    let stress: Int
    let exercise: Int
}

// MARK: - Weekly Health Graph
struct WeeklyHealthGraph: View {
    let data: [WeeklyData]
    
    private var maxValue: Int {
        max(data.map(\.sleep).max() ?? 0, 
            data.map(\.stress).max() ?? 0, 
            data.map(\.exercise).max() ?? 0)
    }
    
    private var minValue: Int {
        min(data.map(\.sleep).min() ?? 0, 
            data.map(\.stress).min() ?? 0, 
            data.map(\.exercise).min() ?? 0)
    }
    
    var body: some View {
        VStack(spacing: 12) {
            // Header
            HStack {
                Text("Weekly Trends")
                    .font(.system(.title3, design: .serif))
                    .fontWeight(.medium)
                    .foregroundColor(.white)
                Spacer()
            }
            
            // Graph Container
            VStack(spacing: 8) {
                // Graph area with smooth lines
                ZStack {
                    // Grid lines
                    VStack(spacing: 0) {
                        Rectangle()
                            .fill(Color.white.opacity(0.1))
                            .frame(height: 1)
                        Spacer()
                        Rectangle()
                            .fill(Color.white.opacity(0.1))
                            .frame(height: 1)
                        Spacer()
                        Rectangle()
                            .fill(Color.white.opacity(0.1))
                            .frame(height: 1)
                    }
                    .frame(height: 80)
                    
                    // Smooth connected lines
                    GeometryReader { geometry in
                        let width = geometry.size.width
                        let height = geometry.size.height
                        
                        ZStack {
                            // Sleep line (Blue)
                            Path { path in
                                for (index, dayData) in data.enumerated() {
                                    let x = CGFloat(index) / CGFloat(data.count - 1) * width
                                    let y = height - (CGFloat(dayData.sleep - minValue) / CGFloat(maxValue - minValue)) * height
                                    
                                    if index == 0 {
                                        path.move(to: CGPoint(x: x, y: y))
                                    } else {
                                        path.addLine(to: CGPoint(x: x, y: y))
                                    }
                                }
                            }
                            .stroke(Color.blue, lineWidth: 2)
                            
                            // Stress line (Red)
                            Path { path in
                                for (index, dayData) in data.enumerated() {
                                    let x = CGFloat(index) / CGFloat(data.count - 1) * width
                                    let y = height - (CGFloat(dayData.stress - minValue) / CGFloat(maxValue - minValue)) * height
                                    
                                    if index == 0 {
                                        path.move(to: CGPoint(x: x, y: y))
                                    } else {
                                        path.addLine(to: CGPoint(x: x, y: y))
                                    }
                                }
                            }
                            .stroke(Color.red, lineWidth: 2)
                            
                            // Exercise line (Green)
                            Path { path in
                                for (index, dayData) in data.enumerated() {
                                    let x = CGFloat(index) / CGFloat(data.count - 1) * width
                                    let y = height - (CGFloat(dayData.exercise - minValue) / CGFloat(maxValue - minValue)) * height
                                    
                                    if index == 0 {
                                        path.move(to: CGPoint(x: x, y: y))
                                    } else {
                                        path.addLine(to: CGPoint(x: x, y: y))
                                    }
                                }
                            }
                            .stroke(Color.green, lineWidth: 2)
                        }
                    }
                    .frame(height: 80)
                }
                
                // X-axis labels (Mon-Sun)
                HStack {
                    ForEach(data, id: \.day) { dayData in
                        Text(dayData.day)
                            .font(.system(.caption2, design: .default))
                            .foregroundColor(.white.opacity(0.7))
                        if dayData.day != data.last?.day {
                            Spacer()
                        }
                    }
                }
                
                // Legend
                HStack(spacing: 16) {
                    LegendItem(color: .blue, label: "Sleep")
                    LegendItem(color: .red, label: "Stress")
                    LegendItem(color: .green, label: "Exercise")
                    Spacer()
                }
            }
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
        .background(
            RoundedRectangle(cornerRadius: 16, style: .continuous)
                .fill(.ultraThinMaterial)
                .overlay(
                    RoundedRectangle(cornerRadius: 16, style: .continuous)
                        .stroke(
                            LinearGradient(
                                gradient: Gradient(colors: [.cyan.opacity(0.3), .gold.opacity(0.2)]),
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            ),
                            lineWidth: 0.5
                        )
                )
                .shadow(color: .black.opacity(0.15), radius: 6, x: 0, y: 3)
        )
    }
}


struct LegendItem: View {
    let color: Color
    let label: String
    
    var body: some View {
        HStack(spacing: 6) {
            Circle()
                .fill(color)
                .frame(width: 8, height: 8)
            Text(label)
                .font(.system(.caption2, design: .default))
                .foregroundColor(.white.opacity(0.8))
        }
    }
}

// MARK: - Color Extensions
extension Color {
    static let gold = Color(red: 1.0, green: 0.84, blue: 0.0)
}

//---

// MARK: - Tab Item View (Refactored to accept content)

/// A reusable view for each tab's content, which applies a full-screen background and accepts unique `content`.
struct TabItemView<Content: View>: View {
    let imageName: String
    let viewName: String
    let textColor: Color
    @ViewBuilder let content: Content // Accepts any SwiftUI view as content

    // Helper property to safely check if the imageName is a valid SF Symbol.
    private var isSFSymbol: Bool {
        // Use the search tool to verify the SF Symbol is valid before shipping.
        UIImage(systemName: imageName) != nil
    }

    var body: some View {
        ZStack {
            // Background Image or Symbol
            Group {
                if isSFSymbol {
                    Image(systemName: imageName)
                        .resizable()
                        .scaledToFit()
                        .foregroundColor(.gray)
                } else {
                    Image(imageName)
                        .resizable()
                        .renderingMode(.original)
                        .scaledToFill()
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .edgesIgnoringSafeArea(.all)

            // Content provided by the call site (HomeView, Text("Discover Content"), etc.)
            content
        }
    }
}

// MARK: - Bottom Navigation Bar

struct BottomNavigationBar: View {
    @Binding var selectedTab: Int
    
    private let tabs = [
        NavigationTab(icon: "house.fill", title: "Home", tag: 0),
        NavigationTab(icon: "checklist", title: "Tasks", tag: 1),
        NavigationTab(icon: "photo.on.rectangle", title: "Gallery", tag: 2),
        NavigationTab(icon: "chart.bar.fill", title: "Insights", tag: 3),
        NavigationTab(icon: "person.fill", title: "Profile", tag: 4)
    ]
    
    var body: some View {
        HStack(spacing: 0) {
            ForEach(tabs, id: \.tag) { tab in
                Button(action: {
                    withAnimation(.easeInOut(duration: 0.3)) {
                        selectedTab = tab.tag
                    }
                }) {
                    VStack(spacing: 4) {
                        ZStack {
                            // Blue background for selected tab
                            if selectedTab == tab.tag {
                                RoundedRectangle(cornerRadius: 12)
                                    .fill(Color.blue.opacity(0.2))
                                    .frame(width: 50, height: 50)
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 12)
                                            .stroke(Color.blue, lineWidth: 2)
                                    )
                            }
                            
                            Image(systemName: tab.icon)
                                .font(.system(size: 20, weight: .medium))
                                .foregroundColor(selectedTab == tab.tag ? .blue : .gray)
                        }
                        
                        Text(tab.title)
                            .font(.caption2)
                            .foregroundColor(selectedTab == tab.tag ? .blue : .gray)
                    }
                }
                .frame(maxWidth: .infinity)
            }
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
    }
}

struct NavigationTab {
    let icon: String
    let title: String
    let tag: Int
}

// MARK: - Tasks View
struct TasksView: View {
    @State private var tasks = [
        TaskItem(title: "Complete daily meditation", isCompleted: false),
        TaskItem(title: "Review museum artifacts", isCompleted: true),
        TaskItem(title: "Update exhibit descriptions", isCompleted: false),
        TaskItem(title: "Plan next acquisition", isCompleted: false)
    ]
    
    var body: some View {
        VStack {
            Text("Tasks")
                .font(.largeTitle)
                .fontWeight(.bold)
                .foregroundColor(.white)
                .padding(.top, 20)
            
            List {
                ForEach(tasks.indices, id: \.self) { index in
                    TaskRowView(task: $tasks[index])
                }
            }
            .listStyle(PlainListStyle())
            .scrollContentBackground(.hidden)
            .background(Color.clear)
        }
        .background(
            Image("task")
                .resizable()
                .scaledToFill()
                .ignoresSafeArea()
        )
    }
}

struct TaskItem: Identifiable {
    let id = UUID()
    var title: String
    var isCompleted: Bool
}

struct TaskRowView: View {
    @Binding var task: TaskItem
    
    var body: some View {
        HStack {
            Button(action: {
                task.isCompleted.toggle()
            }) {
                Image(systemName: task.isCompleted ? "checkmark.circle.fill" : "circle")
                    .foregroundColor(task.isCompleted ? .green : .gray)
                    .font(.title2)
            }
            
            Text(task.title)
                .foregroundColor(.white)
                .strikethrough(task.isCompleted)
                .opacity(task.isCompleted ? 0.6 : 1.0)
            
            Spacer()
        }
        .padding(.vertical, 8)
        .background(Color.black.opacity(0.3))
        .cornerRadius(8)
    }
}

// MARK: - Gallery View
struct GalleryView: View {
    let artifacts = [
        Artifact(name: "Ancient Vase", description: "A beautiful ceramic piece from 500 BC", imageName: "museum"),
        Artifact(name: "Golden Mask", description: "Ritual mask from ancient civilization", imageName: "museum"),
        Artifact(name: "Stone Tablet", description: "Inscribed with ancient text", imageName: "museum"),
        Artifact(name: "Bronze Statue", description: "Small deity figure", imageName: "museum")
    ]
    
    var body: some View {
        VStack {
            Text("Gallery")
                .font(.largeTitle)
                .fontWeight(.bold)
                .foregroundColor(.white)
                .padding(.top, 20)
            
            ScrollView {
                LazyVGrid(columns: [
                    GridItem(.flexible()),
                    GridItem(.flexible())
                ], spacing: 20) {
                    ForEach(artifacts) { artifact in
                        ArtifactCard(artifact: artifact)
                    }
                }
                .padding()
            }
        }
        .background(
            Image("museum")
                .resizable()
                .scaledToFill()
                .ignoresSafeArea()
        )
    }
}

struct Artifact: Identifiable {
    let id = UUID()
    let name: String
    let description: String
    let imageName: String
}

struct ArtifactCard: View {
    let artifact: Artifact
    
    var body: some View {
        VStack {
            Image(artifact.imageName)
                .resizable()
                .scaledToFit()
                .frame(height: 120)
                .cornerRadius(10)
            
            Text(artifact.name)
                .font(.headline)
                .foregroundColor(.white)
                .multilineTextAlignment(.center)
            
            Text(artifact.description)
                .font(.caption)
                .foregroundColor(.white.opacity(0.8))
                .multilineTextAlignment(.center)
        }
        .padding()
        .background(Color.black.opacity(0.4))
        .cornerRadius(15)
    }
}

// MARK: - Profile View
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

// MARK: - Insights View
struct InsightsView: View {
    @State private var currentWeek = 0
    @State private var sleepQuality: Double = 0.87
    @State private var stressLevel: Double = 0.23
    @State private var exerciseIntensity: Double = 0.92
    @State private var aiCuratorNote = "This crystal grew brighter this week thanks to consistent rest. Your sleep patterns show remarkable improvement!"
    
    private let weeklyData = [
        WeekData(week: "This Week", sleep: 87, stress: 23, exercise: 92, correlation: "Sleep ↔ Exercise"),
        WeekData(week: "Last Week", sleep: 82, stress: 31, exercise: 78, correlation: "Stress ↑ Exercise ↓"),
        WeekData(week: "2 Weeks Ago", sleep: 75, stress: 45, exercise: 65, correlation: "All metrics improving"),
        WeekData(week: "3 Weeks Ago", sleep: 68, stress: 52, exercise: 58, correlation: "Stress dominant")
    ]
    
    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                // Museum Header
                HStack {
                    Image(systemName: "sparkles")
                        .foregroundColor(.gold)
                        .font(.title2)
                    Text("Museum of Insights")
                        .font(.system(.largeTitle, design: .serif))
                        .fontWeight(.bold)
                        .foregroundColor(.white)
                    Spacer()
                }
                .padding(.horizontal, 20)
                .padding(.top, 20)
                
                // AI Curator Note
                AICuratorNote(note: aiCuratorNote)
                
                // Current Week Artifacts Gallery
                VStack(spacing: 16) {
                    Text("Current Exhibit")
                        .font(.system(.title2, design: .serif))
                        .fontWeight(.medium)
                        .foregroundColor(.white)
                        .padding(.horizontal, 20)
                    
                    // Dynamic Artifacts
                    HStack(spacing: 20) {
                        SleepCrystal(clarity: sleepQuality)
                        StressSculpture(bend: stressLevel)
                        ExerciseOrb(energy: exerciseIntensity)
                    }
                    .padding(.horizontal, 20)
                    
                    // Linked Artifacts with Glowing Threads
                    if sleepQuality > 0.8 && exerciseIntensity > 0.8 {
                        LinkedArtifactsView()
                    }
                }
                
                // Weekly Timeline Gallery
                WeeklyTimelineGallery(data: weeklyData, currentWeek: $currentWeek)
                
                Spacer(minLength: 100) // Space for bottom navigation
            }
        }
        .background(
            Image("sky")
                .resizable()
                .scaledToFill()
                .ignoresSafeArea()
        )
    }
}

// MARK: - AI Curator Note
struct AICuratorNote: View {
    let note: String
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Image(systemName: "brain.head.profile")
                    .foregroundColor(.cyan)
                    .font(.title3)
                Text("AI Curator's Note")
                    .font(.system(.headline, design: .serif))
                    .fontWeight(.medium)
                    .foregroundColor(.white)
                Spacer()
            }
            
            Text(note)
                .font(.system(.body, design: .serif))
                .foregroundColor(.white.opacity(0.9))
                .lineLimit(nil)
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 16)
        .background(
            RoundedRectangle(cornerRadius: 16, style: .continuous)
                .fill(.ultraThinMaterial)
                .overlay(
                    RoundedRectangle(cornerRadius: 16, style: .continuous)
                        .stroke(
                            LinearGradient(
                                gradient: Gradient(colors: [.cyan.opacity(0.4), .gold.opacity(0.3)]),
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            ),
                            lineWidth: 1
                        )
                )
                .shadow(color: .black.opacity(0.2), radius: 8, x: 0, y: 4)
        )
        .padding(.horizontal, 20)
    }
}

// MARK: - Sleep Crystal
struct SleepCrystal: View {
    let clarity: Double
    
    var body: some View {
        VStack(spacing: 8) {
            ZStack {
                // Crystal base
                RoundedRectangle(cornerRadius: 8)
                    .fill(Color.blue.opacity(0.3))
                    .frame(width: 60, height: 80)
                
                // Crystal facets
                ForEach(0..<3, id: \.self) { index in
                    RoundedRectangle(cornerRadius: 4)
                        .fill(
                            LinearGradient(
                                gradient: Gradient(colors: [
                                    Color.blue.opacity(0.8 * clarity),
                                    Color.cyan.opacity(0.6 * clarity)
                                ]),
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .frame(width: 40, height: 60)
                        .offset(x: CGFloat(index - 1) * 8, y: CGFloat(index - 1) * 5)
                }
            }
            .shadow(color: .blue.opacity(0.5), radius: 8, x: 0, y: 4)
            
            Text("Sleep Crystal")
                .font(.system(.caption, design: .serif))
                .foregroundColor(.white)
                .multilineTextAlignment(.center)
        }
    }
}

// MARK: - Stress Sculpture
struct StressSculpture: View {
    let bend: Double
    
    var body: some View {
        VStack(spacing: 8) {
            ZStack {
                // Sculpture base
                RoundedRectangle(cornerRadius: 4)
                    .fill(Color.red.opacity(0.3))
                    .frame(width: 60, height: 80)
                
                // Bending sculpture
                RoundedRectangle(cornerRadius: 4)
                    .fill(
                        LinearGradient(
                            gradient: Gradient(colors: [
                                Color.red.opacity(0.8),
                                Color.orange.opacity(0.6)
                            ]),
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .frame(width: 40, height: 60)
                    .rotationEffect(.degrees(bend * 30 - 15)) // Bend based on stress
                    .offset(x: bend * 10 - 5, y: bend * 5)
            }
            .shadow(color: .red.opacity(0.5), radius: 8, x: 0, y: 4)
            
            Text("Stress Sculpture")
                .font(.system(.caption, design: .serif))
                .foregroundColor(.white)
                .multilineTextAlignment(.center)
        }
    }
}

// MARK: - Exercise Orb
struct ExerciseOrb: View {
    let energy: Double
    
    var body: some View {
        VStack(spacing: 8) {
            ZStack {
                // Orb base
                Circle()
                    .fill(Color.green.opacity(0.3))
                    .frame(width: 80, height: 80)
                
                // Energy rings
                ForEach(0..<3, id: \.self) { index in
                    Circle()
                        .stroke(
                            LinearGradient(
                                gradient: Gradient(colors: [
                                    Color.green.opacity(0.8 * energy),
                                    Color.mint.opacity(0.6 * energy)
                                ]),
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            ),
                            lineWidth: 3
                        )
                        .frame(width: 60 - CGFloat(index * 15), height: 60 - CGFloat(index * 15))
                        .scaleEffect(1.0 + energy * 0.3)
                }
            }
            .shadow(color: .green.opacity(0.5), radius: 8, x: 0, y: 4)
            
            Text("Exercise Orb")
                .font(.system(.caption, design: .serif))
                .foregroundColor(.white)
                .multilineTextAlignment(.center)
        }
    }
}

// MARK: - Linked Artifacts
struct LinkedArtifactsView: View {
    var body: some View {
        VStack(spacing: 12) {
            Text("Connected Patterns")
                .font(.system(.headline, design: .serif))
                .foregroundColor(.white)
            
            HStack(spacing: 30) {
                // Glowing connection lines
                HStack(spacing: 0) {
                    Circle()
                        .fill(Color.cyan)
                        .frame(width: 8, height: 8)
                        .shadow(color: .cyan, radius: 4)
                    
                    Rectangle()
                        .fill(
                            LinearGradient(
                                gradient: Gradient(colors: [.cyan, .blue]),
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                        .frame(height: 2)
                        .shadow(color: .cyan, radius: 2)
                    
                    Circle()
                        .fill(Color.blue)
                        .frame(width: 8, height: 8)
                        .shadow(color: .blue, radius: 4)
                }
                
                Text("Sleep ↔ Exercise")
                    .font(.system(.caption, design: .serif))
                    .foregroundColor(.white.opacity(0.8))
            }
        }
        .padding(.horizontal, 20)
    }
}

// MARK: - Weekly Timeline Gallery
struct WeeklyTimelineGallery: View {
    let data: [WeekData]
    @Binding var currentWeek: Int
    
    var body: some View {
        VStack(spacing: 16) {
            Text("Archive Gallery")
                .font(.system(.title2, design: .serif))
                .fontWeight(.medium)
                .foregroundColor(.white)
                .padding(.horizontal, 20)
            
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 16) {
                    ForEach(Array(data.enumerated()), id: \.offset) { index, week in
                        WeekExhibitCard(
                            week: week,
                            isCurrent: index == currentWeek,
                            isSelected: index == currentWeek
                        )
                        .onTapGesture {
                            withAnimation(.easeInOut(duration: 0.3)) {
                                currentWeek = index
                            }
                        }
                    }
                }
                .padding(.horizontal, 20)
            }
        }
    }
}

// MARK: - Week Exhibit Card
struct WeekExhibitCard: View {
    let week: WeekData
    let isCurrent: Bool
    let isSelected: Bool
    
    var body: some View {
        VStack(spacing: 12) {
            // Week label
            Text(week.week)
                .font(.system(.caption, design: .serif))
                .fontWeight(.medium)
                .foregroundColor(.white)
            
            // Mini artifacts
            HStack(spacing: 8) {
                // Mini sleep crystal
                RoundedRectangle(cornerRadius: 2)
                    .fill(Color.blue.opacity(0.6))
                    .frame(width: 12, height: 16)
                
                // Mini stress sculpture
                RoundedRectangle(cornerRadius: 2)
                    .fill(Color.red.opacity(0.6))
                    .frame(width: 12, height: 16)
                
                // Mini exercise orb
                Circle()
                    .fill(Color.green.opacity(0.6))
                    .frame(width: 16, height: 16)
            }
            
            // Correlation note
            Text(week.correlation)
                .font(.system(.caption2, design: .serif))
                .foregroundColor(.white.opacity(0.7))
                .multilineTextAlignment(.center)
                .lineLimit(2)
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 16)
        .background(
            RoundedRectangle(cornerRadius: 12, style: .continuous)
                .fill(.ultraThinMaterial)
                .overlay(
                    RoundedRectangle(cornerRadius: 12, style: .continuous)
                        .stroke(
                            isSelected ? 
                            LinearGradient(
                                gradient: Gradient(colors: [.cyan, .gold]),
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            ) :
                            LinearGradient(
                                gradient: Gradient(colors: [.cyan.opacity(0.3), .gold.opacity(0.2)]),
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            ),
                            lineWidth: isSelected ? 2 : 0.5
                        )
                )
                .shadow(color: .black.opacity(0.15), radius: 6, x: 0, y: 3)
        )
        .scaleEffect(isSelected ? 1.05 : 1.0)
    }
}

// MARK: - Data Models
struct WeekData {
    let week: String
    let sleep: Int
    let stress: Int
    let exercise: Int
    let correlation: String
}
