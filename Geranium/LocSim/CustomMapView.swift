//
//  CustomMapView.swift
//  Geranium
//
//  Created by cclerc on 21.12.23.
//

import SwiftUI
import MapKit

struct CustomMapView: UIViewRepresentable {
    @Binding var tappedCoordinate: EquatableCoordinate?

    func makeUIView(context: Context) -> MKMapView {
        let mapView = MKMapView()
        mapView.delegate = context.coordinator
        mapView.showsUserLocation = true
        mapView.layer.cornerRadius = 15
        mapView.layer.masksToBounds = true

        let tapRecognizer = UITapGestureRecognizer(target: context.coordinator, action: #selector(Coordinator.handleTap(_:)))
        mapView.addGestureRecognizer(tapRecognizer)
        return mapView
    }

    func updateUIView(_ uiView: MKMapView, context: Context) {}

    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }

    class Coordinator: NSObject, MKMapViewDelegate {
        var parent: CustomMapView

        init(_ parent: CustomMapView) {
            self.parent = parent
        }

        @objc func handleTap(_ gesture: UITapGestureRecognizer) {
            let mapView = gesture.view as! MKMapView
            let touchPoint = gesture.location(in: mapView)
            let coordinate = mapView.convert(touchPoint, toCoordinateFrom: mapView)
            parent.tappedCoordinate = EquatableCoordinate(coordinate: coordinate)
        }
    }
}
