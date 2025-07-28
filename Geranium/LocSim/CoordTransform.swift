//
//  CoordTransform.swift
//  Geranium
//
//  Created by acg7878 on 28.07.25.
//

import CoreLocation
import Foundation

/// A utility for converting coordinates between WGS-84 and GCJ-02.
struct CoordTransform {

    // MARK: - Geodetic Constants

    /// Semi-major axis of the Krasovsky 1940 ellipsoid, used for GCJ-02.
    private static let krasovskySemiMajorAxis = 6378245.0

    /// Squared eccentricity of the WGS-84 ellipsoid.
    private static let wgs84EccentricitySquared = 0.00669342162296594323

    /// Converts GCJ-02 (Mars Coordinates) to WGS-84 (World Geodetic System).
    /// This is the primary function needed for correcting the map offset.
    /// - Parameter gcjCoordinate: The coordinate obtained from a Chinese map (in GCJ-02).
    /// - Returns: The corrected coordinate in WGS-84.
    static func gcj02ToWgs84(_ gcjCoordinate: CLLocationCoordinate2D) -> CLLocationCoordinate2D {
        if isOutOfChina(gcjCoordinate) {
            return gcjCoordinate
        }

        let wgsCoordinate = reverseGeocode(gcjCoordinate)
        return wgsCoordinate
    }

    /// Converts WGS-84 (World Geodetic System) to GCJ-02 (Mars Coordinates).
    /// - Parameter wgsCoordinate: The coordinate from a standard GPS source (in WGS-84).
    /// - Returns: The coordinate ready to be displayed on a Chinese map (in GCJ-02).
    static func wgs84ToGcj02(_ wgsCoordinate: CLLocationCoordinate2D) -> CLLocationCoordinate2D {
        if isOutOfChina(wgsCoordinate) {
            return wgsCoordinate
        }
        return geocode(wgsCoordinate)
    }

    // MARK: - Core Transformation Logic

    /// Forward geocoding: Applies the GCJ-02 offset to a WGS-84 coordinate.
    private static func geocode(_ wgsCoordinate: CLLocationCoordinate2D) -> CLLocationCoordinate2D {
        var adjustedCoordinate = wgsCoordinate
        var latOffset = transformLatitude(
            x: wgsCoordinate.longitude - 105.0, y: wgsCoordinate.latitude - 35.0)
        var lonOffset = transformLongitude(
            x: wgsCoordinate.longitude - 105.0, y: wgsCoordinate.latitude - 35.0)

        let radLat = wgsCoordinate.latitude / 180.0 * Double.pi
        var magic = sin(radLat)
        magic = 1 - wgs84EccentricitySquared * magic * magic
        let sqrtMagic = sqrt(magic)

        latOffset =
            (latOffset * 180.0)
            / ((krasovskySemiMajorAxis * (1 - wgs84EccentricitySquared)) / (magic * sqrtMagic)
                * Double.pi)
        lonOffset =
            (lonOffset * 180.0) / (krasovskySemiMajorAxis / sqrtMagic * cos(radLat) * Double.pi)

        adjustedCoordinate.latitude += latOffset
        adjustedCoordinate.longitude += lonOffset

        return adjustedCoordinate
    }

    /// Reverse geocoding: Removes the GCJ-02 offset from a coordinate using iterative approximation.
    private static func reverseGeocode(_ gcjCoordinate: CLLocationCoordinate2D)
        -> CLLocationCoordinate2D
    {
        let initialPoint = gcjCoordinate
        let geocodedPoint = geocode(initialPoint)
        let latOffset = geocodedPoint.latitude - initialPoint.latitude
        let lonOffset = geocodedPoint.longitude - initialPoint.longitude

        return CLLocationCoordinate2D(
            latitude: initialPoint.latitude - latOffset,
            longitude: initialPoint.longitude - lonOffset
        )
    }

    /// Checks if a coordinate is outside of mainland China.
    private static func isOutOfChina(_ coordinate: CLLocationCoordinate2D) -> Bool {
        return coordinate.longitude < 72.004 || coordinate.longitude > 137.847
            || coordinate.latitude < 0.8293 || coordinate.latitude > 55.8271
    }

    private static func transformLatitude(x: Double, y: Double) -> Double {
        var lat = -100.0 + 2.0 * x + 3.0 * y + 0.2 * y * y + 0.1 * x * y + 0.2 * sqrt(abs(x))
        lat += (20.0 * sin(6.0 * x * Double.pi) + 20.0 * sin(2.0 * x * Double.pi)) * 2.0 / 3.0
        lat += (20.0 * sin(y * Double.pi) + 40.0 * sin(y / 3.0 * Double.pi)) * 2.0 / 3.0
        lat += (160.0 * sin(y / 12.0 * Double.pi) + 320 * sin(y * Double.pi / 30.0)) * 2.0 / 3.0
        return lat
    }

    private static func transformLongitude(x: Double, y: Double) -> Double {
        var lon = 300.0 + x + 2.0 * y + 0.1 * x * x + 0.1 * x * y + 0.1 * sqrt(abs(x))
        lon += (20.0 * sin(6.0 * x * Double.pi) + 20.0 * sin(2.0 * x * Double.pi)) * 2.0 / 3.0
        lon += (20.0 * sin(x * Double.pi) + 40.0 * sin(x / 3.0 * Double.pi)) * 2.0 / 3.0
        lon += (150.0 * sin(x / 12.0 * Double.pi) + 300.0 * sin(x / 30.0 * Double.pi)) * 2.0 / 3.0
        return lon
    }
}
