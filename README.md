**🎫 DRT Ticket Scanner**

DRT Ticket Scanner is an iOS application for scanning and validating tickets.
It leverages CocoaPods for dependency management and certificates for secure API communication.
---

**✨ Features**

📷 QR / Barcode ticket scanning

⚡ Real-time ticket validation

🔐 Secure API communication using certificates

📶 Online & Offline ticket scanning

🧩 Clean and intuitive UI

---

**📂 Project Structure**
<pre>
DRTScanner/
│── DRTScanner.xcodeproj     # Xcode project
│── Podfile                  # CocoaPods dependencies
│── Podfile.lock
│── certificate/             # Certificates for secure communication
│── Sources/                 # App source code
│   ├── Views/               # UI components
│   ├── Models/              # Data models
│   ├── ViewModels/          # Business logic
│── Resources/               # Assets, Images, Localizations
│── README.md                # Documentation
  
</pre>

---

**⚙️ Setup & Installation**

**1. Clone the Repository**
git clone https://github.com/your-username/drt-scanner.git
cd drt-scanner

---
**2. Install Dependencies**
Make sure **CocoaPods** is installed:
```
sudo gem install cocoapods
```
Install project pods:
```
pod install
```
✅ Always open the project using the .xcworkspace file.

---

**3. Certificates**
Certificates for secure communication are located in the certificate folder.
- Import them into **Keychain Access (macOS)**
- Or configure them directly inside **Xcode** as required
---
**🚀 Running the App**
1. Open DRTScanner.xcworkspace in Xcode
2. Select a target device or simulator
3. Press **Cmd + R** to run
---
**📦 Dependencies**
Managed via CocoaPods:
- SDWebImage (5.21.2) → Load images from the web
- SDWebImageSVGCoder → SVG image support
- SDWebImageSwiftUI → SwiftUI integration for image loading
---
**🔐 Security**
- **⚠️ Do not commit production certificates to public repositories**
- **Use environment-specific configurations for development, staging, and production**
---
**🛠️ Requirements**
- iOS **16.0+**
- Xcode **16+**
- Swift **5.9+**

--- 
**📤 How to Create & Upload a Build**

This section explains in simple, non-technical steps how to prepare and upload the app to **TestFlight** and the **App Store.**

---

**✅ Step 1: Open the Project**

1. Open Xcode

2. Load the file: DRTScanner.xcworkspace

---

**✅ Step 2: Select the Right Team**

1. In Xcode, click on the project name (DRTScanner) in the left sidebar

2. Go to Signing & Capabilities

3. Choose the correct **Apple Developer Team**

---

**✅ Step 3: Create a Build**

1. Connect your iPhone (or just use “Any iOS Device” option)

2. From the top menu, select:
<pre>

Product → Archive
</pre>

3. Wait until Xcode finishes building.

   - When complete, the Organizer window will open.
   
---

**✅ Step 4: Upload to App Store Connect**

1. In the Organizer window, click Distribute App

2. Choose [App Store Connect](https://appstoreconnect.apple.com/login).

3. Select Upload

4. Keep all settings as default and continue

5. Xcode will upload the build to App Store Connect

---

**✅ Step 5: TestFlight (Internal Testing)**

1. Log in to App Store Connect

2. Go to My Apps → DRT Ticket Scanner → TestFlight

3. You will see the uploaded build

4. Add testers by entering their Apple IDs (emails)

5. They will get an invitation email to install via TestFlight app

---

**✅ Step 6: Submit to the App Store**

1. In App Store Connect, go to My Apps → DRT Ticket Scanner → App Store → Prepare for Submission

2. Fill in required details:

    - App Name

     - Description

     - Screenshots

     - App Privacy Policy URL

     - App Category

3. Select the uploaded build

4. Click Submit for Review

---

**ℹ️ Notes**

- Review Time: Apple usually reviews apps in 24–48 hours (can be longer)

- If rejected, Apple provides reasons → fix issues in Xcode → upload again

----
