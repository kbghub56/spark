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

    init(parent: MapViewRepresentable, authViewModel: AuthViewModel) {
        self.parent = parent
        self.authViewModel = authViewModel
    }
    
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        
        if let userLocation = annotation as? MKUserLocation {
                let identifier = "UserLocation"
                var view: MKAnnotationView
                
                if let dequeuedView = mapView.dequeueReusableAnnotationView(withIdentifier: identifier) {
                    dequeuedView.annotation = annotation
                    view = dequeuedView
                } else {
                    view = MKAnnotationView(annotation: annotation, reuseIdentifier: identifier)
                }
                
                // Set a placeholder image immediately
                view.image = UIImage(named: "placeholderImage")  // Ensure you have a placeholder image
                
                // Use the Bitmoji URL from the AuthViewModel
                if let bitmojiUrlString = authViewModel.snapchatBitmojiWalkingUrl, let bitmojiUrl = URL(string: bitmojiUrlString) {
                    URLSession.shared.dataTask(with: bitmojiUrl) { data, response, error in
                        guard let data = data, error == nil, let image = UIImage(data: data) else {
                            return
                        }
                        
                        DispatchQueue.main.async {
                            view.image = image
                            
                            // Apply a scale transform to the view to adjust the size
                            let scaleFactor: CGFloat = 0.5  // Adjust this scale factor to suit your needs
                            view.transform = CGAffineTransform(scaleX: scaleFactor, y: scaleFactor)
                            
                            // Force the map view to refresh this annotation view
                            mapView.removeAnnotation(userLocation)
                            mapView.addAnnotation(userLocation)
                        }
                    }.resume()
                }
                
                return view
            }
            // Handle other annotations...
    

        
        if let eventAnnotation = annotation as? EventAnnotation {
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
                    imageName = "EveryoneParty"
                case "Friends Only":
                    imageName = "FriendsOnly"
                case "Friends and Mutuals Only":
                    imageName = "FriendsAndMutuals"
                default:
                    imageName = "EveryoneParty"
                }
            
            if let image = UIImage(named: imageName) {
                // Define the target size of the image
                let targetSize = CGSize(width: 75, height: 56.25)  // Your desired size

                // Start an image context with the target size and no scaling
                UIGraphicsBeginImageContextWithOptions(targetSize, false, 0.0)

                // Draw the original image into the context with the target size
                image.draw(in: CGRect(origin: CGPoint.zero, size: targetSize))

                // Capture the resized image from the context
                let resizedImage = UIGraphicsGetImageFromCurrentImageContext()

                // End the image context
                UIGraphicsEndImageContext()

                // Set the resized image to the annotation view
                view.image = resizedImage
            }



            // Setup like button for each event annotation
            let likeButton = LikeButton(type: .custom)
            if let currentUserID = authViewModel.currentUserID {
                likeButton.isLiked = eventAnnotation.likedBy.contains(currentUserID)
            }
            likeButton.setImage(UIImage(systemName: "heart"), for: .normal)
            likeButton.frame = CGRect(x: 0, y: 0, width: 30, height: 30)
            likeButton.eventID = eventAnnotation.id
            likeButton.addTarget(self, action: #selector(handleLikeButtonTap(_:)), for: .touchUpInside)
            view.rightCalloutAccessoryView = likeButton

            return view

        } else if let friendAnnotation = annotation as? FriendAnnotation {
            let identifier = "FriendAnnotation"
            var view: MKMarkerAnnotationView

            if let dequeuedView = mapView.dequeueReusableAnnotationView(withIdentifier: identifier) as? MKMarkerAnnotationView {
                dequeuedView.annotation = friendAnnotation
                view = dequeuedView
            } else {
                view = MKMarkerAnnotationView(annotation: friendAnnotation, reuseIdentifier: identifier)
                view.canShowCallout = true
            }

           // view.pinTintColor = .blue // Set the pin color to blue for friend annotations

            return view
        } else {
            // Handle other types of annotations if necessary
            return nil
        }

       // return view
    }

    
    

    func mapView(_ mapView: MKMapView, annotationView view: MKAnnotationView, calloutAccessoryControlTapped control: UIControl) {
        print("Callout accessory tapped")

    }
    
    func mapView(_ mapView: MKMapView, regionDidChangeAnimated animated: Bool) {
            let zoomLevel = calculateZoomLevel(mapView: mapView)
            print("Current Zoom Level: \(zoomLevel)")
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


