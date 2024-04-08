//
//  ClickEvent.swift
//  spark
//
//  Created by Kabir Borle on 3/28/24.
//

import SwiftUI
import UIKit

struct ClickEvent: View {
    @EnvironmentObject var authViewModel: AuthViewModel
    @EnvironmentObject var eventsViewModel: EventsViewModel
    @State private var isLiked = false
    @State private var isShared = false
    @Binding var isPresented: Bool
    let event: Event
    let onCompletion: () -> Void
    
    var body: some View {
        ZStack {
            VStack(spacing: 10) {
                Text(event.title ?? "Event Name")
                    .font(.system(size: 20))
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.horizontal, 24)
                Text(event.visibility ?? "Invite Status")
                    .font(.system(size: 17))
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.horizontal, 24)
                Text("\(event.locTitle)" ?? "Location Title")
                    .font(.system(size: 17))
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.horizontal, 24)
                Text(event.description ?? "Description")
                    .font(.system(size: 17))
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.horizontal, 24)
                
                // Display the corresponding emoji in the white circle
                HStack {
                    Spacer()
                    
                    VStack(spacing: 10) {
                                            HStack {
                                                Text("Start:")
                                                    .font(.system(size: 17))
                                                    .foregroundColor(.white)
                                                
                                                RoundedRectangle(cornerRadius: 10)
                                                    .fill(Color.white)
                                                    .frame(width: 110, height: 30)
                                                    .overlay(
                                                        Text(formatDate(event.startDate))
                                                            .font(.system(size: 14))
                                                            .foregroundColor(.black)
                                                    )
                                                
                                                RoundedRectangle(cornerRadius: 10)
                                                    .fill(Color.white)
                                                    .frame(width: 70, height: 30)
                                                    .overlay(
                                                        Text(formatTime(event.startDate))
                                                            .font(.system(size: 14))
                                                            .foregroundColor(.black)
                                                    )
                                            }
                                            
                                            HStack {
                                                Text("End:")
                                                    .font(.system(size: 17))
                                                    .foregroundColor(.white)
                                                
                                                RoundedRectangle(cornerRadius: 10)
                                                    .fill(Color.white)
                                                    .frame(width: 110, height: 30)
                                                    .overlay(
                                                        Text(formatDate(event.endDate))
                                                            .font(.system(size: 14))
                                                            .foregroundColor(.black)
                                                    )
                                                
                                                RoundedRectangle(cornerRadius: 10)
                                                    .fill(Color.white)
                                                    .frame(width: 70, height: 30)
                                                    .overlay(
                                                        Text(formatTime(event.endDate))
                                                            .font(.system(size: 14))
                                                            .foregroundColor(.black)
                                                    )
                                            }
                                        }
                    
                    Spacer()
                    
                    Image(getEventImage(event))
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: 100, height: 100)
                    
                    Spacer()
                }
                
                HStack(spacing: 30) {
                    VStack {
                        Button(action: {
                            self.isLiked.toggle() // Immediately toggle the visual state
                            
                            let currentUserID = self.authViewModel.currentUserID ?? ""
                            if self.isLiked {
                                eventsViewModel.likeEvent(eventID: event.id, currentUserID: currentUserID, isLiked: true)
                            } else {
                                eventsViewModel.unlikeEvent(eventID: event.id, currentUserID: currentUserID)
                            }
                        }) {
                            Image(systemName: self.isLiked ? "heart.fill" : "heart")
                                .font(.system(size: 24 * 1.5))
                                .scaleEffect(self.isLiked ? 1.5 : 1)
                                .foregroundColor(self.isLiked ? .red : .white)
                                .offset(y: 4)
                        }
                    }
                    .onAppear {
                        // Initialize the isLiked state when the view appears
                        self.isLiked = event.likedBy.contains(authViewModel.currentUserID ?? "")
                    }

                    VStack {
                        Button(action: {
                            withAnimation {
                                self.isShared.toggle()
                                shareEvent()
                            }
                        }) {
                            Image(systemName: "square.and.arrow.up")
                                .font(.system(size: 24 * 1.5))
                                //.scaleEffect(isShared ? 1.5 : 1)
                                .foregroundColor(.white)
                        }
                    }
                }
                
                // Display the Bitmojis of the user's friends who liked the event
                HStack(spacing: 0) {
                    Text("Liked by")
                        .font(.system(size: 12))
                        .foregroundColor(.white)
                    
                    Image(systemName: "heart.fill")
                        .foregroundColor(.red)
                        .font(.system(size: 12))
                    
                    HStack(spacing: -10) {
                        ForEach(event.likedBy.filter { eventsViewModel.friendsList.contains($0) && authViewModel.friendsBitmojiUrls.keys.contains($0) }, id: \.self) { userId in
                            if let bitmojiUrl = authViewModel.friendsBitmojiUrls[userId], let url = URL(string: bitmojiUrl) {
                                AsyncImage(url: url) { phase in
                                    switch phase {
                                    case .success(let image):
                                        image.resizable()
                                            .aspectRatio(contentMode: .fill)
                                            .frame(width: 27, height: 27)
                                            .clipShape(Circle())
                                    case .failure(_):
                                        Circle().fill(Color.gray).frame(width: 27, height: 27)
                                    case .empty:
                                        ProgressView()
                                    @unknown default:
                                        EmptyView()
                                    }
                                }
                            }
                        }
                    }
                    .onAppear {
                        // Initialize the isLiked state when the view appears
                        self.isLiked = event.likedBy.contains(authViewModel.currentUserID ?? "")
                        print("is it liked: \(self.isLiked)")
                    }
                    
                    Text("&more")
                        .font(.system(size: 12))
                        .foregroundColor(.white)
                        .padding(.leading, 4)
                }
                .padding(.top, 10)
            }
            .frame(width: 375, height: 405)
            .background(.black)
            .cornerRadius(25)
            .modifier(EventPopupTransition(isPresented: isPresented, onCompletion: onCompletion))
        }
    }
    
    func getEventImage(_ event: Event) -> String {
            switch event.visibility {
            case "Everyone":
                return "EveryoneParty"
            case "Friends and Mutuals Only":
                return "FriendsAndMutuals"
            case "Friends Only":
                return "FriendsOnly"
            default:
                return "EveryoneParty"
            }
        }
    
    func shareEvent() {
        let eventDetails = "\(event.title ?? "Event Name")\n\n" +
                           "Invite Status: \(event.visibility ?? "Invite Status")\n" +
                           "Location: \(event.locTitle ?? "Location Title")\n\n" +
                           "\(event.description ?? "Description")"
        
        let activityViewController = UIActivityViewController(activityItems: [eventDetails], applicationActivities: nil)
        
        if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
           let window = windowScene.windows.first {
            window.rootViewController?.present(activityViewController, animated: true, completion: nil)
        }
    }
    
    // Helper function to format the date
       private func formatDate(_ date: Date) -> String {
           let dateFormatter = DateFormatter()
           dateFormatter.dateFormat = "MMM d, yyyy"
           return dateFormatter.string(from: date)
       }
       
       // Helper function to format the time
       private func formatTime(_ date: Date) -> String {
           let dateFormatter = DateFormatter()
           dateFormatter.dateFormat = "h:mm a"
           return dateFormatter.string(from: date)
       }
}
