import SwiftUI
// DateFormatter extension remains unchanged
extension DateFormatter {
    static let timeFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateStyle = .none
        formatter.timeStyle = .short
        return formatter
    }()
}
struct AddEvents: View {
    @State private var eventName: String = ""
    @State private var eventDescription: String = ""
    @State private var location: String = "" // Corrected from using eventName for location
    @State private var selection: String?
    @State private var everyoneText: String = "Everyone"
    @State private var friendsAndMutualsText: String = "Friends and Mutuals Only"
    @State private var friendsOnlyText: String = "Friends Only"
    @ObservedObject var viewModel = EventDateTimeViewModel()
    var body: some View {
        NavigationView {
            ZStack {
                Rectangle()
                    .frame(width: 364, height: 612)
                    .foregroundColor(Color.black.opacity(0.8))
                    .cornerRadius(42)
                Rectangle()
                    .frame(width: 346, height: 596)
                    .foregroundColor(.black)
                    .cornerRadius(40)
                VStack(spacing: 25) {
                    Group {
                        Circle()
                            .frame(width: 30, height: 30)
                            .foregroundColor(Color(red: 0.99, green: 0.01, blue: 0.01).opacity(0.44))
                            .offset(x: 140, y: 120)
                        Rectangle()
                            .frame(width: 5, height: 20)
                            .background(Color.black)
                            .cornerRadius(90)
                            .rotationEffect(.degrees(-45))
                            .offset(x: 140, y: 70)
                        Rectangle()
                            .frame(width: 5, height: 20)
                            .background(Color.black)
                            .cornerRadius(90)
                            .rotationEffect(.degrees(45))
                            .offset(x: 140, y: 25)
                    }
                    Text("Add Event")
                        .font(.system(size: 48, weight: .bold))
                        .foregroundColor(.white)
                        .offset(x: 0, y: 10)
                    TextField("Event Name", text: $eventName)
                        .padding()
                        .frame(width: 274, height: 50)
                        .background(Color.gray)
                        .cornerRadius(10)
                        .foregroundColor(.white)
                    TextField("Theme, description, attire, etc.", text: $eventDescription)
                        .padding()
                        .frame(width: 274, height: 100)
                        .background(Color.gray)
                        .cornerRadius(10)
                        .foregroundColor(.white)
                    TextField("Location", text: $location)
                        .padding()
                        .frame(width: 274, height: 50)
                        .background(Color.gray)
                        .cornerRadius(10)
                        .foregroundColor(.white)
                    if viewModel.timeHasBeenSet {
                        VStack {
                            Text("Starts at \(viewModel.startTime, formatter: DateFormatter.timeFormatter)")
                                .foregroundColor(.white)
                            Button("Change") {
                                viewModel.isShowingSetTimeView = true
                            }
                            .font(.system(size: 12))
                            .foregroundColor(.blue)
                        }
                    } else {
                        Button("Set Time") {
                            viewModel.isShowingSetTimeView = true
                        }
                        .foregroundColor(.black)
                        .frame(width: 250, height: 75)
                        .background(Color.white)
                        .cornerRadius(40)
                    }
                    Text("Who's coming?")
                        .font(.system(size: 28, weight: .bold))
                        .foregroundColor(.white)
                        .offset(x: 0, y: -5)
                    VStack(alignment: .leading, spacing: 15) {
                        Button(action: {
                            selection = "Everyone"
                            everyoneText = "Let's Rage 🎉"
                            DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                                everyoneText = "Everyone"
                            }
                        }) {
                            HStack {
                                Image(systemName: selection == "Everyone" ? "largecircle.fill.circle" : "circle")
                                    .foregroundColor(.white)
                                Text(everyoneText)
                                    .font(.system(size: 18, weight: .bold))
                                    .foregroundColor(.white)
                                    .frame(minWidth: 0, maxWidth: .infinity, alignment: .leading) // Fixed width for the text
                            }
                        }
                        .frame(maxWidth: .infinity) // Ensuring the button takes full available width
                        .padding(.horizontal) // Optional, for padding on both sides if needed
                        .offset(x: 100)
                        Button(action: {
                            selection = "Friends and Mutuals Only"
                            friendsAndMutualsText = "Kickback 🤗"
                            DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                                friendsAndMutualsText = "Friends and Mutuals Only"
                            }
                        }) {
                            HStack {
                                Image(systemName: selection == "Friends and Mutuals Only" ? "largecircle.fill.circle" : "circle")
                                    .foregroundColor(.white)
                                Text(friendsAndMutualsText)
                                    .font(.system(size: 18, weight: .bold))
                                    .foregroundColor(.white)
                                    .frame(minWidth: 0, maxWidth: .infinity, alignment: .leading) // Fixed width for the text
                            }
                        }
                        .frame(maxWidth: .infinity) // Ensuring the button takes full available width
                        .padding(.horizontal) // Optional, for padding on both sides if needed
                        .offset(x: 100)
                        Button(action: {
                            selection = "Friends Only"
                            friendsOnlyText = "Small hangout 😄"
                            DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                                friendsOnlyText = "Friends Only"
                            }
                        }) {
                            HStack {
                                Image(systemName: selection == "Friends Only" ? "largecircle.fill.circle" : "circle")
                                    .foregroundColor(.white)
                                Text(friendsOnlyText)
                                    .font(.system(size: 18, weight: .bold))
                                    .foregroundColor(.white)
                                    .frame(minWidth: 0, maxWidth: .infinity, alignment: .leading) // Fixed width for the text
                            }
                        }
                        .frame(maxWidth: .infinity) // Ensuring the button takes full available width
                        .padding(.horizontal) // Optional, for padding on both sides if needed
                        .offset(x: 100)
                    }
                    Button(action: {
                        // Action for the Done button
                    }) {
                        Text("Done")
                            .font(.headline.weight(.bold))
                            .foregroundColor(.black)
                            .frame(width: 180, height: 60)
                            .background(Color.white)
                            .cornerRadius(60)
                    }
                }
            }
            .offset(y: -70)
            .frame(width: 430, height: 932)
            .background(.black)
            .navigationBarHidden(true)
        }
        .sheet(isPresented: $viewModel.isShowingSetTimeView) {
            SetTime(viewModel: viewModel)
        }
    }
}
struct AddEvents_Previews: PreviewProvider {
    static var previews: some View {
        AddEvents()
    }
}

