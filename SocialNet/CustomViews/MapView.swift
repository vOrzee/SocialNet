//
//  MapView.swift
//  SocialNet
//
//  Created by Роман Лешин on 10.12.2024.
//

import SwiftUI
import MapKit

struct MapView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var cameraPosition: MapCameraPosition
    @State private var selectedCoordinate: CLLocationCoordinate2D?
    @State private var isEditingMode: Bool
    @Binding var coordinates: Coordinates?

    init(coordinatePoint: Coordinates? = nil, _ coordinates: Binding<Coordinates?>) {
        _coordinates = coordinates
        if let coordinatePoint = coordinatePoint {
            let coordinate = CLLocationCoordinate2D(latitude: coordinatePoint.lat, longitude: coordinatePoint.long)
            _cameraPosition = State(initialValue: .region(
                MKCoordinateRegion(
                    center: coordinate,
                    span: MKCoordinateSpan(latitudeDelta: 0.05, longitudeDelta: 0.05)
                )
            ))
            _selectedCoordinate = State(initialValue: coordinate)
            _isEditingMode = State(initialValue: false)
        } else {
            _cameraPosition = State(initialValue: .region(
                MKCoordinateRegion(
                    center: CLLocationCoordinate2D(latitude: 51.209759, longitude: 58.509221),
                    span: MKCoordinateSpan(latitudeDelta: 5.0, longitudeDelta: 5.0)
                )
            ))
            _selectedCoordinate = State(initialValue: nil)
            _isEditingMode = State(initialValue: true)
        }
    }

    var body: some View {
        NavigationStack {
            ZStack {
                Map(position: $cameraPosition, interactionModes: .all) {
                    if let selectedCoordinate, !isEditingMode {
                        Annotation("Pin", coordinate: selectedCoordinate) {
                            Image(systemName: "mappin.circle.fill")
                                .resizable()
                                .frame(width: 32, height: 32)
                                .foregroundColor(.red)
                        }
                    }
                }
                .onMapCameraChange { context in
                    if (isEditingMode) {
                        selectedCoordinate = context.region.center
                    }
                }
                .toolbar {
                    ToolbarItem(placement: .cancellationAction) {
                        Button("Закрыть") {
                            dismiss()
                        }
                    }
                    if isEditingMode {
                        ToolbarItem(placement: .confirmationAction) {
                            Button("Сохранить") {
                                if let selectedCoordinate {
                                    coordinates = Coordinates(
                                        lat: selectedCoordinate.latitude,
                                        long: selectedCoordinate.longitude
                                    )
                                }
                                dismiss()
                            }
                            .disabled(selectedCoordinate == nil)
                        }
                    }
                }
                if isEditingMode {
                    Image(systemName: "location.north.fill")
                        .resizable()
                        .frame(width: 32, height: 32)
                        .foregroundColor(.orange)
                        .rotationEffect(.degrees(180))
                }
            }
        }
        .navigationTitle("Карта")
    }
}


