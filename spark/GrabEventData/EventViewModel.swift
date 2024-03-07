//
//  EventViewModel.swift
//  spark
//
//  Created by Kabir Borle on 2/13/24.
//

import FirebaseDatabase
import FirebaseFirestore
import CoreLocation
import SwiftUI

class EventsViewModel: ObservableObject {
    @Published var allEvents: [Event] = []
    @Published var filteredEvents: [Event] = []
    @Published var forFriendsAndMutualsState: Bool = false
    
    private var authViewModel: AuthViewModel
    
    init(authViewModel: AuthViewModel) {
        self.authViewModel = authViewModel
        fetchEvents()
        fetchFriends() // Fetch the friends list
        fetchMutualFriends()
    }

//    private(set) var currentUserID: String? // This will be set via the initializer
    private var friendsList: [String] = [] // Assume this is populated accordingly
    private var mutualFriendsList: Set<String> = []

        // Call this method to fetch mutual friends
    // Method to fetch mutual friends
    func fetchFriends() {
        guard let currentUserID = authViewModel.currentUserID else { return }

        let db = Firestore.firestore()
        db.collection("users").document(currentUserID).getDocument { [weak self] (document, error) in
            guard let self = self, let document = document, error == nil else { return }
            if let currentUserFriends = document.data()?["friends"] as? [String] {
                DispatchQueue.main.async {
                    self.friendsList = currentUserFriends
                    // Once friendsList is updated, you might want to re-filter the events
                    self.filterEvents(forFriendsAndMutuals: self.forFriendsAndMutualsState)
                }
            }
        }
    }

    
    func fetchMutualFriends() {
        guard let currentUserID = authViewModel.currentUserID else { return }

        let db = Firestore.firestore()
        db.collection("users").document(currentUserID).getDocument { [weak self] (document, error) in
            guard let self = self, let document = document, error == nil else { return }
            if let currentUserFriends = document.data()?["friends"] as? [String] {
                self.fetchFriendsFriends(currentUserFriends: Set(currentUserFriends))
            }
        }
    }

    // Helper method to fetch each friend's friends and determine mutual friends
    private func fetchFriendsFriends(currentUserFriends: Set<String>) {
        let db = Firestore.firestore()

        for friendID in currentUserFriends {
            db.collection("users").document(friendID).getDocument { [weak self] (document, error) in
                guard let self = self, let document = document, error == nil else { return }
                if let friendFriends = document.data()?["friends"] as? [String] {
                    let mutualFriends = Set(friendFriends).intersection(currentUserFriends)
                    DispatchQueue.main.async {
                        self.mutualFriendsList.formUnion(mutualFriends)
                    }
                }
            }
        }
    }
    
    func fetchEvents() {
        let ref = Database.database().reference(withPath: "events")
        ref.observe(.value, with: { [weak self] snapshot in
            guard let self = self else { return }
            var newEvents: [Event] = []
            
            for child in snapshot.children {
                if let snapshot = child as? DataSnapshot,
                   let dict = snapshot.value as? [String: Any],
                   let title = dict["title"] as? String,
                   let description = dict["description"] as? String,
                   let startDate = dict["startDate"] as? TimeInterval,
                   let endDate = dict["endDate"] as? TimeInterval,
                   let latitude = dict["latitude"] as? Double,
                   let longitude = dict["longitude"] as? Double,
                   let visibility = dict["visibility"] as? String,
                   let organizerID = dict["organizerID"] as? String {  // Assuming organizerID is always present and is a String
                    
                    let event = Event(id: snapshot.key, title: title, description: description, startDate: Date(timeIntervalSince1970: startDate), endDate: Date(timeIntervalSince1970: endDate), latitude: latitude, longitude: longitude, visibility: (Event.EventVisibility(rawValue: visibility) ?? .publicEvent).rawValue, organizerID: organizerID)
                    
                    // Now use the synchronous shouldIncludeEvent check
                    if self.shouldIncludeEvent(event) {
                        newEvents.append(event)
                    }
                }
            }
            
            DispatchQueue.main.async {
                self.allEvents = newEvents
                self.filterEvents(forFriendsAndMutuals: self.forFriendsAndMutualsState)
            }
        })
    }


    func filterEvents(forFriendsAndMutuals: Bool) {
        self.forFriendsAndMutualsState = forFriendsAndMutuals // Update the internal state
        
        if forFriendsAndMutuals {
            filteredEvents = allEvents.filter { event in
                event.organizerID == authViewModel.currentUserID || isFriend(event.organizerID) || mutualFriendsList.contains(event.organizerID)
            }
            print("FOR YOU")
            //print(allEvents)
            print(mutualFriendsList)
        } else {
            filteredEvents = allEvents
            print("ALL")
        }
    }



    func shouldIncludeEvent(_ event: Event) -> Bool {
        guard let currentUserID = authViewModel.currentUserID else { return false }

       // Check if the event is posted by the current user
       if event.organizerID == currentUserID {
           return true
       }

        if event.visibility == .publicEvent || isFriend(event.organizerID) {
            return true
        } else if event.visibility == .friendsAndMutuals {
            return isMutualFriend(event.organizerID)
        }
        return false
    }


    private func isFriend(_ userID: String) -> Bool {
        return friendsList.contains(userID)
    }

    private func isMutualFriend(_ userID: String) -> Bool {
        mutualFriendsList.contains(userID)
    }
    
//    func updateCurrentUserID(_ userID: String?) {
//        print(userID)
//            self.currentUserID = userID
//        print("UPDATED CURRENT USER ID")
//            //fetchEvents()  // Refetch events if needed
//        }

}
        

