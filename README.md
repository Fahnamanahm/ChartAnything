# ChartAnything

A powerful iOS health tracking app with highly customizable data visualization. Track any health metric with beautiful, interactive charts and automatic GKI (Glucose-Ketone Index) calculation.

[![iOS](https://img.shields.io/badge/iOS-17.0+-blue)](https://img.shields.io/badge/iOS-17.0+-blue)
[![Swift](https://img.shields.io/badge/Swift-5.9-orange)](https://img.shields.io/badge/Swift-5.9-orange)
[![SwiftUI](https://img.shields.io/badge/SwiftUI-%E2%9C%93-green)](https://img.shields.io/badge/SwiftUI-%E2%9C%93-green)

**Current Version: 1.0.0** • Released: December 5, 2025

## ✨ Features

### Core Functionality
* 📊 **Unlimited Custom Measurements** - Track any health metric (glucose, ketones, weight, sleep, steps, etc.)
* 📈 **Highly Customizable Charts** - Adjust colors, line widths, point sizes, and toggle visibility
* 🔄 **Auto-Calculate GKI** - Automatic Glucose-Ketone Index calculation with color-coded zones
* 📅 **Flexible Date Filtering** - Preset ranges (7/30/90 days) or custom date selection
* 🎯 **Tap-to-View Values** - Interactive charts show exact values on tap/drag

### Advanced Features
* 🔀 **Merge Charts** - Compare different metrics with independent dual Y-axes
* 💾 **Data Export/Import** - CSV format with clipboard support
* 🎨 **Chart Customization** - Per-chart color schemes, line styles, and point sizes
* 📱 **Local Storage** - All data stored securely on-device with SwiftData
* 🗑️ **Data Management** - Delete all data with double-confirmation protection

### GKI Tracking
* **Therapeutic Ketosis**: 0.5 - 1.0 (Green)
* **High Ketosis**: 1.01 - 3.0 (Yellow)
* **Moderate Ketosis**: 3.01 - 6.0 (Orange)
* **Low Ketosis**: 6.01 - 9.0 (Red)

## 🖼️ Screenshots

*Screenshots coming soon - currently in active development*

## 🛠️ Tech Stack

* **Language**: Swift 5.9
* **UI Framework**: SwiftUI
* **Data Persistence**: SwiftData
* **Charts**: Swift Charts Framework
* **Minimum iOS**: 17.0+

## 📦 Installation

### Requirements
* Xcode 15.0 or later
* iOS 17.0+ device or simulator
* macOS Sonoma or later

### Setup

1. Clone the repository:
```bash
   git clone https://github.com/Fahnamanahm/ChartAnything.git
```

2. Open the project:
```bash
   cd ChartAnything
   open ChartAnything.xcodeproj
```

3. Build and run:
   * Select your target device/simulator
   * Press `Cmd + R` or click the Play button

### First Launch

The app starts with no data. You can:
* Create custom measurement types
* Add measurements manually
* Import data via CSV (clipboard or file)

## 📱 Usage

### Adding Measurements

1. Tap the **+** button in the top right
2. Select **"Add Measurement"**
3. Choose measurement type, enter value, and add notes
4. Data automatically appears on charts

### Creating Custom Measurement Types

1. Tap **+** → **"New Measurement Type"**
2. Enter name, unit, choose emoji and color
3. Start tracking immediately

### Customizing Charts

1. Tap any chart to customize
2. Adjust line colors, widths, point sizes
3. Toggle line/point visibility
4. Changes save automatically

### Merging Charts

1. Tap **+** → **"Merge Charts"**
2. Select exactly 2 measurement types
3. View with independent Y-axes (left and right)
4. Each metric maintains its own scale

### Importing Data

**From Clipboard:**
1. Copy CSV data to clipboard
2. Tap **+** → **"Import Data"** → **"Import from Clipboard"**
3. Review import results

**CSV Format:**
```csv
Date,Time,Measurement Type,Value,Unit,Notes
2025-12-01,08:00:00,Glucose,95,mg/dL,Fasting
2025-12-01,08:30:00,Ketones,1.2,mmol/L,
```

### Exporting Data

1. Tap **+** → **"Export Data"**
2. CSV data copied to clipboard
3. Paste into Notes, Mail, or any text app

## 📝 Changelog

### Version 1.0.0 (December 5, 2025)
**Initial Release**
* ✅ Custom measurement types with emoji and color selection
* ✅ Interactive charts with tap-to-view functionality
* ✅ Automatic GKI calculation with color-coded zones
* ✅ Chart customization (colors, line widths, point sizes, visibility toggles)
* ✅ Merged charts with independent dual Y-axes
* ✅ Date range filtering (7/30/90 days or custom dates)
* ✅ CSV import/export with clipboard support
* ✅ SwiftData persistence for all user data
* ✅ Data management with delete confirmation
* ✅ Chart date filtering in merged views
* ✅ GKI merge capability
* ✅ Tab-based navigation (Charts, Add Data, Settings)
* ✅ Chart header buttons for quick access

## 🗺️ Roadmap

### Planned Features
* 📋 Settings tab completion
* 📋 Chart reordering functionality
* 📋 Horizontally scrollable charts for long time periods
* 📋 Chart overlays (compare different time periods side-by-side)
* 📋 Customizable GKI zone colors
* 📋 Statistics and analytics view
* 📋 Chart export as images
* 📋 Apple Health integration
* 📋 Custom emoji as chart data points

### Known Issues
* ⚠️ Right Y-axis extends slightly below X-axis in merged charts (cosmetic Swift Charts limitation)

## 🤝 Contributing

Contributions are welcome! This is a personal health tracking project, but feel free to:
* Report bugs via Issues
* Suggest features
* Submit pull requests

## 📄 License

This project is available for personal use. Please contact the author for commercial use inquiries.

## 👤 Author

**John Pologruto**
* GitHub: [@Fahnamanahm](https://github.com/Fahnamanahm)

## 📊 Project Stats

* **Development Time**: 20 hours 45 minutes (across 11 sessions)
* **Lines of Code**: ~3,000+
* **Files**: 16 Swift files
* **Commits**: 18+ semantic commits
* **Started**: December 2, 2025
* **Version 1.0.0**: December 5, 2025
* **Development Period**: December 2-10, 2025

## 🙏 Acknowledgments

Built with guidance from Claude (Anthropic) as a learning project for iOS development.

Special thanks to systematic debugging practices and version control, which saved multiple hours during development!

---

**Note**: ChartAnything is designed for personal health tracking. Always consult healthcare professionals for medical decisions.
