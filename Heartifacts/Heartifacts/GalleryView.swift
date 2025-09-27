//
//  GalleryView.swift
//  Heartifacts
//
//  Created by Shaya Farahmand on 9/27/25.
//

import SwiftUI

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
