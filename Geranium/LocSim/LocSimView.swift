//
//  LocSimView.swift
//  Geranium
//
//  Created by cclerc on 21.12.23.
//

import SwiftUI
import CoreLocation
import AlertKit

struct LocSimView: View {
    @StateObject private var appSettings = AppSettings()
    
    @State private var locationManager = CLLocationManager()
    @State private var lat: Double = 0.0
    @State private var long: Double = 0.0
    @State private var altitude: String = "0.0"
    @State private var tappedCoordinate: EquatableCoordinate? = nil
    @State private var bookmarkSheetTggle: Bool = false
    var body: some View {
            if #available(iOS 16.0, *) {
                NavigationStack {
                    LocSimMainView()
                }
            } else {
                NavigationView {
                    LocSimMainView()
                }
            }
        }
    @ViewBuilder
        private func LocSimMainView() -> some View {
            VStack {
                CustomMapView(tappedCoordinate: $tappedCoordinate)
                    .onAppear {
                        CLLocationManager().requestAlwaysAuthorization()
                    }
            }
            .ignoresSafeArea(.keyboard)
        .onAppear {
            LocationModel().requestAuthorisation()
        }
        .onChange(of: tappedCoordinate) { newValue in
            if let coordinate = newValue {
                let altitudeValue = Double(altitude) ?? 0.0
                startSimulation(at: coordinate.coordinate, altitude: altitudeValue)
            }
        }
        .toolbar{
            ToolbarItem(placement: .navigationBarLeading) {
                Text("LocSim")
                    .font(.title2)
                    .bold()
            }
            ToolbarItem(placement: .navigationBarTrailing) {
                Button(action: {
                    UIApplication.shared.TextFieldAlert(
                        title: "Enter Coordinates",
                        message: "The location will be simulated on device\nPro tip: Press wherever on the map to move there.",
                        textFieldPlaceHolder: "Latitude",
                        secondTextFieldPlaceHolder: "Longitude"
                    ) { latText, longText in
                        if let latDouble = Double(latText ?? ""), let longDouble = Double(longText ?? "") {
                            // Standardize the use of the startSimulation function.
                            let gcjCoordinate = CLLocationCoordinate2D(latitude: latDouble, longitude: longDouble)
                            let altitudeValue = Double(altitude) ?? 0.0
                            startSimulation(at: gcjCoordinate, altitude: altitudeValue)
                        } else {
                            UIApplication.shared.alert(body: "Those are invalid coordinates mate !")
                        }
                    }
                }) {
                    Image(systemName: "mappin")
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: 24, height: 24)
                }
            }
            ToolbarItem(placement: .navigationBarTrailing) {
                Button(action: {
                    UIApplication.shared.TextFieldAlert(
                        title: "Set Altitude",
                        message: "Enter the altitude in meters.",
                        textFieldPlaceHolder: "Altitude (m)"
                    ) { altitudeText, _ in
                        if let altText = altitudeText, !altText.isEmpty {
                            self.altitude = altText
                            AlertKitAPI.present(
                                title: "Altitude Set!",
                                icon: .done,
                                style: .iOS17AppleMusic,
                                haptic: .success
                            )
                        }
                    }
                }) {
                    Image(systemName: "mountain.2.fill")
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: 24, height: 24)
                }
            }
            ToolbarItem(placement: .navigationBarTrailing) {
                Button(action: {
                    if appSettings.locSimMultipleAttempts {
                        var countdown = appSettings.locSimAttemptNB
                        DispatchQueue.global().async {
                            while countdown > 0 {
                                LocSimManager.stopLocSim()
                                countdown -= 1
                            }
                        }
                    }
                    else {
                        LocSimManager.stopLocSim()
                    }
                    AlertKitAPI.present(
                        title: "Stopped !",
                        icon: .done,
                        style: .iOS17AppleMusic,
                        haptic: .success
                    )
                }) {
                    Image(systemName: "location.slash")
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: 24, height: 24)
                }
            }
            ToolbarItem(placement: .navigationBarTrailing) {
                Button(action: {
                    bookmarkSheetTggle.toggle()
                }) {
                    Image(systemName: "bookmark")
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: 24, height: 24)
                }
            }
        }
        .sheet(isPresented: $bookmarkSheetTggle) {
            BookMarkSlider(lat: $lat, long: $long)
        }
    }
    
    private func startSimulation(at gcjCoordinate: CLLocationCoordinate2D, altitude: Double) {
        let wgsCoordinate = CoordTransform.gcj02ToWgs84(gcjCoordinate)
        
        self.lat = wgsCoordinate.latitude
        self.long = wgsCoordinate.longitude
        
        let location = CLLocation(coordinate: wgsCoordinate, altitude: altitude, horizontalAccuracy: 5, verticalAccuracy: 5)
        LocSimManager.startLocSim(location: location)
        
        AlertKitAPI.present(
            title: "Started!",
            icon: .done,
            style: .iOS17AppleMusic,
            haptic: .success
        )
    }
}

#Preview {
    LocSimView()
}
