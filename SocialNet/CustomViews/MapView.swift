//
//  MapView.swift
//  SocialNet
//
//  Created by Роман Лешин on 10.12.2024.
//


import SwiftUI
import MapKit

struct MapView: View {
    let coordinate: CLLocationCoordinate2D
    @Environment(\.dismiss) private var dismiss
    @State private var cameraPosition: MapCameraPosition

    init(coordinatePoint: Coordinates = Coordinates(lat: 51.209759, long: 58.509221)) {
        self.coordinate = CLLocationCoordinate2D(latitude: coordinatePoint.lat, longitude: coordinatePoint.long)
        _cameraPosition = State(initialValue: MapCameraPosition.region(
            MKCoordinateRegion(
                center: coordinate,
                span: MKCoordinateSpan(latitudeDelta: 0.05, longitudeDelta: 0.05)
            )
        ))
    }

    var body: some View {
        NavigationView {
            Map(position: $cameraPosition) {
                Annotation("", coordinate: coordinate) {
                    Image(systemName: "mappin.circle.fill")
                        .resizable()
                        .frame(width: 32, height: 32)
                        .foregroundColor(.red)
                }
            }
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Закрыть") {
                        dismiss()
                    }
                }
            }
        }
        .navigationTitle("Карта")
    }
}


