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
    @State private var artifactsFound = 3
    @State private var energyLevel = 85.0

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
            Text("Welcome Home")
                .font(.largeTitle)
                .fontWeight(.black)
                .foregroundColor(.white)
                .shadow(radius: 5)
                .padding(.bottom, 20)

            // 3. Counter Elements
            HStack(spacing: 40) {
                CounterView(label: "Artifacts Found", count: artifactsFound, color: .orange)
                CounterView(label: "Energy %", value: String(format: "%.0f", energyLevel), color: .green)
            }
            .padding()

            // 4. List Element (Using a List for scrollable items)
            List {
                Section(header: Text("Pending Tasks").font(.headline)) {
                    TaskRow(task: "Fix the skylight")
                    TaskRow(task: "Clean the exhibits")
                    TaskRow(task: "Research new acquisitions")
                }
                .listRowBackground(Color.black.opacity(0.6)) // Apply a semi-transparent background to list items
            }
            // Use a clear background for the List container itself to see the background image
            .scrollContentBackground(.hidden)
            .background(Color.clear)
            .frame(height: 200) // Constrain the list height
            .padding()

            Spacer() // Pushes content up
        }
    }
}

//---

// MARK: - Helper Views

/// A reusable component for a counter display.
struct CounterView: View {
    let label: String
    var count: Int? = nil
    var value: String? = nil // For values that aren't simple integers (like percentages)
    let color: Color

    var body: some View {
        VStack {
            Text(value ?? "\(count!)")
                .font(.system(size: 30, weight: .heavy, design: .rounded))
                .foregroundColor(color)
            Text(label)
                .font(.caption)
                .foregroundColor(.white)
        }
        .padding()
        .background(Color.black.opacity(0.5))
        .cornerRadius(10)
    }
}

/// A reusable component for a list row.
struct TaskRow: View {
    let task: String

    var body: some View {
        HStack {
            Image(systemName: "checkmark.circle.fill")
                .foregroundColor(.blue)
            Text(task)
                .foregroundColor(.white)
            Spacer()
        }
    }
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
