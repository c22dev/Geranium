//
//  LocSimManager.swift
//  Geranium
//
//  Created by Constantin Clerc on 12.11.2022.
//

import Foundation
import CoreLocation


class LocSimManager {
    static let simManager = CLSimulationManager()
    
    /// Updates timezone
    static func post_required_timezone_update(){
        CFNotificationCenterPostNotificationWithOptions(CFNotificationCenterGetDarwinNotifyCenter(), .init("AutomaticTimeZoneUpdateNeeded" as CFString), nil, nil, kCFNotificationDeliverImmediately);
    }
    
    /// Starts a location simulation of specified argument "location"
    // TODO: save
    static func startLocSim(location: CLLocation) {
        simManager.stopLocationSimulation()
        simManager.clearSimulatedLocations()
        simManager.appendSimulatedLocation(location)
        simManager.flush()
        simManager.startLocationSimulation()
        post_required_timezone_update();
    }
    
    /// Stops location simulation
    static func stopLocSim(){
        simManager.stopLocationSimulation()
        simManager.clearSimulatedLocations()
        simManager.flush()
        post_required_timezone_update();
    }
}


struct EquatableCoordinate: Equatable {
    var coordinate: CLLocationCoordinate2D
    
    static func ==(lhs: EquatableCoordinate, rhs: EquatableCoordinate) -> Bool {
        lhs.coordinate.latitude == rhs.coordinate.latitude && lhs.coordinate.longitude == rhs.coordinate.longitude
    }
}


// https://stackoverflow.com/a/75703059

class LocationModel: NSObject, ObservableObject {
    private let locationManager = CLLocationManager()
    @Published var authorisationStatus: CLAuthorizationStatus = .notDetermined

    override init() {
        super.init()
        self.locationManager.delegate = self
    }

    public func requestAuthorisation(always: Bool = false) {
        if always {
            self.locationManager.requestAlwaysAuthorization()
        } else {
            self.locationManager.requestWhenInUseAuthorization()
        }
    }
}

extension LocationModel: CLLocationManagerDelegate {

    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        self.authorisationStatus = status
    }
}


func extractCoordinates(from url: String) -> (latitude: Double, longitude: Double)? {
    var latitude: Double = 0.0
    var longitude: Double = 0.0
    
    if url.contains("maps.google") {
        // Extracting coordinates from Google Maps link
        if let range = url.range(of: #"@([-+]?\d*\.\d+),([-+]?\d*\.\d+)"#, options: .regularExpression) {
            let coordinates = url[range]
                .dropFirst()
                .split(separator: ",")
                .map { Double($0)! }
            if coordinates.count == 2 {
                latitude = coordinates[0]
                longitude = coordinates[1]
            }
        }
    } else if url.contains("maps.apple") {
        // Extracting coordinates from Apple Maps link
        if let range = url.range(of: #"&ll=([-+]?\d*\.\d+),([-+]?\d*\.\d+)&"#, options: .regularExpression) {
            let coordinates = url[range]
                .dropFirst(4)
                .dropLast(1)
                .split(separator: ",")
                .map { Double($0)! }
            if coordinates.count == 2 {
                latitude = coordinates[0]
                longitude = coordinates[1]
            }
        }
    } else {
        return nil // Unsupported URL
    }
    
    return (latitude, longitude)
}
