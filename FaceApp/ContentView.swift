//
//  ContentView.swift
//  FaceApp
//
//  Created by Римма Давлетова on 25/10/2025.
//

import SwiftUI

struct ContentView: View {
    @State private var totalStorageUsed: String = "0 MB"
    @State private var showCamera = false
    @State private var showGallery = false
    
    var body: some View {
        NavigationView {
            VStack(spacing: 30) {
                Text("🎥 Video Diary")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                
                Button(action: {
                    showCamera = true
                }) {
                    Label("Record New Video", systemImage: "video.fill")
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.blue)
                        .foregroundColor(.white)
                        .cornerRadius(12)
                }
                .sheet(isPresented: $showCamera, onDismiss: updateStorageUsed) {
                    CameraView()
                }
                
                Button(action: {
                    showGallery = true
                }) {
                    Label("View Gallery", systemImage: "photo.on.rectangle")
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.green)
                        .foregroundColor(.white)
                        .cornerRadius(12)
                }
                .sheet(isPresented: $showGallery, onDismiss: updateStorageUsed) {
                    GalleryView()
                }
                
                VStack {
                    Text("Storage Used:")
                        .font(.headline)
                    Text(totalStorageUsed)
                        .font(.title3)
                }
                .onAppear(perform: updateStorageUsed)
                
                Spacer()
            }
            .padding()
            .navigationTitle("My Diary")
        }
    }
    
    private func updateStorageUsed() {
        totalStorageUsed = VideoManager.shared.calculateStorageUsed()
    }
}



#Preview {
    ContentView()
}
