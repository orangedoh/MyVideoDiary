//
//  CameraView.swift
//  FaceApp
//
//  Created by Римма Давлетова on 25/10/2025.
//

import Foundation
import SwiftUI
import AVFoundation
import UIKit

struct CameraView: View {
    @Environment(\.dismiss) var dismiss
    
    @StateObject private var camera = CameraModel()
    @State private var countdown = 3
    @State private var isCountingDown = false
    
    var body: some View {
        ZStack {
            // Camera preview layer
            CameraPreview(session: camera.session)
                .ignoresSafeArea()
            
            // Countdown overlay
            if isCountingDown {
                Text("\(countdown)")
                    .font(.system(size: 80, weight: .bold))
                    .foregroundColor(.white)
                    .shadow(radius: 10)
            }
            
            // UI controls
            VStack {
                HStack {
                    Button(action: { dismiss() }) {
                        Image(systemName: "xmark.circle.fill")
                            .font(.largeTitle)
                            .foregroundColor(.white)
                            .padding()
                    }
                    Spacer()
                }
                Spacer()
                
                if !camera.isRecording {
                    Button(action: startCountdown) {
                        Circle()
                            .fill(Color.red)
                            .frame(width: 80, height: 80)
                            .overlay(
                                Image(systemName: "video.fill")
                                    .font(.title)
                                    .foregroundColor(.white)
                            )
                    }
                    .padding(.bottom, 40)
                } else {
                    Text("Recording...")
                        .font(.title)
                        .bold()
                        .foregroundColor(.red)
                        .padding(.bottom, 40)
                }
            }
        }
        .onAppear {
            camera.checkPermissions()
            camera.configure()
        }
        .onDisappear {
            camera.stopSession()
        }
    }
    
    private func startCountdown() {
        guard !camera.isRecording else { return }
        isCountingDown = true
        countdown = 3
        Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { timer in
            countdown -= 1
            if countdown == 0 {
                timer.invalidate()
                isCountingDown = false
                camera.startRecording()
                
                // Stop after 5 seconds
                DispatchQueue.main.asyncAfter(deadline: .now() + 5) {
                    camera.stopRecording()
                }
            }
        }
    }
}

class CameraModel: NSObject, ObservableObject, AVCaptureFileOutputRecordingDelegate {
    @Published var isRecording = false
    
    let session = AVCaptureSession()
    private let output = AVCaptureMovieFileOutput()
    private let queue = DispatchQueue(label: "camera.queue")
    
    func checkPermissions() {
        switch AVCaptureDevice.authorizationStatus(for: .video) {
        case .authorized:
            break
        case .notDetermined:
            AVCaptureDevice.requestAccess(for: .video) { granted in
                if !granted {
                    print("Camera access denied")
                }
            }
        default:
            print("Camera access denied or restricted")
        }
    }
    
    func configure() {
        queue.async {
            self.session.beginConfiguration()
            self.session.sessionPreset = .high
            
            // Add video input
            guard let device = AVCaptureDevice.default(.builtInWideAngleCamera, for: .video, position: .front),
                  let input = try? AVCaptureDeviceInput(device: device),
                  self.session.canAddInput(input) else {
                print("Error: Cannot add video input")
                return
            }
            self.session.addInput(input)
            
            // Add audio input
            if let mic = AVCaptureDevice.default(for: .audio),
               let micInput = try? AVCaptureDeviceInput(device: mic),
               self.session.canAddInput(micInput) {
                self.session.addInput(micInput)
            }
            
            // Add movie output
            if self.session.canAddOutput(self.output) {
                self.session.addOutput(self.output)
            }
            
            self.session.commitConfiguration()
            self.session.startRunning()
        }
    }
    
    func startRecording() {
        guard !isRecording else { return }
        isRecording = true
        
        let tempURL = URL(fileURLWithPath: NSTemporaryDirectory()).appendingPathComponent("temp.mov")
        try? FileManager.default.removeItem(at: tempURL)
        output.startRecording(to: tempURL, recordingDelegate: self)
    }
    
    func stopRecording() {
        guard isRecording else { return }
        output.stopRecording()
        isRecording = false
    }
    
    func stopSession() {
        if session.isRunning {
            session.stopRunning()
        }
    }
    
    // MARK: Delegate
    func fileOutput(_ output: AVCaptureFileOutput, didFinishRecordingTo outputFileURL: URL, from connections: [AVCaptureConnection], error: Error?) {
        if let error = error {
            print("Recording error:", error.localizedDescription)
            return
        }
        if let savedURL = VideoManager.shared.saveVideo(tempURL: outputFileURL) {
            print("Saved video at:", savedURL)
        }
    }
}

struct CameraPreview: UIViewRepresentable {
    class VideoPreviewView: UIView {
        override class var layerClass: AnyClass {
            AVCaptureVideoPreviewLayer.self
        }
        
        var videoPreviewLayer: AVCaptureVideoPreviewLayer {
            return layer as! AVCaptureVideoPreviewLayer
        }
    }
    
    let session: AVCaptureSession
    
    func makeUIView(context: Context) -> VideoPreviewView {
        let view = VideoPreviewView()
        view.videoPreviewLayer.session = session
        view.videoPreviewLayer.videoGravity = .resizeAspectFill
        return view
    }
    
    func updateUIView(_ uiView: VideoPreviewView, context: Context) {}
}

