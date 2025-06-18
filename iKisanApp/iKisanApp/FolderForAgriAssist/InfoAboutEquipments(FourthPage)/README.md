# InfoAboutEquipments SwiftUI Conversion

This folder has been converted from UIKit to SwiftUI while maintaining the same functionality and UI design.

## Files

### New SwiftUI Files
- `InfoAboutEquipmentsView.swift` - Main SwiftUI view with all components
- `InfoAboutEquipmentsHostingController.swift` - UIKit hosting controller for integration

### Removed UIKit Files
- `infoAboutEquipmentsViewController.swift` - Old UIKit view controller
- `InfoAboutEquipmentDetailsCollectionViewCell.swift` - Old collection view cell
- `RelatedEquipmentCollectionViewCell.swift` - Old collection view cell
- `AllEquipmentsViewController.swift` - Old view controller for all equipments
- `AgriSectionHeaderCollectionReusableView.swift` - Old section header view
- `InfoAboutEquipmentDetailsCollectionViewCell.xib` - Old XIB file
- `RelatedEquipmentCollectionViewCell.xib` - Old XIB file

## Features

### Equipment Details Section
- Displays detailed information about the selected equipment
- Shows equipment image, name, likes count
- Displays purpose, best for, average cost, and needs
- Tap on image to play video
- Consistent styling with app's color scheme

### Related Equipment Section
- Grid layout showing related equipment
- Each card shows equipment image, name, likes count
- "Book Now" button for each equipment
- "See All" button to view all related equipment

### All Equipments View
- Modal sheet showing all equipment of a category
- Same grid layout as related equipment section
- Proper navigation and dismissal

## Styling
- Uses the app's signature green color: `Color(red: 0.298, green: 0.498, blue: 0.345)`
- Consistent corner radius (12-16px)
- Subtle shadows and borders
- Proper spacing and typography

## Integration
- Updated storyboard to use `InfoAboutEquipmentsHostingController`
- Updated segue preparations in other view controllers
- Maintains same navigation flow and data passing

## Data Loading
- Uses SupabaseManager for async data loading
- Proper error handling and loading states
- Maintains same data structure and API calls 