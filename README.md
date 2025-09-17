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
