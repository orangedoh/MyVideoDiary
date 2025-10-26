## Video Diary App

A simple mobile **video diary** built with **SwiftUI** and **AVFoundation**.
This app allows users to record short front-camera videos, view them in a gallery, play them back, and track total storage used.

---

### Features

**Record Video**

* 5 second front-camera recording
* Countdown timer before recording starts
* Automatically saves with timestamped filenames

**Video Gallery**

* Displays list of all saved videos
* Shows thumbnail + timestamp for each clip
* Tap to play video
* Swipe to delete

**Storage Tracking**

* Displays total storage used by all recorded videos

---

### Project Structure

```
VideoDiary/
├── ContentView.swift        // Main screen, storage display, navigation
├── CameraView.swift         // Camera UI + recording logic
├── GalleryView.swift        // Video gallery with thumbnails & playback
├── VideoManager.swift       // Handles file saving, listing, deleting
├── VideoPlayerView.swift    // Playback screen
└── FaceAppApp.swift      // App entry point
```

---

### Setup Instructions

1. **Clone** the project:

   ```bash
   git clone https://github.com/orangedoh/MyVideoDiary.git
   ```

2. **Open in Xcode**

   * Double-click `FaceApp.xcodeproj`
   * Make sure the **target platform is iOS**, not Multiplatform

3. **Connect your iPhone**

   * Go to Xcode toolbar → device dropdown → select your iPhone
   * You may need to **trust your developer certificate** on the device:

     * Settings → General → VPN & Device Management → Trust 

4. **Run the app**

   * Press play (or `Cmd + R`) to build and run on your iPhone.

5. **Permissions**

   * Allow camera and microphone access when prompted.

---

### Known Limitations

* Camera doesn’t work on the Xcode Simulator (requires physical device).
---


### Author

**Name:** Rimma Davletova
**Date:** October 2025
**Framework:** SwiftUI (iOS)
**Contact:** rdavletova235@gmail.com

---
