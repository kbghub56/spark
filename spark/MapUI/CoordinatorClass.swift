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
        
        if let friendAnnotation = annotation as? FriendAnnotation {
                let identifier = "Friend"
                var view: MKMarkerAnnotationView
                if let dequeuedView = mapView.dequeueReusableAnnotationView(withIdentifier: identifier) as? MKMarkerAnnotationView {
                    dequeuedView.annotation = friendAnnotation
                    view = dequeuedView
                } else {
                    view = MKMarkerAnnotationView(annotation: friendAnnotation, reuseIdentifier: identifier)
                    view.canShowCallout = true
                }
                view.markerTintColor = UIColor.blue // Set a custom color for friend annotations
                return view
            }


        let identifier = "annotation"
        var view: MKMarkerAnnotationView

        if let dequeuedView = mapView.dequeueReusableAnnotationView(withIdentifier: identifier) as? MKMarkerAnnotationView {
            dequeuedView.annotation = annotation
            view = dequeuedView
        } else {
            view = MKMarkerAnnotationView(annotation: annotation, reuseIdentifier: identifier)
            view.canShowCallout = true
            view.calloutOffset = CGPoint(x: -5, y: 5)
            
            // Check if the annotation is an EventAnnotation
            if annotation is EventAnnotation {
                // Set up a "Like" button as the right callout accessory view
                let likeButton = UIButton(type: .contactAdd) // Use your preferred button type or image
                view.rightCalloutAccessoryView = likeButton
            } else {
                view.rightCalloutAccessoryView = UIButton(type: .detailDisclosure)
            }
        }

        // Customize the annotation view based on the annotation title
        if let title = annotation.title as? String, title.contains("Friend") {
            view.markerTintColor = .green
            view.glyphImage = UIImage(systemName: "person.fill")
        } else if let title = annotation.title as? String, title.contains("Event") {
            view.markerTintColor = .red
            view.glyphImage = UIImage(systemName: "star.fill")
        } else {
            // Default color for any other annotations
            view.markerTintColor = .purple
        }
        
        if let eventAnnotation = annotation as? EventAnnotation {
            let likeButton = LikeButton(type: .custom)
                // Set the initial like state based on whether the current user has liked the event
            if let currentUserID = authViewModel.currentUserID {
                likeButton.isLiked = eventAnnotation.likedBy.contains(currentUserID)
            }
            likeButton.setImage(UIImage(systemName: "heart"), for: .normal)  // Example using SF Symbols
            likeButton.frame = CGRect(x: 0, y: 0, width: 30, height: 30)
            likeButton.eventID = eventAnnotation.id
            likeButton.addTarget(self, action: #selector(handleLikeButtonTap(_:)), for: .touchUpInside)
            view.rightCalloutAccessoryView = likeButton
        }


        print("Y#Y#Y#Y#Y#Y")
        return view
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

