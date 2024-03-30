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
        if annotation is MKUserLocation {
                return nil
            }

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
                    let targetSize = CGSize(width: 100, height: 100)  // Your desired size

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

