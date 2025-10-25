//
//  GalleryView.swift
//  FaceApp
//
//  Created by Римма Давлетова on 25/10/2025.
//

import Foundation
import SwiftUI
import AVKit

struct VideoItem: Identifiable {
    let id = UUID()
    let url: URL
}


struct GalleryView: View {
    @Environment(\.dismiss) var dismiss
    @State private var videos: [URL] = []
    @State private var selectedVideo: VideoItem? = nil
    
    var body: some View {
        NavigationView {
            List {
                ForEach(videos, id: \.self) { video in
                    Button(action: {
                        selectedVideo = VideoItem(url: video)
                    }) {
                        HStack {
                            ThumbnailView(videoURL: video)
                                .frame(width: 80, height: 80)
                                .cornerRadius(8)
                                .clipped()
                            
                            VStack(alignment: .leading) {
                                Text(video.lastPathComponent)
                                    .font(.headline)
                                if let date = try? video.resourceValues(forKeys: [.creationDateKey]).creationDate {
                                    Text(date, style: .date)
                                        .font(.caption)
                                        .foregroundColor(.gray)
                                }
                            }
                        }
                    }
                }
                .onDelete(perform: deleteVideo)
            }
            .navigationTitle("Gallery")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Close") { dismiss() }
                }
            }
            .sheet(item: $selectedVideo) { item in
                VideoPlayerView(videoURL: item.url)
            }
            .onAppear {
                videos = VideoManager.shared.listVideos()
            }
        }
    }
    
    private func deleteVideo(at offsets: IndexSet) {
        offsets.forEach { index in
            let url = videos[index]
            VideoManager.shared.deleteVideo(url: url)
        }
        videos.remove(atOffsets: offsets)
    }
}

import UIKit
import AVFoundation

struct ThumbnailView: View {
    let videoURL: URL
    @State private var image: UIImage? = nil
    
    var body: some View {
        Group {
            if let img = image {
                Image(uiImage: img)
                    .resizable()
                    .scaledToFill()
            } else {
                Rectangle()
                    .fill(Color.gray)
                    .onAppear { generateThumbnail() }
            }
        }
    }
    
    private func generateThumbnail() {
        DispatchQueue.global().async {
            let asset = AVAsset(url: videoURL)
            let generator = AVAssetImageGenerator(asset: asset)
            generator.appliesPreferredTrackTransform = true
            if let cgImage = try? generator.copyCGImage(at: .zero, actualTime: nil) {
                let uiImage = UIImage(cgImage: cgImage)
                DispatchQueue.main.async {
                    self.image = uiImage
                }
            }
        }
    }
}

import SwiftUI
import AVKit

struct VideoPlayerView: View {
    let videoURL: URL
    
    var body: some View {
        NavigationView {
            VideoPlayer(player: AVPlayer(url: videoURL))
                .edgesIgnoringSafeArea(.all)
                .navigationTitle("Playback")
                .navigationBarTitleDisplayMode(.inline)
                .toolbar {
                    ToolbarItem(placement: .cancellationAction) {
                        Button("Close") { dismiss() }
                    }
                }
        }
    }
    
    @Environment(\.dismiss) private var dismiss
}

