//
//  VideoManager.swift
//  FaceApp
//
//  Created by Римма Давлетова on 25/10/2025.
//

import Foundation
import AVFoundation
import SwiftUI

class VideoManager {
    static let shared = VideoManager()
    private init() {}
    
    private let fileManager = FileManager.default
    
    func videosDirectory() -> URL {
        let docs = fileManager.urls(for: .documentDirectory, in: .userDomainMask)[0]
        return docs.appendingPathComponent("Videos", isDirectory: true)
    }
    
    func ensureDirectoryExists() {
        let dir = videosDirectory()
        if !fileManager.fileExists(atPath: dir.path) {
            try? fileManager.createDirectory(at: dir, withIntermediateDirectories: true)
        }
    }
    
    func saveVideo(tempURL: URL) -> URL? {
        ensureDirectoryExists()
        let destination = videosDirectory().appendingPathComponent("video-\(Date().timeIntervalSince1970).mov")
        do {
            try fileManager.copyItem(at: tempURL, to: destination)
            return destination
        } catch {
            print("Save error:", error)
            return nil
        }
    }
    
    func listVideos() -> [URL] {
        ensureDirectoryExists()
        let contents = try? fileManager.contentsOfDirectory(at: videosDirectory(), includingPropertiesForKeys: nil)
        return contents?.sorted(by: { $0.lastPathComponent > $1.lastPathComponent }) ?? []
    }
    
    func deleteVideo(url: URL) {
        try? fileManager.removeItem(at: url)
    }
    
    func calculateStorageUsed() -> String {
        ensureDirectoryExists()
        let files = listVideos()
        let totalBytes = files.reduce(0) { $0 + (try? $1.resourceValues(forKeys: [.fileSizeKey]).fileSize ?? 0)! }
        let mb = Double(totalBytes) / (1024 * 1024)
        return String(format: "%.2f MB", mb)
    }
}

