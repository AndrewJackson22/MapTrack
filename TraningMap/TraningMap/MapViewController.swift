//
//  MapViewController.swift
//  TraningMap
//
//  Created by Андрей Михайлов on 01.08.2021.
//

import UIKit
import MapKit
import CoreLocation

class MapViewController: UIViewController {
    
    let mapView: MKMapView = {
        let map = MKMapView()
        map.translatesAutoresizingMaskIntoConstraints = false
        return map
    }()
    
    let addAdress: UIButton = {
        let button = UIButton()
        button.setImage(UIImage(named: "addIcon"), for: .normal)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    let routeButton: UIButton = {
        let button = UIButton()
        button.setImage(UIImage(named: "routeIcon"), for: .normal)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.isHidden = true
        return button
    }()
    
    let resetButton: UIButton = {
        let button = UIButton()
        button.setImage(UIImage(named: "deleteIcon"), for: .normal)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.isHidden = true
        return button
    }()
    
    var anotationsArray = [MKPointAnnotation]()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        mapView.delegate = self
        setConstrain()
        addAdress.addTarget(self, action: #selector(addAdressTap), for: .touchUpInside)
        routeButton.addTarget(self, action: #selector(routeAdressTap), for: .touchUpInside)
        resetButton.addTarget(self, action: #selector(resetAdressTap), for: .touchUpInside)
    }
    
    @objc func addAdressTap() {
        alertAddAdress(title: "Добавить", placeholer: "Введите Адрес", comlishionHandler: { [self] (text) in
            setupPlaceMark(adressPlace: text)
        })
    }
    
    @objc func resetAdressTap() {
        mapView.removeOverlays(mapView.overlays)
        mapView.removeAnnotations(mapView.annotations)
        anotationsArray = [MKPointAnnotation]()
        resetButton.isHidden = true
        routeButton.isHidden = true
    }
    
    @objc func routeAdressTap() {
        for index in 0...anotationsArray.count - 2 {
            createDirection(startCoordinate: anotationsArray[index].coordinate, destinateCoordinate: anotationsArray[index + 1].coordinate)
        }
        mapView.showAnnotations(anotationsArray, animated: true)
    }
    
    private func setupPlaceMark(adressPlace: String) {
        let geocoder = CLGeocoder()
        geocoder.geocodeAddressString(adressPlace) { [self] (placemarks, error) in
            if let error = error {
                print(error)
                alertError(title: "Error", message: "Server is not found")
                return
            }
            guard let placeamrks = placemarks else { return }
            let placemark = placeamrks.first
            
            let annotation = MKPointAnnotation()
            annotation.title = "\(adressPlace)"
            guard let placemarkLocation = placemark?.location else { return }
            annotation.coordinate = placemarkLocation.coordinate
           
            
            anotationsArray.append(annotation)
            
            if anotationsArray.count > 2 {
                routeButton.isHidden = false
                resetButton.isHidden = false
                
            }
            mapView.showAnnotations(anotationsArray, animated: true)
        }
    }
    
    private func createDirection(startCoordinate: CLLocationCoordinate2D, destinateCoordinate: CLLocationCoordinate2D) {
        
        let startLocation = MKPlacemark(coordinate: startCoordinate)
        let destinateLocation = MKPlacemark(coordinate: destinateCoordinate)
        
        let request = MKDirections.Request()
        request.source = MKMapItem(placemark: startLocation)
        request.destination = MKMapItem(placemark: destinateLocation)
        request.transportType = .walking
        request.requestsAlternateRoutes = true
        
        let diraction = MKDirections(request: request)
        diraction.calculate(completionHandler: {(response, error) in
            if let error = error {
                print(error)
                return
            }
            guard let response = response else { self.alertError(title: "Error", message: "Маршрут не доступен!")
                return
            }
            var minRoute = response.routes[0]
            for route in response.routes {
                minRoute = (route.distance < minRoute.distance) ? route : minRoute
            }
            
            self.mapView.addOverlay(minRoute.polyline)
        })
    
    }
}
extension MapViewController: MKMapViewDelegate {
    func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
        let render = MKPolylineRenderer(overlay: overlay as! MKPolyline)
        render.strokeColor = .green
        return render
    }
}

extension MapViewController {
    func setConstrain() {
        
        view.addSubview(mapView)
        NSLayoutConstraint.activate([
            mapView.topAnchor.constraint(equalTo: view.topAnchor, constant: 0),
            mapView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 0),
            mapView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: 0),
            mapView.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: 0)
        ])
        
        mapView.addSubview(addAdress)
        NSLayoutConstraint.activate([
            addAdress.topAnchor.constraint(equalTo: mapView.topAnchor, constant: 50),
            addAdress.trailingAnchor.constraint(equalTo: mapView.trailingAnchor, constant: -20),
            addAdress.heightAnchor.constraint(equalToConstant: 40),
            addAdress.widthAnchor.constraint(equalToConstant: 40)
        ])
        
        mapView.addSubview(resetButton)
        NSLayoutConstraint.activate([
            resetButton.bottomAnchor.constraint(equalTo: mapView.bottomAnchor, constant: -30),
            resetButton.trailingAnchor.constraint(equalTo: mapView.trailingAnchor, constant: -10),
            resetButton.heightAnchor.constraint(equalToConstant: 50),
            resetButton.widthAnchor.constraint(equalToConstant: 50)
        ])
        
        mapView.addSubview(routeButton)
        NSLayoutConstraint.activate([
            routeButton.bottomAnchor.constraint(equalTo: mapView.bottomAnchor, constant: -30),
            routeButton.leadingAnchor.constraint(equalTo: mapView.leadingAnchor, constant: 10),
            routeButton.heightAnchor.constraint(equalToConstant: 50),
            routeButton.widthAnchor.constraint(equalToConstant: 50)
        ])
    }
}
