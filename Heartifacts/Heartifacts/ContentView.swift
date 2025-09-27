//
//  ContentView.swift
//  Heartifacts
//
//  Created by Shaya Farahmand on 9/27/25.
//

import SwiftUI

// MARK: - Main Content View

struct ContentView: View {
    var body: some View {
        // TabView with PageTabViewStyle allows for a swipeable, full-screen tab interface.
        TabView {
            // 1. Home Tab (Uses a custom, unique HomeView)
            TabItemView(imageName: "museum", viewName: "Home", textColor: .white) {
                HomeView() // The new, unique view with the list, counters, and chandelier
            }
            .tag(0)

            // 2. Discover Tab (Simple placeholder, or could be replaced with a custom view later)
            TabItemView(imageName: "sky", viewName: "Discover", textColor: .yellow) {
                // The TabItemView now takes a content closure.
                Text("Discover Content")
                    .foregroundColor(.white)
            }
            .tag(1)

            // 3. Museum Thingy Tab
            TabItemView(imageName: "task", viewName: "Museum Thingy", textColor: .pink) {
                Text("Museum Content")
                    .foregroundColor(.white)
            }
            .tag(2)

            // 4. Messages Tab
            TabItemView(imageName: "sky", viewName: "Messages", textColor: .white) {
                Text("Messages Content")
                    .foregroundColor(.white)
            }
            .tag(3)

            // 5. Profile Tab
            TabItemView(imageName: "person.crop.circle.fill", viewName: "Profile", textColor: .white) {
                Text("Profile Content")
                    .foregroundColor(.white)
            }
            .tag(4)
        }
        .tabViewStyle(PageTabViewStyle())
        .ignoresSafeArea()
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
                .padding(.top, 50) // Push it down from the top of the screen

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
