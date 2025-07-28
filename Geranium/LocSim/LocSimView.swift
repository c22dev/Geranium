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
                startSimulation(at: coordinate.coordinate)
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
                            startSimulation(at: gcjCoordinate)
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
    
    private func startSimulation(at gcjCoordinate: CLLocationCoordinate2D) {
        // Convert coordinate from GCJ-02 to WGS-84
        let wgsCoordinate = CoordTransform.gcj02ToWgs84(gcjCoordinate)
        
        // Update the state variables for any UI that might display them
        self.lat = wgsCoordinate.latitude
        self.long = wgsCoordinate.longitude
        
        // Start the simulation with the corrected WGS-84 coordinate
        LocSimManager.startLocSim(location: .init(latitude: wgsCoordinate.latitude, longitude: wgsCoordinate.longitude))
        
        // Show success alert
        AlertKitAPI.present(
            title: "Started!",
            icon: .done,
            style: .iOS17AppleMusic,
            haptic: .success
        )
    }
}
