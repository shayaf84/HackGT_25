import SwiftUI
import UIKit

// MARK: - Theme Tokens

enum HeartifactsTheme {
    static let accent = Color(red: 0.1, green: 0.75, blue: 0.93)
    static let backgroundTop = Color(red: 0.09, green: 0.03, blue: 0.29)
    static let backgroundBottom = Color(red: 0.02, green: 0.01, blue: 0.12)
    static let backgroundHighlight = Color(red: 0.38, green: 0.16, blue: 0.55)
    static let quietLabel = Color.white.opacity(0.65)
}

struct AppBackground: View {
    var body: some View {
        ZStack {
            LinearGradient(
                gradient: Gradient(colors: [HeartifactsTheme.backgroundTop, HeartifactsTheme.backgroundBottom]),
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            RadialGradient(
                gradient: Gradient(colors: [HeartifactsTheme.backgroundHighlight.opacity(0.6), .clear]),
                center: .topLeading,
                startRadius: 80,
                endRadius: 600
            )
            RadialGradient(
                gradient: Gradient(colors: [HeartifactsTheme.accent.opacity(0.3), .clear]),
                center: .bottomTrailing,
                startRadius: 60,
                endRadius: 520
            )
        }
        .overlay(
            LinearGradient(
                gradient: Gradient(colors: [.white.opacity(0.05), .clear, .white.opacity(0.05)]),
                startPoint: .top,
                endPoint: .bottom
            ).blendMode(.overlay)
        )
        .ignoresSafeArea()
    }
}

struct GlassBackground: View {
    var cornerRadius: CGFloat = 28
    var shadowRadius: CGFloat = 24
    var body: some View {
        RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
            .fill(.ultraThinMaterial)
            .background(.clear)
            .overlay(
                RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                    .fill(Color.white.opacity(0.08))
            )
            .overlay(
                RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                    .stroke(
                        LinearGradient(
                            gradient: Gradient(colors: [HeartifactsTheme.accent.opacity(0.55), Color.blue.opacity(0.35)]),
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        ),
                        lineWidth: 1
                    )
            )
            .shadow(color: Color.black.opacity(0.35), radius: shadowRadius, x: 0, y: 18)
    }
}

struct GlassCard<Content: View>: View {
    var cornerRadius: CGFloat
    var padding: CGFloat
    @ViewBuilder var content: Content

    init(cornerRadius: CGFloat = 28, padding: CGFloat = 24, @ViewBuilder content: () -> Content) {
        self.cornerRadius = cornerRadius
        self.padding = padding
        self.content = content()
    }

    var body: some View {
        content
            .padding(padding)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(
                GlassBackground(cornerRadius: cornerRadius)
                    .overlay(
                        RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                            .strokeBorder(Color.white.opacity(0.02), lineWidth: 1)
                    )
            )
    }
}

struct AnimatedAuroraBackground: View {
    var body: some View {
        TimelineView(.animation(minimumInterval: 1 / 24)) { timeline in
            let phase = timeline.date.timeIntervalSinceReferenceDate
            Canvas { context, size in
                let baseRect = CGRect(origin: .zero, size: size)
                let time = CGFloat(phase.truncatingRemainder(dividingBy: 12))
                let oscillation = sin(time * .pi / 3)
                let secondaryOscillation = sin((time + 2) * .pi / 4)

                context.fill(
                    Path(roundedRect: baseRect, cornerRadius: 32),
                    with: .linearGradient(
                        Gradient(colors: [
                            HeartifactsTheme.accent.opacity(0.25),
                            Color.purple.opacity(0.18),
                            Color.blue.opacity(0.22)
                        ]),
                        startPoint: CGPoint(x: 0, y: 0),
                        endPoint: CGPoint(x: size.width, y: size.height)
                    )
                )

                let waveRect = CGRect(
                    x: -size.width * 0.2 + oscillation * size.width * 0.12,
                    y: size.height * 0.1,
                    width: size.width * 1.4,
                    height: size.height * 0.8
                )

                context.fill(
                    Path(ellipseIn: waveRect),
                    with: .radialGradient(
                        Gradient(colors: [
                            HeartifactsTheme.accent.opacity(0.55),
                            Color.clear
                        ]),
                        center: CGPoint(x: waveRect.midX, y: waveRect.minY + waveRect.height * 0.25),
                        startRadius: 20,
                        endRadius: max(waveRect.width, waveRect.height)
                    )
                )

                let secondaryRect = CGRect(
                    x: size.width * 0.1,
                    y: size.height * (0.25 + secondaryOscillation * 0.1),
                    width: size.width * 0.9,
                    height: size.height * 0.7
                )

                context.fill(
                    Path(ellipseIn: secondaryRect),
                    with: .linearGradient(
                        Gradient(colors: [
                            Color.purple.opacity(0.4),
                            Color.blue.opacity(0.15)
                        ]),
                        startPoint: CGPoint(x: secondaryRect.minX, y: secondaryRect.midY),
                        endPoint: CGPoint(x: secondaryRect.maxX, y: secondaryRect.maxY)
                    )
                )

                let highlightPath = Path { path in
                    path.move(to: CGPoint(x: 0, y: size.height * 0.75))
                    path.addCurve(
                        to: CGPoint(x: size.width, y: size.height * 0.45),
                        control1: CGPoint(x: size.width * 0.25, y: size.height * (0.55 + oscillation * 0.05)),
                        control2: CGPoint(x: size.width * 0.6, y: size.height * (0.4 + secondaryOscillation * 0.07))
                    )
                    path.addLine(to: CGPoint(x: size.width, y: size.height))
                    path.addLine(to: CGPoint(x: 0, y: size.height))
                    path.closeSubpath()
                }

                context.fill(
                    highlightPath,
                    with: .linearGradient(
                        Gradient(colors: [
                            Color.white.opacity(0.08),
                            Color.clear
                        ]),
                        startPoint: CGPoint(x: 0, y: size.height * 0.5),
                        endPoint: CGPoint(x: 0, y: size.height)
                    )
                )
            }
        }
        .overlay(
            RoundedRectangle(cornerRadius: 32, style: .continuous)
                .stroke(Color.white.opacity(0.08), lineWidth: 1)
        )
        .shadow(color: Color.black.opacity(0.35), radius: 40, x: 0, y: 24)
    }
}

// MARK: - Main Content View

struct ContentView: View {
    @State private var selectedTab = 0
    @StateObject private var manager = Manager()
    
    var body: some View {
        ZStack {
            AppBackground()

            VStack(spacing: 0) {
            TabView(selection: $selectedTab) {
                    TabItemView {
                    HomeView(manager: manager)
                }
                .tag(0)

                    TabItemView {
                    GalleryView(manager: manager)
                }
                .tag(1)

                    TabItemView {
                    ProfileView()
                }
                .tag(2)
            }
                .tabViewStyle(PageTabViewStyle(indexDisplayMode: .never))
            .ignoresSafeArea()
            
                BottomNavigationBar(selectedTab: $selectedTab)
                    .padding(.bottom, 24)
            }
        }
        .onAppear {
            manager.loadAllHealthData()
        }
    }
}

//---

// MARK: - Home View

/// The unique content for the "Home" tab, including a chandelier, a list, and counters.
struct HomeView: View {
    @ObservedObject var manager: Manager
    
    var body: some View {
        ZStack(alignment: .topLeading) {
            Image("museum")
                .resizable()
                .scaledToFill()
                .ignoresSafeArea()

            LinearGradient(gradient: Gradient(colors: [Color.black.opacity(0.6), Color.clear]), startPoint: .top, endPoint: .center)
                .frame(height: 240)
                .ignoresSafeArea()

            VStack(alignment: .leading, spacing: 16) {
            Text("Heartifacts")
                .font(.system(size: 44, weight: .bold, design: .rounded))
                .foregroundColor(.white)
                .padding(.top, 72)
                .padding(.leading, 28)
                
                // Health Data Summary
                if manager.isLoading {
                    HStack {
                        ProgressView()
                            .progressViewStyle(CircularProgressViewStyle(tint: .white))
                        Text("Loading your health data...")
                .foregroundColor(.white)
                            .font(.system(size: 16, weight: .medium))
                    }
                    .padding(.leading, 28)
                } else if !manager.errorMessage.isEmpty {
                    Text("Error: \(manager.errorMessage)")
                        .foregroundColor(.red)
                        .font(.system(size: 16, weight: .medium))
                        .padding(.leading, 28)
                } else if let combinedData = manager.combinedHealthData {
                    HealthSummaryCard(combinedData: combinedData)
                        .padding(.horizontal, 28)
                }
                
                // Refresh Button
                Button(action: {
                    manager.refreshData()
                }) {
                    HStack {
                        Image(systemName: "arrow.clockwise")
                        Text("Refresh Data")
                    }
                    .font(.system(size: 16, weight: .medium, design: .rounded))
                    .foregroundColor(.white)
                    .padding(.horizontal, 20)
                    .padding(.vertical, 12)
        .background(
                        Capsule()
                            .fill(.ultraThinMaterial)
                .overlay(
                                Capsule()
                                    .stroke(Color.white.opacity(0.3), lineWidth: 1)
                            )
                    )
                }
                .padding(.leading, 28)
                .padding(.top, 8)
            }
        }
    }
}

// MARK: - Health Summary Card
struct HealthSummaryCard: View {
    let combinedData: CombinedHealthData

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Today's Health Summary")
                .font(.system(size: 20, weight: .bold, design: .rounded))
                .foregroundColor(.white)

            HStack(spacing: 20) {
                // Sleep Score
                VStack(alignment: .leading, spacing: 4) {
                    Text("Sleep")
                        .font(.system(size: 12, weight: .medium, design: .rounded))
                        .foregroundColor(.white.opacity(0.8))
                    Text("\(combinedData.sleepData?.sleepScore ?? 0)")
                        .font(.system(size: 24, weight: .bold, design: .rounded))
                        .foregroundColor(.blue)
                    }
            
            Spacer()
            
                // Steps
                VStack(alignment: .leading, spacing: 4) {
                    Text("Steps")
                        .font(.system(size: 12, weight: .medium, design: .rounded))
                        .foregroundColor(.white.opacity(0.8))
                    Text("\(combinedData.movementData?.steps ?? 0)")
                        .font(.system(size: 24, weight: .bold, design: .rounded))
                        .foregroundColor(.green)
                }
                
                Spacer()
                
                // HRV
            VStack(alignment: .leading, spacing: 4) {
                    Text("HRV")
                        .font(.system(size: 12, weight: .medium, design: .rounded))
                        .foregroundColor(.white.opacity(0.8))
                    if let hrv = combinedData.stressData?.heartRateVariability {
                        Text("\(String(format: "%.0f", hrv))")
                            .font(.system(size: 24, weight: .bold, design: .rounded))
                            .foregroundColor(.orange)
                    } else {
                        Text("N/A")
                            .font(.system(size: 24, weight: .bold, design: .rounded))
                            .foregroundColor(.gray)
                    }
                }
            }
        }
        .padding(20)
                        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(.ultraThinMaterial)
                                .overlay(
                    RoundedRectangle(cornerRadius: 16)
                        .stroke(Color.white.opacity(0.2), lineWidth: 1)
                )
        )
    }
}

private struct HeroHeaderSection: View {
    let title: String
    let subtitle: String
    let caption: String

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            ZStack {
                AnimatedAuroraBackground()
                    .frame(height: 200)
                    .clipShape(RoundedRectangle(cornerRadius: 40, style: .continuous))

                VStack(alignment: .leading, spacing: 12) {
                Text(title)
                        .font(.system(size: 36, weight: .bold, design: .rounded))
                    .foregroundStyle(.white)
                        .shadow(color: .black.opacity(0.35), radius: 12, x: 0, y: 8)

                    Text(subtitle)
                        .font(.system(size: 15, weight: .medium, design: .rounded))
                    .foregroundColor(HeartifactsTheme.quietLabel)
            }
                .padding(.leading, 24)
                .frame(maxWidth: .infinity, alignment: .leading)
            }

            Text(caption)
                .font(.system(size: 18, weight: .medium, design: .rounded))
                            .foregroundColor(HeartifactsTheme.quietLabel)
                .padding(.leading, 12)
        }
    }
}






//---

// MARK: - Helper Views

/// A reusable component for a counter display with museum aesthetic.


// MARK: - Color Extensions
extension Color {
    static let gold = Color(red: 1.0, green: 0.84, blue: 0.0)
}

//---

// MARK: - Tab Item View (Refactored to accept content)

/// A reusable view for each tab's content, which applies a full-screen background and accepts unique `content`.
struct TabItemView<Content: View>: View {
    @ViewBuilder let content: Content

    var body: some View {
        ZStack {
            AppBackground()
            content
        }
        .ignoresSafeArea()
    }
}

// MARK: - Bottom Navigation Bar

struct BottomNavigationBar: View {
    @Binding var selectedTab: Int
    
    private let tabs = [
        NavigationTab(icon: "house.fill", title: "Home", tag: 0),
        NavigationTab(icon: "photo.on.rectangle", title: "Gallery", tag: 1),
        NavigationTab(icon: "person.fill", title: "Profile", tag: 2)
    ]
    
    var body: some View {
        GlassCard(cornerRadius: 34, padding: 18) {
        HStack(spacing: 0) {
            ForEach(tabs, id: \.tag) { tab in
                Button(action: {
                        withAnimation(.interactiveSpring(response: 0.5, dampingFraction: 0.8, blendDuration: 0.6)) {
                        selectedTab = tab.tag
                    }
                        triggerHaptic()
                }) {
                        VStack(spacing: 8) {
                        ZStack {
                            if selectedTab == tab.tag {
                                    Capsule()
                                        .fill(HeartifactsTheme.accent.opacity(0.25))
                                        .frame(width: 56, height: 40)
                                    .overlay(
                                            Capsule()
                                                .stroke(HeartifactsTheme.accent, lineWidth: 1.2)
                                    )
                                        .shadow(color: HeartifactsTheme.accent.opacity(0.45), radius: 10, x: 0, y: 4)
                            }
                            
                            Image(systemName: tab.icon)
                                    .font(.system(size: 19, weight: .semibold, design: .rounded))
                                    .foregroundColor(selectedTab == tab.tag ? HeartifactsTheme.accent : HeartifactsTheme.quietLabel)
                                    .shadow(color: selectedTab == tab.tag ? HeartifactsTheme.accent.opacity(0.6) : .clear, radius: 8, x: 0, y: 0)
                        }
                            .frame(height: 40)
                        
                        Text(tab.title)
                                .font(.system(size: 11, weight: .semibold, design: .rounded))
                                .foregroundColor(selectedTab == tab.tag ? .white : HeartifactsTheme.quietLabel)
                                .overlay(alignment: .bottom) {
                                    if selectedTab == tab.tag {
                                        Capsule()
                                            .fill(HeartifactsTheme.accent)
                                            .frame(width: 18, height: 3)
                                            .offset(y: 6)
                                            .transition(.move(edge: .bottom).combined(with: .opacity))
                                    }
                    }
                }
                .frame(maxWidth: .infinity)
                        .padding(.vertical, 4)
                        .animation(.easeInOut(duration: 0.3), value: selectedTab)
                    }
                }
            }
        }
        .padding(.horizontal, 24)
    }

    private func triggerHaptic() {
        #if os(iOS)
        let generator = UIImpactFeedbackGenerator(style: .light)
        generator.prepare()
        generator.impactOccurred()
        #endif
    }
}

struct NavigationTab {
    let icon: String
    let title: String
    let tag: Int
}


// MARK: - Gallery View
struct GalleryView: View {
    @ObservedObject var manager: Manager
    
    @State private var selectedArtifactIndex = 0
    
    private func updateSelectedIndexIfNeeded() {
        if selectedArtifactIndex >= artifacts.count && !artifacts.isEmpty {
            selectedArtifactIndex = 0
        }
    }
    
    private var artifacts: [Artifact] {
        var generatedArtifacts: [Artifact] = []
        
        if let sleepArt = manager.sleepArtData {
            generatedArtifacts.append(Artifact(
                name: sleepArt.title,
                description: sleepArt.description,
                imageURL: sleepArt.imageURL
            ))
        }
        
        if let movementArt = manager.movementArtData {
            generatedArtifacts.append(Artifact(
                name: movementArt.title,
                description: movementArt.description,
                imageURL: movementArt.imageURL
            ))
        }
        
        if let stressArt = manager.stressArtData {
            generatedArtifacts.append(Artifact(
                name: stressArt.title,
                description: stressArt.description,
                imageURL: stressArt.imageURL
            ))
        }
        
        // Fallback artifacts if no generated artwork is available
        if generatedArtifacts.isEmpty {
            return [
                Artifact(name: "Sleep Artifact", description: "Your personalized sleep visualization", imageName: "museum"),
                Artifact(name: "Movement Artifact", description: "Your activity pattern artwork", imageName: "museum"),
                Artifact(name: "Stress Artifact", description: "Your stress and recovery visualization", imageName: "museum")
            ]
        }
        
        return generatedArtifacts
    }
    
    private var selectedArtifact: Artifact {
        if artifacts.isEmpty {
            return Artifact(name: "No Artifacts", description: "Generate health data to create artifacts", imageName: "museum")
        } else if selectedArtifactIndex < artifacts.count {
            return artifacts[selectedArtifactIndex]
        } else {
            return artifacts[0] // Fallback to first artifact
        }
    }
    
    var body: some View {
        let _ = updateSelectedIndexIfNeeded() // Ensure index is valid
        
        ZStack {
            // Parallax museum background
            ParallaxBackgroundView(selectedIndex: selectedArtifactIndex)
            
            // Dark overlay for better text visibility
            LinearGradient(
                gradient: Gradient(colors: [Color.black.opacity(0.3), Color.clear, Color.black.opacity(0.3)]),
                startPoint: .top,
                endPoint: .bottom
            )
            .ignoresSafeArea()
            
            VStack(spacing: 0) {
                // Header
                HStack {
            Text("Gallery")
                        .font(.system(size: 32, weight: .bold, design: .rounded))
                .foregroundColor(.white)
                        .shadow(color: .black.opacity(0.5), radius: 8, x: 0, y: 4)
                    
                    Spacer()
                    
                    if manager.isLoading {
                        HStack {
                            ProgressView()
                                .progressViewStyle(CircularProgressViewStyle(tint: .white))
                                .scaleEffect(0.8)
                            Text("Generating...")
                                .font(.system(size: 14, weight: .medium, design: .rounded))
                                .foregroundColor(.white.opacity(0.8))
                        }
                        .padding(.horizontal, 12)
                        .padding(.vertical, 6)
                        .background(
                            Capsule()
                                .fill(Color.black.opacity(0.4))
                        )
                    } else {
                    Text("\(selectedArtifactIndex + 1) of \(artifacts.count)")
                        .font(.system(size: 16, weight: .medium, design: .rounded))
                        .foregroundColor(.white.opacity(0.8))
                        .padding(.horizontal, 12)
                        .padding(.vertical, 6)
                        .background(
                            Capsule()
                                .fill(Color.black.opacity(0.4))
                        )
                    }
                }
                .padding(.horizontal, 24)
                .padding(.top, 60)
                
                // Artifact info panel (moved above)
                VStack(spacing: 16) {
                    Text(selectedArtifact.name)
                        .font(.system(size: 24, weight: .bold, design: .rounded))
                        .foregroundColor(.white)
                        .multilineTextAlignment(.center)
                        .shadow(color: .black.opacity(0.5), radius: 4, x: 0, y: 2)
                        .animation(.easeInOut(duration: 0.3), value: selectedArtifact.name)
                    
                    Text(selectedArtifact.description)
                        .font(.system(size: 16, weight: .medium, design: .rounded))
                        .foregroundColor(.white.opacity(0.9))
                        .multilineTextAlignment(.center)
                        .lineLimit(3)
                        .shadow(color: .black.opacity(0.5), radius: 4, x: 0, y: 2)
                        .animation(.easeInOut(duration: 0.3), value: selectedArtifact.description)
                }
                .padding(.horizontal, 32)
                .padding(.top, 20)
                
                Spacer()
                
                // Main artifact display
                TabView(selection: $selectedArtifactIndex) {
                    ForEach(Array(artifacts.enumerated()), id: \.offset) { index, artifact in
                        ArtifactPedestalView(artifact: artifact)
                            .tag(index)
                    }
                }
                .tabViewStyle(PageTabViewStyle(indexDisplayMode: .never))
                .frame(maxHeight: .infinity)
                .animation(.interactiveSpring(response: 0.6, dampingFraction: 0.8, blendDuration: 0.3), value: selectedArtifactIndex)
                
                Spacer()
            }
        }
    }
}

struct Artifact: Identifiable {
    let id = UUID()
    let name: String
    let description: String
    let imageName: String?
    let imageURL: String?
    
    init(name: String, description: String, imageName: String? = nil, imageURL: String? = nil) {
        self.name = name
        self.description = description
        self.imageName = imageName
        self.imageURL = imageURL
    }
}

struct ArtifactCard: View {
    let artifact: Artifact
    
    var body: some View {
        VStack {
            Group {
                if let imageName = artifact.imageName {
                    Image(imageName)
                .resizable()
                .scaledToFit()
                } else if let imageURL = artifact.imageURL, let url = URL(string: imageURL) {
                    AsyncImage(url: url) { image in
                        image
                            .resizable()
                            .scaledToFit()
                    } placeholder: {
                        RoundedRectangle(cornerRadius: 10)
                            .fill(Color.gray.opacity(0.3))
                            .overlay(
                                ProgressView()
                                    .scaleEffect(1.2)
                            )
                    }
                } else {
                    RoundedRectangle(cornerRadius: 10)
                        .fill(Color.gray.opacity(0.3))
                        .overlay(
                            Image(systemName: "photo")
                                .font(.system(size: 30))
                                .foregroundColor(.white.opacity(0.6))
                        )
                }
            }
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

struct ParallaxBackgroundView: View {
    let selectedIndex: Int
    
    var body: some View {
        GeometryReader { geometry in
            let screenWidth = geometry.size.width
            let parallaxOffset = CGFloat(selectedIndex) * screenWidth * 0.3
            
            ZStack {
                // Base museum image
                Image("museum")
                    .resizable()
                    .scaledToFill()
                    .frame(width: screenWidth * 1.6, height: geometry.size.height)
                    .offset(x: -parallaxOffset * 0.2)
                    .clipped()
                
                // Secondary layer for depth
                Image("museum")
                    .resizable()
                    .scaledToFill()
                    .frame(width: screenWidth * 1.4, height: geometry.size.height)
                    .offset(x: -parallaxOffset * 0.4)
                    .opacity(0.6)
                    .blur(radius: 2)
                    .clipped()
                
                // Foreground elements
                Image("museum")
                    .resizable()
                    .scaledToFill()
                    .frame(width: screenWidth * 1.2, height: geometry.size.height)
                    .offset(x: -parallaxOffset * 0.6)
                    .opacity(0.8)
                    .clipped()
            }
            .ignoresSafeArea()
        }
        .animation(.interactiveSpring(response: 0.6, dampingFraction: 0.8, blendDuration: 0.3), value: selectedIndex)
    }
}

struct ArtifactPedestalView: View {
    let artifact: Artifact
    
    var body: some View {
        ZStack(alignment: .bottom) {
            // Pillar at bottom of screen
            Image("pillar")
                .resizable()
                .scaledToFit()
                .frame(width: 180, height: 300) // 1.5x larger (120*1.5=180, 200*1.5=300)
                .shadow(color: .black.opacity(0.3), radius: 15, x: 0, y: 8)
                .offset(y: 50) // Push it down to bottom half
            
            // Artifact floating above pillar
            ZStack {
                // Glow effect behind artifact
                Circle()
                    .fill(
                        RadialGradient(
                            gradient: Gradient(colors: [
                                Color.white.opacity(0.1),
                                Color.clear
                            ]),
                            center: .center,
                            startRadius: 0,
                            endRadius: 120
                        )
                    )
                    .frame(width: 240, height: 240)
                    .blur(radius: 20)
                
                // Main artifact image
                Group {
                    if let imageURL = artifact.imageURL, let url = URL(string: imageURL) {
                        AsyncImage(url: url) { image in
                            image
                    .resizable()
                    .scaledToFit()
                        } placeholder: {
                            RoundedRectangle(cornerRadius: 16)
                                .fill(Color.gray.opacity(0.3))
                                .overlay(
                                    ProgressView()
                                        .scaleEffect(1.5)
                                )
                        }
                    } else if let imageName = artifact.imageName {
                        Image(imageName)
                            .resizable()
                            .scaledToFit()
                    } else {
                        RoundedRectangle(cornerRadius: 16)
                            .fill(Color.gray.opacity(0.3))
                            .overlay(
                                Image(systemName: "photo")
                                    .font(.system(size: 40))
                                    .foregroundColor(.white.opacity(0.6))
                            )
                    }
                }
                    .frame(width: 200, height: 200)
                    .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
                    .overlay(
                        RoundedRectangle(cornerRadius: 16, style: .continuous)
                            .stroke(
                                LinearGradient(
                                    gradient: Gradient(colors: [
                                        Color.white.opacity(0.3),
                                        Color.white.opacity(0.1)
                                    ]),
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                ),
                                lineWidth: 2
                            )
                    )
                    .shadow(color: .black.opacity(0.4), radius: 30, x: 0, y: 15)
            }
            .offset(y: -150) // Position artifact above the pillar
        }
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
    
    private var unlockedAchievements: Int {
        achievements.filter { $0.isUnlocked }.count
    }
    
    var body: some View {
        ZStack {
            // Background
            AppBackground()
            
            // Dark overlay
            Color.black.opacity(0.3)
                .ignoresSafeArea()
            
            ScrollView {
                VStack(spacing: 24) {
                    // Hero Header
                    HeroHeaderSection(
                        title: "Profile",
                        subtitle: "Museum Curator",
                        caption: "Level \(userLevel) • \(unlockedAchievements) achievements"
                    )
                    
                    // Profile Card
                    GlassCard {
                        VStack(spacing: 20) {
                            // Profile Avatar
                            ZStack {
                                Circle()
                                    .fill(
                                        LinearGradient(
                                            gradient: Gradient(colors: [
                                                HeartifactsTheme.accent,
                                                HeartifactsTheme.accent.opacity(0.7)
                                            ]),
                                            startPoint: .topLeading,
                                            endPoint: .bottomTrailing
                                        )
                                    )
                                    .frame(width: 80, height: 80)
                                
                                Image(systemName: "person.crop.circle.fill")
                                    .font(.system(size: 40))
                                    .foregroundColor(.white)
                            }
                            
                            VStack(spacing: 8) {
                                Text(userName)
                                    .font(.system(size: 24, weight: .bold, design: .rounded))
                                    .foregroundColor(.white)
                                
                                Text("Level \(userLevel)")
                                    .font(.system(size: 16, weight: .medium, design: .rounded))
                                    .foregroundColor(HeartifactsTheme.accent)
                            }
                        }
                        .padding(24)
                    }
                    
                    // Stats Section
                    VStack(spacing: 16) {
                        HStack(spacing: 16) {
                            StatCard(
                                title: "\(totalArtifacts)",
                                subtitle: "Artifacts",
                                color: HeartifactsTheme.accent
                            )
                            
                            StatCard(
                                title: "23",
                                subtitle: "Days Active",
                                color: .green
                            )
                            
                            StatCard(
                                title: "\(unlockedAchievements)",
                                subtitle: "Achievements",
                                color: .orange
                            )
                        }
                    }
                    .padding(.horizontal, 20)
                    
                    // Achievements Section
                    VStack(alignment: .leading, spacing: 16) {
                        HStack {
                            Text("Achievements")
                                .font(.system(size: 20, weight: .semibold, design: .rounded))
                                .foregroundColor(.white)
                            
                            Spacer()
                            
                            Text("\(unlockedAchievements)/\(achievements.count)")
                                .font(.system(size: 14, weight: .medium, design: .rounded))
                                .foregroundColor(HeartifactsTheme.accent)
                        }
                        .padding(.horizontal, 20)
                        
                        VStack(spacing: 12) {
                            ForEach(achievements) { achievement in
                                AchievementRow(achievement: achievement)
                            }
                        }
                        .padding(.horizontal, 20)
                    }
                    
                    Spacer(minLength: 100)
                }
                .padding(.top, 60)
            }
        }
    }
}

struct Achievement: Identifiable {
    let id = UUID()
    let title: String
    let description: String
    let isUnlocked: Bool
}

struct StatCard: View {
    let title: String
    let subtitle: String
    let color: Color
    
    var body: some View {
        GlassCard {
            VStack(spacing: 8) {
                Text(title)
                    .font(.system(size: 24, weight: .bold, design: .rounded))
                    .foregroundColor(color)
                
                Text(subtitle)
                    .font(.system(size: 12, weight: .medium, design: .rounded))
                    .foregroundColor(.white.opacity(0.8))
            }
            .padding(16)
        }
    }
}

struct AchievementRow: View {
    let achievement: Achievement
    
    var body: some View {
        GlassCard {
            HStack(spacing: 16) {
                ZStack {
                    Circle()
                        .fill(
                            achievement.isUnlocked ?
                            LinearGradient(
                                gradient: Gradient(colors: [Color.yellow, Color.orange]),
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            ) :
                            LinearGradient(
                                gradient: Gradient(colors: [Color.white.opacity(0.1), Color.white.opacity(0.05)]),
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .frame(width: 32, height: 32)
                    
                    Image(systemName: achievement.isUnlocked ? "star.fill" : "star")
                        .font(.system(size: 14, weight: .medium))
                        .foregroundColor(achievement.isUnlocked ? .white : .white.opacity(0.5))
                }
                
                VStack(alignment: .leading, spacing: 4) {
                    Text(achievement.title)
                        .font(.system(size: 16, weight: .semibold, design: .rounded))
                        .foregroundColor(achievement.isUnlocked ? .white : .white.opacity(0.6))
                    
                    Text(achievement.description)
                        .font(.system(size: 14, weight: .medium, design: .rounded))
                        .foregroundColor(.white.opacity(0.7))
                }
                
                Spacer()
                
                if achievement.isUnlocked {
                    Image(systemName: "checkmark.circle.fill")
                        .font(.system(size: 16))
                        .foregroundColor(.green)
                }
            }
            .padding(16)
        }
    }
}


// MARK: - AI Curator Note

