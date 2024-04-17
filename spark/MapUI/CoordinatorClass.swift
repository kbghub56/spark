//
//  CoordinatorClass.swift
//  spark
//
//  Created by Kabir Borle on 2/25/24.
//

import SwiftUI
import MapKit
import FirebaseFirestore
import FirebaseAuth



class Coordinator: NSObject, MKMapViewDelegate {
    var parent: MapViewRepresentable
    var authViewModel: AuthViewModel
    var userLocationView: MKAnnotationView?
    var eventAnnotationView: MKAnnotationView?
    var zoomLevel = 0.0
    
    
    init(parent: MapViewRepresentable, authViewModel: AuthViewModel) {
        self.parent = parent
        self.authViewModel = authViewModel
    }
    
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        print("[MDB] TRIGGER MAP VIEW")
        if let userLocation = annotation as? MKUserLocation {
            print("[MDB] USER LOCATION")
            let identifier = "UserLocation"
            var view: MKAnnotationView
            
            if let dequeuedView = mapView.dequeueReusableAnnotationView(withIdentifier: identifier) {
                dequeuedView.annotation = annotation
                view = dequeuedView
            } else {
                view = MKAnnotationView(annotation: annotation, reuseIdentifier: identifier)
            }
            
            
            Task.detached {
                while self.authViewModel.snapchatBitmojiWalkingUrl == nil {
                    try! await Task.sleep(nanoseconds: 10000)
                }
                
                print("GET WALK URL: \(self.authViewModel.snapchatBitmojiWalkingUrl)")
                
                // Use the Bitmoji URL from the AuthViewModel
                if let bitmojiUrlString = self.authViewModel.snapchatBitmojiWalkingUrl, let bitmojiUrl = URL(string: bitmojiUrlString) {
                    print("[MDB] GET BITMOJI")
                    URLSession.shared.dataTask(with: bitmojiUrl) { data, response, error in
                        guard let data = data, error == nil, let image = UIImage(data: data) else {
                            return
                        }
                        
                        DispatchQueue.main.async {
                            view.image = image
                            
                            // Apply a scale transform to the view to adjust the size
                            //   self.updateScaleFactorFor(view: view, at: self.zoomLevel)
                            
                            print("UPDATING BITMOJI (KB CODES)")
                            
                            // Force the map view to refresh this annotation view
                            //                            mapView.removeAnnotation(userLocation)
                            //                            mapView.addAnnotation(userLocation)
                            
                            print("Set")
                        }
                    }.resume()
                }
            }
            
            self.userLocationView = view
            
            return view
        }
        
        if let friendAnnotation = annotation as? FriendAnnotation {
            print("[KB] FRIEND ANNOTATION")
            let identifier = "FriendAnnotation"
            var view: MKAnnotationView
            
            if let dequeuedView = mapView.dequeueReusableAnnotationView(withIdentifier: identifier) {
                dequeuedView.annotation = annotation
                view = dequeuedView
            } else {
                view = MKAnnotationView(annotation: annotation, reuseIdentifier: identifier)
                view.canShowCallout = false
            }
            
            Task.detached {
                while self.authViewModel.friendsBitmojiWalkingUrls == [:] {
                    try! await Task.sleep(nanoseconds: 100000)
                }
                
                // Assume FriendAnnotation has a 'userId' property to match keys in friendsBitmojiWalkingUrls
                if let userId = friendAnnotation.title,
                   let bitmojiUrlString = self.authViewModel.friendsBitmojiWalkingUrls[userId],
                   let bitmojiUrl = URL(string: bitmojiUrlString) {
                    
                    URLSession.shared.dataTask(with: bitmojiUrl) { data, response, error in
                        guard let data = data, error == nil, let image = UIImage(data: data) else {
                            return
                        }
                        
                        DispatchQueue.main.async {
                            view.image = image
                            self.updateScaleFactorFor(view: view, at: self.zoomLevel)

                        }
                    }.resume()
                }
            }
            
            return view
        }
        
        
        if let eventAnnotation = annotation as? EventAnnotation {
            print("[KB] TRIGGER EVENT ANNOTATION")
            let identifier = "EventAnnotation"
            var view: MKAnnotationView
            
            if let dequeuedView = mapView.dequeueReusableAnnotationView(withIdentifier: identifier) {
                dequeuedView.annotation = annotation
                view = dequeuedView
            } else {
                view = MKAnnotationView(annotation: annotation, reuseIdentifier: identifier)
                view.canShowCallout = true
            }
            
            let imageName: String
            switch eventAnnotation.visibility {
            case "Everyone":
                imageName = "EveryoneBare"
            case "Friends Only":
                imageName = "FriendsBare"
                view.transform = CGAffineTransform(scaleX: 0.8, y: 0.8)

            case "Friends and Mutuals Only":
                imageName = "FriendsAndMutualsBare"
            default:
                imageName = "EveryoneBare"
            }
            
            if let image = UIImage(named: imageName) {
                view.image = image
                
                // Adjust the frame of the view to make the image smaller
                let newSize = CGSize(width: image.size.width * 0.5, height: image.size.height * 0.5) // Adjust the scaling factor (0.75) as needed
                view.frame = CGRect(origin: view.frame.origin, size: newSize)
                
                
                
                self.updateScaleFactorFor(view: view, at: self.zoomLevel)
            }
            
            
            self.eventAnnotationView = view
            view.canShowCallout = false
            
            return view
        }
        
        else {
            // Handle other types of annotations if necessary
            return nil
        }
        
        // return view
    }
    
    func mapView(_ mapView: MKMapView, annotationView view: MKAnnotationView, calloutAccessoryControlTapped control: UIControl) {
        print("Callout accessory tapped")
    }
    
    func mapView(_ mapView: MKMapView, regionDidChangeAnimated animated: Bool) {
        self.zoomLevel = calculateZoomLevel(mapView: mapView)
        print("Current Zoom Level: \(self.zoomLevel)")
        
        // Update user location view
        if let userLocationView = self.userLocationView {
            updateScaleFactorFor(view: userLocationView, at: self.zoomLevel)
        }
        
        // Iterate over all annotations to find event annotations and update their scale
        for annotation in mapView.annotations {
            if let view = mapView.view(for: annotation) as? MKAnnotationView, annotation is EventAnnotation {
                updateScaleFactorFor(view: view, at: self.zoomLevel)
            }
            
            if let view = mapView.view(for: annotation) as? MKAnnotationView, annotation is FriendAnnotation {
                updateScaleFactorFor(view: view, at: self.zoomLevel)
            }
            
        }
    }
    
    
    // Calculate and return the map's zoom level based on the longitude span of its current region
    private func calculateZoomLevel(mapView: MKMapView) -> Double {
        // The map's longitude delta represents the span of the visible region
        let longitudeDelta = mapView.region.span.longitudeDelta
        
        // You might adjust this formula based on what "zoom level" means for your application
        // This is a simple inverse relationship; smaller longitudeDelta means more zoomed in
        let zoomLevel = log2(360 / longitudeDelta)
        
        return zoomLevel
    }
    
    func mapView(_ mapView: MKMapView, didSelect view: MKAnnotationView) {
        print("Annotation selected: \(String(describing: view.annotation?.title))")
        
        
        if let eventAnnotation = view.annotation as? EventAnnotation {
            // Find the corresponding Event based on the annotation's id
            //let event = parent.eventsViewModel.allEvents.first { $0.id == eventAnnotation.id }
            
            DispatchQueue.main.async {
               // withAnimation(.easeInOut(duration: 0.1)) {
                self.parent.selectedEvent = eventAnnotation
              //  }
            }
        }
        
        else if let friendAnnotation = view.annotation as? FriendAnnotation {
            DispatchQueue.main.async {
                // withAnimation(.easeInOut(duration: 0.1)) {
                self.parent.selectedFriend = friendAnnotation
                                //  }
            }
        }
        
        else if view.annotation is MKUserLocation {
                DispatchQueue.main.async {
                    self.parent.didSelectUserAnnotation = true
                    withAnimation {
                        self.parent.showMenu = true
                    }
                }
            }
        
        
        
        
    }

    func mapView(_ mapView: MKMapView, didDeselect view: MKAnnotationView) {
        if view.annotation is EventAnnotation {
            DispatchQueue.main.async {
                withAnimation(.easeInOut(duration: 0.1)) {
                    self.parent.selectedEvent = nil
                }
            }
        }
        else if view.annotation is FriendAnnotation {
            DispatchQueue.main.async {
                withAnimation(.easeInOut (duration: 0.1)){
                    self.parent.selectedFriend = nil
                }
            }
        }
    }

    @objc func handleLikeButtonTap(_ sender: LikeButton) {
        guard let currentUserID = Auth.auth().currentUser?.uid else {
            print("Current user ID not found")
            return
        }
        
        if let eventID = sender.eventID {
            print("Toggling like for event with ID: \(eventID)")
            sender.isLiked.toggle()  // Toggle the like state
            parent.eventsViewModel.likeEvent(eventID: eventID, currentUserID: currentUserID, isLiked: sender.isLiked)
        } else {
            print("Could not retrieve eventID from button")
        }
    }
    
    // Helper function to resize an image
    func resizeImage(image: UIImage, targetSize: CGSize) -> UIImage {
        let size = image.size
        
        let widthRatio  = targetSize.width  / size.width
        let heightRatio = targetSize.height / size.height
        
        // Figure out what our orientation is, and use that to form the rectangle
        var newSize: CGSize
        if(widthRatio > heightRatio) {
            newSize = CGSize(width: size.width * heightRatio, height: size.height * heightRatio)
        } else {
            newSize = CGSize(width: size.width * widthRatio,  height: size.height * widthRatio)
        }
        
        // This is the rect that we've calculated out and this is what is actually used below
        let rect = CGRect(x: 0, y: 0, width: newSize.width, height: newSize.height)
        
        // Actually do the resizing to the rect using the ImageContext stuff
        UIGraphicsBeginImageContextWithOptions(newSize, false, 1.0)
        image.draw(in: rect)
        let newImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        return newImage!
    }
    
    func updateScaleFactorFor(view: MKAnnotationView, at zoomLevel: Double) {
        let minZoom: Double = 10
        let maxZoom: Double = 15
        let minScale: CGFloat = 0.2
        let maxScale: CGFloat = 0.3
        
        var scaleFactor: CGFloat
        
        if zoomLevel <= minZoom {
            scaleFactor = minScale
        } else if zoomLevel >= maxZoom {
            scaleFactor = maxScale
        } else {
            // Linear interpolation between minScale and maxScale based on the zoom level
            let ratio = CGFloat((zoomLevel - minZoom) / (maxZoom - minZoom))
            scaleFactor = minScale + ratio * (maxScale - minScale)
        }
        
        // Apply the scale transform
        UIView.animate(withDuration: 0.25) {
            view.transform = CGAffineTransform(scaleX: scaleFactor, y: scaleFactor)
        }
    }
    
    
}

class LikeButton: UIButton {
    var eventID: String?
    var isLiked: Bool = false {
        didSet {
            self.setImage(UIImage(systemName: isLiked ? "heart.fill" : "heart"), for: .normal)
            self.tintColor = isLiked ? .red : .gray
        }
    }
}

