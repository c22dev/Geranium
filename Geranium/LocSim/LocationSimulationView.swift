//
//  LocationSimulationView.swift
//  TrollTools
//
//  Created by Constantin Clerc on 21.12.2022.
//

import Map
import MapKit
import SwiftUI

struct EquatableCoordinate: Equatable {
    var coordinate: CLLocationCoordinate2D
    
    static func ==(lhs: EquatableCoordinate, rhs: EquatableCoordinate) -> Bool {
        lhs.coordinate.latitude == rhs.coordinate.latitude && lhs.coordinate.longitude == rhs.coordinate.longitude
    }
}

struct LocationSimulationView: View {
    struct Location: Identifiable {
        var coordinate: CLLocationCoordinate2D
        var id = UUID()
    }
    @State var locations: [Location] = []
    @State private var long = ""
    @State private var lat = ""
    @State var showBookSheet = false
    @State var directions: MKDirections.Response? = nil
    @State private var region = MKCoordinateRegion(.world)
    @State private var tappedCoordinate: EquatableCoordinate? = nil
    @State private var selectedKey: String?
    var body: some View {
        NavigationView{
            VStack {
                TextField("Enter latitude", text: $lat)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                
                TextField("Enter longitude", text: $long)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
//                Button(action: {
//                    showBookSheet = true
//                }) {
//                    Text("Bookmarks")
//                }
//                .sheet(isPresented: $showBookSheet) {
//                    VStack {
//                        if let array = UserDefaults.standard.object(forKey: "bookmarksList") as? [String] {
//                            Picker("Select a bookmark", selection: $selectedKey) {
//                                ForEach(array, id: \.self) { key in
//                                    Text(key)
//                                }
//                            }
//                            .pickerStyle(.menu)
//
//                            Button("Start LocSim") {
//                                UIApplication.shared.alert(title:"debug", body:"\(selectedKey) sel = \(selectedKey)")
//                                if let usrarray = UserDefaults.standard.object(forKey: selectedKey!) as? [String], usrarray.count >= 2 {
//                                    let var1 = usrarray[0]
//                                    let var2 = usrarray[1]
//                                    let latitudeValue = Double(var1)
//                                    let longitudeValue = Double(var2)
//                                    LocSimManager.startLocSim(location: .init(latitude: latitudeValue!, longitude: longitudeValue!))
//                                    locations = [.init(coordinate: .init(latitude: latitudeValue!, longitude: longitudeValue! )),.init(coordinate: .init(latitude: latitudeValue!, longitude: longitudeValue!)),]
//                                    calculateDirections()
//                                    miniimpactVibrate()
//                                    print("LOCSIM ENABLED for Latitude: \(lat), Longitude: \(long), bookmark : \(selectedKey)")
//                                }
//                                if let key = selectedKey {
//                                }
//                            }
//                            Button("Remove Bookmark") {
//                                if let key = selectedKey {
//                                    UserDefaults.standard.removeObject(forKey: key)
//                                }
//                            }
//                        } else {
//                            Text("No bookmarks added! Try adding some using the button in the toolbar.")
//                        }
//
//                    }
//                }
                let latitudeValue = Double(lat)
                let longitudeValue = Double(long)
                CustomMapView(tappedCoordinate: $tappedCoordinate)
                    .onAppear {
                        CLLocationManager().requestAlwaysAuthorization()
                    }
            }
            .toolbar{
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: {
                        let latitudeValue = Double(lat)
                        let longitudeValue = Double(long)
                        LocSimManager.startLocSim(location: .init(latitude: latitudeValue!, longitude: longitudeValue!))
                        locations = [.init(coordinate: .init(latitude: latitudeValue!, longitude: longitudeValue! )),.init(coordinate: .init(latitude: latitudeValue!, longitude: longitudeValue!)),]
                        calculateDirections()
                        miniimpactVibrate()
                        print("LOCSIM ENABLED for Latitude: \(lat), Longitude: \(long)")
                    }) {
                        Image(systemName: "location")
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(width: 24, height: 24)
                    }
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: {
                        
                        UIApplication.shared.TextFieldAlert(title: "Enter a name for the bookmark", textFieldPlaceHolder: "Name of the bookmark") { (text) in
                            if let name = text {
                                let latlong = [lat, long]
                                UserDefaults.standard.set(latlong, forKey: name)
                                if let value = UserDefaults.standard.object(forKey: "bookmarksList") {
                                    if var bookmarksLi = UserDefaults.standard.array(forKey: "bookmarksList") as? [String] {
                                        bookmarksLi.append(name)
                                        UserDefaults.standard.set(bookmarksLi, forKey: "bookmarksList")
                                        UIApplication.shared.alert(title:"Success!", body:"The bookmark was saved !")
                                    }
                                } else {
                                    let bookmarksList = [name]
                                    UserDefaults.standard.set(bookmarksList, forKey: "bookmarksList")
                                }
                            }
                        }
                        
                    }) {
                        Image(systemName: "bookmark")
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(width: 24, height: 24)
                    }
                }
                ToolbarItem(placement: .navigationBarLeading) {
                    Button(action: {
                        LocSimManager.stopLocSim()
                        impactVibrate()
                        print("ohno")
                    }) {
                        Image(systemName: "location.slash")
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(width: 24, height: 24)
                    }
                }
            }
        }
            .onChange(of: tappedCoordinate) { newValue in
                if let coordinate = newValue {
                    lat = String(coordinate.coordinate.latitude)
                    long = String(coordinate.coordinate.longitude)
                }
            }
    }
    func calculateDirections() {
        guard locations.count >= 2 else { return }
        let request = MKDirections.Request()
        request.source = MKMapItem(placemark: .init(coordinate: locations[0].coordinate))
        request.destination = MKMapItem(placemark: .init(coordinate: locations[1].coordinate))
        request.transportType = .automobile
        
        let directions = MKDirections(request: request)
        directions.calculate { response, error in
            self.directions = response
//            region = .init(response?.routes.first?.polyline.boundingMapRect)
        }
    }
}

struct CustomMapView: UIViewRepresentable {
    @Binding var tappedCoordinate: EquatableCoordinate?
    
    func makeUIView(context: Context) -> MKMapView {
        let mapView = MKMapView()
        mapView.delegate = context.coordinator
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
            impactVibrate()
        }
    }
}



struct LocationSimulationView_Previews: PreviewProvider {
    static var previews: some View {
        LocationSimulationView()
    }
}
