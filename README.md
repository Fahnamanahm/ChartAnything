# ChartAnything

A powerful iOS health tracking app with highly customizable data visualization. Track any health metric with beautiful, interactive charts and automatic GKI (Glucose-Ketone Index) calculation.

[![iOS](https://img.shields.io/badge/iOS-17.0+-blue)](https://img.shields.io/badge/iOS-17.0+-blue)
[![Swift](https://img.shields.io/badge/Swift-5.9-orange)](https://img.shields.io/badge/Swift-5.9-orange)
[![SwiftUI](https://img.shields.io/badge/SwiftUI-%E2%9C%93-green)](https://img.shields.io/badge/SwiftUI-%E2%9C%93-green)

**Current Version: 1.0.0** • Released: December 11, 2025

## ✨ Features

### Core Functionality
* 📊 **Unlimited Custom Measurements** - Track any health metric (glucose, ketones, weight, sleep, steps, etc.)
* 📈 **Highly Customizable Charts** - Adjust colors, line widths, point sizes, and toggle visibility
* 🔄 **Auto-Calculate GKI** - Automatic Glucose-Ketone Index calculation with color-coded zones
* 📅 **Flexible Date Filtering** - Preset ranges (7/30/90 days) or custom date selection with optional persistence
* 🎯 **Tap-to-View Values** - Interactive charts show exact values on tap/drag
* ⚡ **Quick Data Entry** - Dedicated landing page with inline entry fields for all measurement types

### Advanced Features
* 🔀 **Merge Charts** - Compare different metrics with independent dual Y-axes
* 💾 **Data Export/Import** - CSV format with clipboard support
* 🎨 **Chart Customization** - Per-chart color schemes, line styles, and point sizes
* 📱 **Local Storage** - All data stored securely on-device with SwiftData
* 🗑️ **Data Management** - Delete all data with double-confirmation protection
* 🎯 **Chart-Locked Quick-Add** - Quick-add buttons automatically use the correct measurement type
* 💿 **Persistent Settings** - Optional date range persistence across app launches
* 🏠 **Default Measurement Types** - Ships with Glucose, Ketones, and Weight pre-configured

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

The app starts with three default measurement types (Glucose, Ketones, Weight). You can:
* Add data via the **Add Data** tab with inline entry fields
* Use quick-add buttons on individual charts
* Create additional custom measurement types
* Import existing data via CSV (clipboard or file)

## 📱 Usage

### Adding Measurements

**Method 1: Quick Entry (Recommended)**
1. Tap the **Add Data** tab at the bottom
2. Enter values directly in the inline fields for each measurement type
3. Tap **Add** - data saves and automatically navigates to the chart

**Method 2: Chart Quick-Add**
1. Find the chart you want to add data to
2. Tap the **green + button** next to the chart title
3. Enter value and optional notes
4. Quick-add is automatically locked to that chart's measurement type

**Method 3: Full Form**
1. Tap the **+** button in the top right (Charts tab)
2. Select **"Add Measurement"**
3. Choose measurement type, enter value, date, and notes

### Creating Custom Measurement Types

1. Tap **+** → **"New Measurement Type"**
2. Enter name, unit, choose emoji and color
3. New type appears immediately in Charts and Add Data tabs

### Customizing Charts

1. Tap the **blue sliders icon** next to any chart title
2. Adjust line colors, widths, point sizes
3. Toggle line/point visibility
4. Changes save automatically

### Merging Charts

1. Tap **+** → **"Merge Charts"**
2. Select exactly 2 measurement types (can include GKI)
3. View with independent Y-axes (left and right)
4. Each metric maintains its own scale with proper alignment

### Date Range Filtering

**Quick Presets:**
* Last 7 Days
* Last 30 Days
* Last 90 Days
* All Time
* Custom Range

**Persistent Custom Ranges:**
1. Go to **Settings** tab
2. Enable **"Remember custom date range"**
3. Set custom dates via the calendar button
4. Dates persist across app launches

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
2025-12-01,07:00:00,Weight,175,Lbs,Morning
```

### Exporting Data

1. Tap **+** → **"Export Data"**
2. CSV data copied to clipboard
3. Paste into Notes, Mail, or any text app

## 📝 Changelog

### Version 1.0.0 (December 11, 2025)
**Initial Release**

**Core Features:**
* ✅ Custom measurement types with emoji and color selection
* ✅ Interactive charts with tap-to-view functionality
* ✅ Automatic GKI calculation with color-coded zones
* ✅ Chart customization (colors, line widths, point sizes, visibility toggles)
* ✅ Merged charts with independent dual Y-axes (properly aligned)
* ✅ Date range filtering (7/30/90 days or custom dates)
* ✅ CSV import/export with clipboard support
* ✅ SwiftData persistence for all user data
* ✅ Data management with delete confirmation

**Navigation & UX:**
* ✅ Tab-based navigation (Charts, Add Data, Settings)
* ✅ Chart header buttons (customize, quick-add)
* ✅ Quick-add buttons locked to chart's measurement type
* ✅ Data entry landing page with inline entry fields
* ✅ Auto-navigation to chart after data entry
* ✅ GKI navigator button in Add Data tab

**Default Setup:**
* ✅ Ships with Glucose, Ketones, and Weight measurement types
* ✅ Clean data on first launch (no sample data)

**Settings:**
* ✅ Optional date range persistence across app launches
* ✅ "Remember custom date range" toggle

**Technical Improvements:**
* ✅ Fixed Y-axis alignment in merged charts
* ✅ GKI-specific Y-axis values (1, 3, 6, 9) in merged views
* ✅ Proper SwiftUI state management for sheet presentations
* ✅ Closure-based @State initialization for UserDefaults loading

## 🗺️ Roadmap

### Planned Features
* 📋 Chart reordering functionality
* 📋 Horizontally scrollable charts for long time periods
* 📋 Chart overlays (compare different time periods side-by-side)
* 📋 Customizable GKI zone colors
* 📋 Statistics and analytics view
* 📋 Chart export as images
* 📋 Apple Health integration
* 📋 Custom emoji as chart data points

### App Store Preparation
* 📋 App icon design
* 📋 Privacy policy
* 📋 App Store screenshots
* 📋 App Store description
* 📋 TestFlight beta testing

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

* **Development Time**: 28 hours 20 minutes (across 12 sessions)
* **Lines of Code**: ~3,500+
* **Files**: 17 Swift files
* **Commits**: 23+ semantic commits
* **Started**: December 2, 2025
* **Version 1.0.0**: December 11, 2025
* **Development Period**: December 2-11, 2025

## 🙏 Acknowledgments

Built with guidance from Claude (Anthropic) as a comprehensive learning project for iOS development.

**Key Learnings:**
* SwiftUI state management and binding patterns
* Swift Charts dual Y-axis implementation
* SwiftData for local persistence
* UserDefaults for app settings
* Proper code organization and helper view extraction
* Git workflow with semantic commits
* Data integrity debugging (Session 11 lesson: always check data first!)

---

**Note**: ChartAnything is designed for personal health tracking. Always consult healthcare professionals for medical decisions.
