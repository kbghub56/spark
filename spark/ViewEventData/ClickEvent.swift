import SwiftUI
import UIKit

struct ClickEvent: View {
    @EnvironmentObject var authViewModel: AuthViewModel
    @EnvironmentObject var eventsViewModel: EventsViewModel
    @State private var isLiked = false
    @State private var isShared = false
    @Binding var isPresented: Bool
    @State private var isFlagged = false // New state variable for flag icon
    @State private var showFlagAlert = false // New state variable for flag alert
    let event: EventAnnotation
    let onCompletion: () -> Void
    
    var body: some View {
        ZStack {
            VStack(spacing: 10) {
                VStack {
                        Image(getEventImage(event))
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(width: 250, height: 250)
                        Text("\(event.visibility ?? "Invite Status") invited at \(event.locTitle)" ?? "Location Title")
                            .font(.system(size: 15).bold())
                            .foregroundColor(.gray.opacity(0.6))
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .padding(.horizontal)
                        Text(event.title ?? "Event Name")
                            .font(.system(size: 21).bold())
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .padding(.horizontal)

                        Text(event.subtitle ?? "Description")
                            .font(.system(size: 15))
                            .foregroundColor(.gray.opacity(0.6))
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .lineLimit(nil)
                            .fixedSize(horizontal: false, vertical: true)
                            .padding(.horizontal)
                    VStack(alignment: .leading) {
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
                                        .font(.system(size: 24))
                                        .scaleEffect(self.isLiked ? 1 : 1) //removed scale, assess this
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
                                        .font(.system(size: 24))
                                        .foregroundColor(.white)
                                }
                            }
                        }
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.horizontal)
                    
                    if !event.likedBy.filter({ eventsViewModel.friendsList.contains($0) && authViewModel.friendsBitmojiUrls.keys.contains($0) }).isEmpty {
                        HStack(spacing: 0) {
                            Text("Liked by")
                                .font(.system(size: 15).bold())
                                .foregroundColor(.gray.opacity(0.6))

                            Image(systemName: "heart.fill")
                                .foregroundColor(.red)
                                .font(.system(size: 15))
                            
                            HStack(spacing: -10) {
                                ForEach(event.likedBy.filter { eventsViewModel.friendsList.contains($0) && authViewModel.friendsBitmojiUrls.keys.contains($0) }, id: \.self) { userId in
                                    if let bitmojiUrl = authViewModel.friendsBitmojiUrls[userId], let url = URL(string: bitmojiUrl) {
                                        AsyncImage(url: url) { phase in
                                            switch phase {
                                            case .success(let image):
                                                image.resizable()
                                                    .aspectRatio(contentMode: .fill)
                                                    .frame(width: 15, height: 15) //changed 27-> 15, test this
                                                    .clipShape(Circle())
                                            case .failure(_):
                                                Circle().fill(Color.gray).frame(width: 15, height: 15)
                                            case .empty:
                                                ProgressView()
                                            @unknown default:
                                                EmptyView()
                                            }
                                        }
                                    }
                                }
                            }
                            
                            Text("& more")
                                .font(.system(size: 15).bold())
                                .foregroundColor(.gray.opacity(0.6))
                                .padding(.leading, 4)
                        }
                        .padding(.horizontal)
                    } else {
                        Text("liked by .... & more")
                            .font(.system(size: 15))
                            .foregroundColor(.red)
                        //.background(Color.black.opacity(0.9))
                            .padding(.horizontal)
                    }
                    HStack {
                        HStack(spacing: 5) {
                            Text(formatDateTime(event.startDate))
                                .font(.system(size: 15))
                                .foregroundColor(.gray.opacity(0.6))

                            Text("to")
                                .font(.system(size: 15))
                                .foregroundColor(.gray.opacity(0.6))
                            
                            Text(formatDateTime(event.endDate))
                                .font(.system(size: 15))
                                .foregroundColor(.gray.opacity(0.6))
                            Spacer()
                        }

                    HStack {
                        Button(action: {
                            withAnimation {
                                self.isFlagged.toggle()
                                if self.isFlagged {
                                    showFlagAlert = true
                                }
                            }
                        }) {
                            Image(systemName: self.isFlagged ? "flag.fill" : "flag")
                                .font(.system(size: 15))
                                .foregroundColor(self.isFlagged ? .white : .gray)
                        }
                        .alert(isPresented: $showFlagAlert) {
                            Alert(
                                title: Text("Event Flagged"),
                                message: Text("You have flagged this event. Our team will review it soon. Tap on the flag again to undo."),
                                dismissButton: .default(Text("OK"))
                            )
                        }
                        
                    }
                    }
                    .padding(.horizontal)
                    .padding(.bottom)

                }
            }
            .offset(y: -30)
            .frame(width: 385, height: 450)
            .background(Color.black.opacity(0.9))
            .cornerRadius(20)
            .modifier(EventPopupTransition(isPresented: isPresented, onCompletion: onCompletion))
        }
    }
    
    func getEventImage(_ event: EventAnnotation) -> String {
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
        let eventDetails = "\(event.title ?? "Event Title")\n" +
        "\(event.visibility ?? "Invite Status") invited\n" +
        "@ \(event.locTitle ?? "Location Title")\n" +
        "\(event.locSub ?? "Additional Location Info")\n" +
        "\(event.subtitle ?? "Description")\n\n" + "Sent from SparkRice⚡"
        
        let activityViewController = UIActivityViewController(activityItems: [eventDetails], applicationActivities: nil)
        
        if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
           let window = windowScene.windows.first {
            window.rootViewController?.present(activityViewController, animated: true, completion: nil)
        }
    }
    
    // Helper function to format the date and time
    private func formatDateTime(_ date: Date) -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MMM d, h:mm a"
        return dateFormatter.string(from: date)
    }
}
