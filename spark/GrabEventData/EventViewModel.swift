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
    @Published var eventsForYou: [Event] = []

    
    private var authViewModel: AuthViewModel
    
    init(authViewModel: AuthViewModel) {
        self.authViewModel = authViewModel
        fetchEvents()
        fetchFriends {
            self.fetchMutualFriends()
        }
    }

//    private(set) var currentUserID: String? // This will be set via the initializer
    var friendsList: [String] = [] // Assume this is populated accordingly
    private var mutualFriendsList: Set<String> = []
    @Published var rankedEventsByFriendsLikes: [Event] = []

        // Call this method to fetch mutual friends
    // Method to fetch mutual friends
    func fetchFriends(completion: @escaping () -> Void) {
        guard let currentUserID = authViewModel.currentUserID else { return }

        let db = Firestore.firestore()
        db.collection("users").document(currentUserID).getDocument { [weak self] (document, error) in
            guard let self = self, let document = document, error == nil else { return }
            if let currentUserFriends = document.data()?["friends"] as? [String] {
                DispatchQueue.main.async {
                    self.friendsList = currentUserFriends
                    completion() // Call completion handler after updating the friends list
                }
            }
        }
    }


    
    func fetchMutualFriends() {
        let db = Firestore.firestore()
        var allPotentialMutuals = Set<String>() // To store all friends of friends

        // Loop through each friend to get their friends
        for friendID in friendsList {
            db.collection("users").document(friendID).getDocument { [weak self] (document, error) in
                guard let self = self, let document = document, error == nil, let friendFriends = document.data()?["friends"] as? [String] else { return }

                let friendFriendsSet = Set(friendFriends).subtracting(self.friendsList) // Remove direct friends
                allPotentialMutuals = allPotentialMutuals.union(friendFriendsSet) // Union with the set of potential mutuals

                DispatchQueue.main.async {
                            self.mutualFriendsList = allPotentialMutuals.subtracting(Set(self.friendsList))
                            self.fetchEventsForYou() // Now call fetchEventsForYou here
                        }
            }
        }
    }
    
    func fetchEventsForYou() {
        eventsForYou = allEvents.filter { event in
            // Print statements for debugging
            print("Checking event: \(event.title)")
            
            if event.organizerID == authViewModel.currentUserID {
                print("Event added: User is the organizer.")
                return true
            }
            
            if isFriend(event.organizerID) {
                print("Event added: Organizer is a direct friend.")
                return true
            }
            
            if isMutualFriend(event.organizerID) && (event.visibility == "Everyone" || event.visibility == "Friends and Mutuals Only") {
                print("Event added: Organizer is a mutual friend with appropriate visibility.")
                return true
            }
            else{
                print(isMutualFriend(event.organizerID))
                print(event.visibility)
            }
            
            print("Event not added: Does not meet criteria.")
            return false
        }
        
        // Debugging print statement for the final list
        print("Events For You: \(eventsForYou.map { $0.title })")
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
                   let organizerID = dict["organizerID"] as? String {
                    
                    // Ensure the likedBy array is included when you fetch your events
                    let likedBy = dict["likedBy"] as? [String] ?? []
                    
                    let event = Event(id: snapshot.key, title: title, description: description, startDate: Date(timeIntervalSince1970: startDate), endDate: Date(timeIntervalSince1970: endDate), latitude: latitude, longitude: longitude, visibility: visibility, organizerID: organizerID, likedBy: likedBy)
                    
                    // Now use the synchronous shouldIncludeEvent check
                    if self.shouldIncludeEvent(event) {
                        newEvents.append(event)
                    }
                    print(event.visibility)
                }
            }
            
            DispatchQueue.main.async {
                self.allEvents = newEvents
               // print(self.allEvents)
                self.filterEvents(forFriendsAndMutuals: self.forFriendsAndMutualsState)
            }
        })
    }



    func filterEvents(forFriendsAndMutuals: Bool) {
        self.forFriendsAndMutualsState = forFriendsAndMutuals
        DispatchQueue.main.async {
            self.filteredEvents = forFriendsAndMutuals ? self.eventsForYou : self.allEvents
        }
    }




    func shouldIncludeEvent(_ event: Event) -> Bool {
        guard let currentUserID = authViewModel.currentUserID else { return false }

       // Check if the event is posted by the current user
       if event.organizerID == currentUserID {
           return true
       }

        if event.visibility == "Everyone" || isFriend(event.organizerID) {
            return true
        } else if event.visibility == "Friends and Mutuals Only" {
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
    
    func likeEvent(eventID: String, currentUserID: String, isLiked: Bool) {
        let eventRef = Database.database().reference(withPath: "events/\(eventID)")
        
        eventRef.runTransactionBlock({ (currentData: MutableData) -> TransactionResult in
            if var event = currentData.value as? [String: AnyObject],
               var likedBy = event["likedBy"] as? [String],
               let likes = event["likes"] as? Int {
                
                if isLiked {
                    if !likedBy.contains(currentUserID) {
                        likedBy.append(currentUserID)
                        event["likes"] = likes + 1 as AnyObject?
                    }
                } else {
                    if let index = likedBy.firstIndex(of: currentUserID) {
                        likedBy.remove(at: index)
                        event["likes"] = max(likes - 1, 0) as AnyObject?
                    }
                }
                
                event["likedBy"] = likedBy as AnyObject?
                currentData.value = event
                
                return TransactionResult.success(withValue: currentData)
            }
            return TransactionResult.success(withValue: currentData)
        }) { error, committed, snapshot in
            if let error = error {
                print("Error updating likes: \(error.localizedDescription)")
            }
            else{
                //self.rankEvents()
            }
        }
    }


    
    func calculateLikesFromFriends(for event: Event) -> Int {
        let friendsLikes = event.likedBy.filter { friendsList.contains($0) }.count
        return friendsLikes
    }

    
   
    
    var sortedEventsByLikesFromFriends: [Event] {
            allEvents.sorted {
                let firstLikes = $0.likedBy.filter { friendsList.contains($0) }.count
                let secondLikes = $1.likedBy.filter { friendsList.contains($0) }.count
                return firstLikes == secondLikes ? $0.title < $1.title : firstLikes > secondLikes
            }
        }
    

}
        

