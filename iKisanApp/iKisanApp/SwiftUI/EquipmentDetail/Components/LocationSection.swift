//
//  LocationSection.swift
//  iKisanApp
//
//  Location section with map snapshot
//

import SwiftUI
import MapKit

struct LocationSection: View {
    
    @ObservedObject var viewModel: EquipmentDetailViewModel
    @Environment(\.dynamicTypeSize) private var dynamicTypeSize
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            // Section Header
            Text("Location")
                .font(.system(size: 22, weight: .bold))
                .foregroundColor(.primary)
                .accessibilityAddTraits(.isHeader)
            
            // Location Card
            if dynamicTypeSize <= .xxxLarge {
                HStack(spacing: 16) {
                    locationInfo
                    Spacer(minLength: 12)
                    mapPreview
                }
            } else {
                VStack(alignment: .leading, spacing: 16) {
                    locationInfo
                    mapPreview
                        .frame(height: 120)
                }
            }
        }
    }
    
    // MARK: - Subviews
    
    private var locationInfo: some View {
        VStack(alignment: .leading, spacing: 6) {
            HStack(spacing: 8) {
                Image(systemName: "mappin.circle.fill")
                    .font(.system(size: 20, weight: .medium))
                    .foregroundColor(Color(red: 0.298, green: 0.498, blue: 0.345))
                
                Text(viewModel.locationText)
                    .font(.system(size: 17, weight: .semibold))
                    .foregroundColor(.primary)
            }
            
            Text("Equipment Location")
                .font(.caption)
                .foregroundColor(.secondary)
        }
        .accessibilityElement(children: .combine)
        .accessibilityLabel("Location: \(viewModel.locationText)")
    }
    
    private var mapPreview: some View {
        Button(action: {
            viewModel.openLocationInMaps()
        }) {
            EquipmentLocationMapPreview(locationName: viewModel.locationText)
                .frame(width: 110, height: 90)
                .clipShape(RoundedRectangle(cornerRadius: 12))
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(Color(.systemGray5), lineWidth: 1)
                )
                .overlay(
                    // Add a subtle indicator that it's tappable
                    VStack {
                        Spacer()
                        HStack {
                            Spacer()
                            Image(systemName: "arrow.up.forward.circle.fill")
                                .font(.system(size: 20))
                                .foregroundStyle(.white, Color(red: 0.298, green: 0.498, blue: 0.345))
                                .shadow(color: .black.opacity(0.3), radius: 2, x: 0, y: 1)
                                .padding(6)
                        }
                    }
                )
                .shadow(color: Color.black.opacity(0.06), radius: 8, x: 0, y: 2)
        }
        .buttonStyle(MapPreviewButtonStyle())
        .accessibilityLabel("Open \(viewModel.locationText) in Maps")
        .accessibilityHint("Double tap to view location in Apple Maps")
    }
}

// MARK: - Equipment Location Map Preview Component
struct EquipmentLocationMapPreview: View {
    let locationName: String
    @State private var region: MKCoordinateRegion
    @State private var isInteractive = false
    
    init(locationName: String) {
        self.locationName = locationName
        // Default coordinates for Prayagraj (can be geocoded in real implementation)
        self._region = State(initialValue: MKCoordinateRegion(
            center: CLLocationCoordinate2D(latitude: 25.4358, longitude: 81.8463),
            span: MKCoordinateSpan(latitudeDelta: 0.03, longitudeDelta: 0.03)
        ))
    }
    
    var body: some View {
        ZStack {
            Map(coordinateRegion: .constant(region), interactionModes: [])
                .allowsHitTesting(false)
            
            // Location Pin
            Image(systemName: "mappin.circle.fill")
                .font(.system(size: 36, weight: .medium))
                .foregroundStyle(.red, .white)
                .shadow(color: .black.opacity(0.2), radius: 2, x: 0, y: 1)
        }
        .accessibilityElement(children: .ignore)
        .accessibilityLabel("Map showing location of \(locationName)")
    }
}

// MARK: - Map Preview Button Style
struct MapPreviewButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .scaleEffect(configuration.isPressed ? 0.95 : 1.0)
            .opacity(configuration.isPressed ? 0.8 : 1.0)
            .animation(.easeInOut(duration: 0.15), value: configuration.isPressed)
    }
}
