//
//  FoodMapViewController.swift
//  Count on Us
//
//  Created by Tannar, Nathan on 2016-08-06.
//  Copyright © 2016 NathanTannar. All rights reserved.
//

import UIKit
import MapKit
import CoreLocation
import Parse

class ServicesViewController: UIViewController, MKMapViewDelegate, CLLocationManagerDelegate {
    
    @IBOutlet weak var mapView: MKMapView!
    
    var locationManager = CLLocationManager()
    var businesses = [PFObject]()
    var businessNames = [String]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Configure Navbar
        title = "Services Discounts"
        self.addLeftBarButtonWithImage(UIImage(named: "ic_menu_black_24dp")!)
        
        let listButton   = UIBarButtonItem(title: "List", style: .Plain, target: self, action: #selector(listButtonPressed))
        navigationItem.rightBarButtonItems = [listButton]
        
        // Location Services
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.requestWhenInUseAuthorization()
        locationManager.startUpdatingLocation()
        mapView.delegate = self
        mapView.showsBuildings = true
        mapView.showsUserLocation = true
        
        let query = PFQuery(className: PF_SERVICES_CLASS_NAME)
        query.findObjectsInBackgroundWithBlock { (objects: [PFObject]?, error: NSError?) in
            if error == nil {
                for object in objects! {
                    let anotation = MKPointAnnotation()
                    anotation.coordinate = CLLocation(latitude: object[PF_BUSINESS_LAT] as! Double, longitude: object[PF_BUSINESS_LONG] as! Double).coordinate
                    anotation.title = object[PF_BUSINESS_NAME] as? String
                    self.businessNames.append(object[PF_BUSINESS_NAME] as! String)
                    anotation.subtitle = object[PF_BUSINESS_INFO] as? String
                    self.businesses.append(object)
                    self.mapView.addAnnotation(anotation)
                }
            }
        }
    }
    
    // Called when the annotation was added
    func mapView(mapView: MKMapView, viewForAnnotation annotation: MKAnnotation) -> MKAnnotationView? {
        if annotation is MKUserLocation {
            return nil
        }
        
        let reuseId = "pin"
        var pinView = mapView.dequeueReusableAnnotationViewWithIdentifier(reuseId) as? MKPinAnnotationView
        if pinView == nil {
            pinView = MKPinAnnotationView(annotation: annotation, reuseIdentifier: reuseId)
            pinView?.animatesDrop = true
            pinView?.canShowCallout = true
            pinView?.draggable = false
            if #available(iOS 9.0, *) {
                pinView?.pinTintColor = SAP_COLOR
            }
            
            let rightButton: AnyObject! = UIButton(type: UIButtonType.DetailDisclosure)
            pinView?.rightCalloutAccessoryView = rightButton as? UIView
        }
        else {
            pinView?.annotation = annotation
        }
        
        return pinView
    }
    
    func mapView(mapView: MKMapView, annotationView view: MKAnnotationView, calloutAccessoryControlTapped control: UIControl) {
        if control == view.rightCalloutAccessoryView {
            let detailVC = BusinessDetailViewController()
            let businessName = view.annotation?.title
            let index = businessNames.indexOf(businessName!!)
            detailVC.business = businesses[index!]
            self.navigationController?.pushViewController(detailVC, animated: true)
        }
    }
    
    // Center Map on User
    func locationManager(manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        
        //Keeps map centered to users location
        let userLocation: CLLocation = locations[0]
        let latitude = userLocation.coordinate.latitude
        let longitude = userLocation.coordinate.longitude
        let latDelta:CLLocationDegrees = 0.02
        let lonDelta:CLLocationDegrees = 0.02
        
        let span:MKCoordinateSpan = MKCoordinateSpanMake(latDelta, lonDelta)
        
        let location:CLLocationCoordinate2D = CLLocationCoordinate2DMake(latitude, longitude)
        
        let region:MKCoordinateRegion = MKCoordinateRegionMake(location, span)
        
        mapView.setRegion(region, animated: true)
    }
    
    func listButtonPressed(sender: UIBarButtonItem) {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let listVC = storyboard.instantiateViewControllerWithIdentifier("ListViewController") as! ListViewController
        listVC.businesses = self.businesses
        listVC.className = PF_SERVICES_CLASS_NAME
        self.navigationController?.pushViewController(listVC, animated: true)
    }
    
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
}


