////
////  GrabEventDataGPT.swift
////  spark
////
////  Created by Kabir Borle on 2/27/24.
////
//
////
////  EventViewModel.swift
////  spark
////
////  Created by Kabir Borle on 2/13/24.
////
//
//import FirebaseDatabase
//import FirebaseFirestore
//import CoreLocation
//import SwiftUI
//
//class EventsViewModel: ObservableObject {
//    @Published var events: [Event] = []
//    private(set) var currentUserID: String? // This will be set via the initializer
//    private var friendsList: [String] = [] // Assume this is populated accordingly
//
//    // Modify the initializer to have an optional currentUserID parameter
//    init(currentUserID: String? = nil) {
//        self.currentUserID = currentUserID
//        fetchEvents()
//    }
//
//    func fetchEvents() {
//        let ref = Database.database().reference(withPath: "events")
//        ref.observe(.value, with: { [weak self] snapshot in
//            guard let self = self else { return }
//            var newEvents: [Event] = []
//
//            let group = DispatchGroup() // Create a DispatchGroup to track the completion of asynchronous tasks
//            print("working1")
//            for child in snapshot.children {
//                print("supcuh")
//                if let snapshot = child as? DataSnapshot,
//                   let dict = snapshot.value as? [String: Any],
//                   let title = dict["title"] as? String,
//                   let description = dict["description"] as? String,
//                   let startDate = dict["startDate"] as? TimeInterval,
//                   let endDate = dict["endDate"] as? TimeInterval,
//                   let latitude = dict["latitude"] as? Double,
//                   let longitude = dict["longitude"] as? Double,
//                   let visibility = dict["visibility"] as? String,
//                   let organizerID = dict["organizerID"] as? Optional ?? "defaultOrganizerID" {
//
//                    print("working2")
//                    let event = Event(id: snapshot.key, title: title, description: description, startDate: Date(timeIntervalSince1970: startDate), endDate: Date(timeIntervalSince1970: endDate), latitude: latitude, longitude: longitude, visibility: (Event.EventVisibility(rawValue: visibility) ?? .publicEvent).rawValue, organizerID: organizerID)
//
//                    group.enter() // Enter the group before starting the asynchronous task
//                    self.shouldIncludeEvent(event) { includeEvent in
//                        if includeEvent {
//                            newEvents.append(event)
//                            print("added")
//                        }
//                         // Leave the group once the asynchronous task is complete
//                    }
//                    group.leave()
//                }
//            }
//
//            group.notify(queue: .main) { // This block is executed once all asynchronous tasks are complete
//                self.events = newEvents
//            }
//        })
//    }
//
//
//    private func shouldIncludeEvent(_ event: Event, completion: @escaping (Bool) -> Void) {
//        guard self.currentUserID != nil else {
//            print("1")
//            completion(false)
//            return
//        }
//
//        // Public events are visible to everyone.
//        if event.visibility == .publicEvent {
//            print("2")
//            completion(true)
//            return
//        }
//
//        // For friends-only events, check if the organizer is a friend of the current user.
//        if event.visibility == .friendsOnly {
//            print("3")
//            completion(isFriend(event.organizerID))
//            return
//        }
//
//        // For events visible to friends and mutuals, check if the organizer is a friend.
//        if isFriend(event.organizerID) {
//            print("4")
//            completion(true)
//        } else if event.visibility == .friendsAndMutuals {
//            print("5")
//            // If the organizer is not a direct friend, check for mutual friendship.
//            isMutualFriend(event.organizerID) { isMutual in
//                completion(isMutual)
//            }
//        } else {
//            print("6")
//            // If none of the above conditions are met, the event should not be included.
//            completion(false)
//        }
//    }
//
//
//    private func isFriend(_ userID: String) -> Bool {
//        print(friendsList.contains(userID))
//        return friendsList.contains(userID)
//    }
//
//    private func isMutualFriend(_ userID: String, completion: @escaping (Bool) -> Void) {
//        guard let currentUserID = self.currentUserID, !friendsList.isEmpty else {
//            completion(false)
//            return
//        }
//
//        let db = Firestore.firestore()
//        var checksRemaining = friendsList.count
//        var foundMutualFriend = false // Flag to indicate if a mutual friend has been found
//
//        for friendID in friendsList {
//            db.collection("users").document(friendID).getDocument { documentSnapshot, error in
//                checksRemaining -= 1
//
//                if foundMutualFriend { return } // Skip further processing if a mutual friend has already been found
//
//                if let document = documentSnapshot, error == nil,
//                   let friendFriendsList = document.data()?["friends"] as? [String], friendFriendsList.contains(userID) {
//                    foundMutualFriend = true
//                    completion(true)
//                    return
//                }
//
//                if checksRemaining == 0 && !foundMutualFriend {
//                    completion(false)
//                }
//            }
//        }
//    }
//
//    func updateCurrentUserID(_ userID: String?) {
//        print(userID)
//            self.currentUserID = userID
//        print("UPDATED CURRENT USER ID")
//            //fetchEvents()  // Refetch events if needed
//        }
//
//}
//
////
////  EventModel.swift
////  spark
////
////  Created by Kabir Borle on 2/24/24.
////
//
//import SwiftUI
//
//struct Event: Identifiable {
//    let id: String
//    let title: String
//    let description: String
//    let startDate: Date
//    let endDate: Date
//    let latitude: Double
//    let longitude: Double
//    let visibility: EventVisibility
//    let organizerID: String
//
//    enum EventVisibility: String {
//        case publicEvent = "public"
//        case friendsOnly = "friends"
//        case friendsAndMutuals = "friendsAndMutuals"
//    }
//
//    init(id: String, title: String, description: String, startDate: Date, endDate: Date, latitude: Double, longitude: Double, visibility: String, organizerID: String) {
//        self.id = id
//        self.title = title
//        self.description = description
//        self.startDate = startDate
//        self.endDate = endDate
//        self.latitude = latitude
//        self.longitude = longitude
//        self.visibility = EventVisibility(rawValue: visibility) ?? .publicEvent
//        self.organizerID = organizerID
//    }
//}
//
//
////
////  EventDateTimeViewModelRS.swift
////  spark
////
////  Created by Kabir Borle on 2/27/24.
////
//
//import SwiftUI
//class EventDateTimeViewModel: ObservableObject {
//    @Published var startTime: Date = Date()
//    @Published var endTime: Date = Date()
//    @Published var isShowingSetTimeView: Bool = false
//    @Published var timeHasBeenSet: Bool = false // Add this line
//}
//
