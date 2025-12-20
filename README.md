# draingo — Development Report

### Overview
- draingo is an iOS-only app built with SwiftUI to help people understand flood risk around a location.
- The product emphasizes a clean, map-first experience where users can pick a place, see current conditions, and learn about nearby flood reports.

### Key Features
- The Set Location screen lets users choose an area on the map while viewing a top weather card and a bottom search card.
- After searching, the UI switches to a results view that keeps the map in place and overlays flood nodes with clear risk levels.
- Selecting a node opens a detail sheet with walking guidance, user reports, and an address line.
- A “Write report” button opens a reporting sheet where the user can describe the problem and attach a photo.

### User Experience Flow
- On launch, the app attempts to center the map on the device’s current location, using the system permission prompt when needed.
- A search or pin action recenters the map to the target region, and once the camera settles, the results UI appears on the same screen.
- The map continues to update flood nodes regularly while results are shown.
- Tapping a node opens its detail sheet, and the reporting sheet is presented from there.

### Technology Used
- The app is written in Swift and SwiftUI, and it targets iOS only.
- MapKit and CoreLocation handle the map view, search, reverse geocoding, and device location.
- PhotosUI is used for the photo picker in the report sheet.
- Supabase provides the cloud database and file storage for flood nodes and reports.
- Open-Meteo supplies current weather data.
- Development is done in Xcode 26 with an iOS 26.1 deployment target.

### How the App Is Organized
- The project uses a feature-first structure so that each screen keeps its views, view models, and UI components together.
- The map and search experiences live in separate feature folders, while shared models and services are in their own directories.
- Assets are stored in the asset catalog, and app-level files live in the App folder.

### Data and Backend
- Weather data is fetched from Open-Meteo based on the selected location.
- Flood nodes and user reports come from Supabase, and report photos are uploaded to Supabase Storage.
- The app reads from a public view for node data and writes user reports directly to the database with a public insert policy.
- A dedicated storage bucket is used for report images.

### Build and Run
- Open the project in Xcode using `open draingo.xcodeproj`.
- Use the iOS Simulator build command from AGENTS.md if you prefer the command line.
- Tests can be run via `xcodebuild` as documented in the repository guidelines.

### Configuration Notes
- The app requires a Location When In Use description in the target’s Info settings so iOS can prompt for permission.
- Supabase is configured in `draingo/Services/Supabase.swift`.
- Any custom fonts must be bundled correctly and referenced in the app’s Info settings.
- The launch screen is defined in `LaunchScreen.storyboard`.

### Current State
- Core screens and the primary flow are in place, including the search UI, map results, node details, and report submission.
- Supabase reads and writes are wired, and the reporting flow can upload photos.
- The app includes a periodic refresh of node data while the results view is visible.

### Challenges Encountered
- Xcode 26’s folder-versus-group behavior made it easy to misplace resources, which later showed up as missing fonts at runtime.
- iOS 26 deprecated several MapKit and CoreLocation APIs, so reverse geocoding and placemark usage required migration.
- SwiftUI map annotation gestures needed adjustments to work correctly inside annotation content.
- Early builds were slow or appeared to hang due to network or API issues, which required careful isolation of asynchronous calls.
- Supabase integration required attention to target membership and package configuration.

### Roadmap
- Short term: polish the reporting flow, refine the node detail presentation, and tighten UI consistency.
- Mid term: add moderation and validation for reports, clearer risk categorization, and offline-friendly caching.
- Long term: integrate live sensor ingestion and build an admin-facing dashboard for monitoring flood conditions and device health.
