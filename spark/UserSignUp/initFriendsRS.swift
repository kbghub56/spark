import SwiftUI

struct InitFriends: View {
    @State private var isPressed = false // State to handle button press animation
    @State private var userInput = ""
    @StateObject private var foundUserData = FoundUserData()
    @State private var errorMessage: String?
    @State private var isShowingSheet = false
    @EnvironmentObject var userManager: UserManager
    @State private var isShowingResults = false
    @Environment(\.presentationMode) var presentationMode

    @State private var keyboardHeight: CGFloat = 0

    var body: some View {
        ZStack {
            Color.black.ignoresSafeArea()

            VStack(alignment: .leading, spacing: 32.5) {
                HStack {
                    Spacer()
                    Text("Let's check on your friends")
                        .font(.largeTitle)
                        .bold()
                        .foregroundColor(.white)
                        .multilineTextAlignment(.center)
                    Spacer()
                }
                .padding(.top, 16)

                Text("Keep in mind your friends can see what you're up to - this is for that group chat and those friends.")
                    .font(.system(size: 17))
                    .foregroundColor(.gray)
                    .multilineTextAlignment(.leading)

                let uniqueUserID = userManager.currentUser?.uniqueUserID ?? ""
                let urlString = "www.sparkapps.org/users/" + uniqueUserID

                Text("Your link:")
                    .font(.system(size: 17))
                    .bold()
                    .foregroundColor(.white)

                HStack {
                    Text(urlString)
                        .font(.system(size: 17))
                        .foregroundColor(.white)
                        .multilineTextAlignment(.leading)
                        .padding(.trailing, 60)
                        .textSelection(.enabled)

                    ZStack {
                        VStack {
                            ShareLink(item: "add me: \(urlString)\n\nsent from SparkRice⚡") {
                                Image(systemName: "square.and.arrow.up")
                                    .font(.system(size: 24))
                                    .foregroundColor(.white)
                            }
                        }
                    }
                }

                Text("Your SparkID:")
                    .font(.system(size: 17))
                    .bold()
                    .foregroundColor(.white)

                HStack {
                    Text(userManager.currentUser?.uniqueUserID ?? "Not Found")
                        .font(.system(size: 17))
                        .foregroundColor(.white)
                        .multilineTextAlignment(.leading)
                        .padding(.trailing, 60)
                        .textSelection(.enabled)
                    //UNCOMMENT BELOW IF WANT TO INCLUDE SHARE BUTTON
                    //                        ZStack {
                    //                            VStack {
                    //                                Button(action: {
                    //                                    shareSparkID() // Call shareSparkID() when the button is tapped
                    //                                }) {
                    //                                    Image(systemName: "square.and.arrow.up")
                    //                                        .font(.system(size: 24))
                    //                                        .foregroundColor(.white)
                    //                                }
                    //                            }
                    //                        }
                }

                Text("Add a SparkID:")
                    .font(.system(size: 17))
                    .bold()
                    .foregroundColor(.white)

                HStack {
                    TextField("Optional", text: $userInput)
                        .foregroundColor(.black)
                        .padding(EdgeInsets(top: 16, leading: 16, bottom: 16, trailing: 16))
                        .background(.gray)
                        .cornerRadius(15)
                        .onTapGesture {
                            self.errorMessage = nil
                        }
                }

                if let errorMessage = errorMessage {
                    Text(errorMessage)
                        .foregroundColor(.red)
                        .font(.system(size: 14))
                        .padding(.leading)
                }

                Button(action: {
                    if userInput.isEmpty {
                        presentationMode.wrappedValue.dismiss()
                    } else {
                        searchForUser()
                    }
                }) {
                    Text("Continue")
                        .font(.system(size: 17, weight: .bold))
                        .foregroundColor(.black)
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, 15)
                .background(.white)
                .cornerRadius(40)
                .padding(.top, 25)
            }
            .padding(.horizontal, 16)
            .padding(.bottom, keyboardHeight)
            .onTapGesture {
                self.hideKeyboard()
            }
            .onChange(of: isShowingSheet) { newValue in
                if newValue {
                    if let user = foundUserData.user {
                        print("Showing sheet with found user: \(user)")
                    } else {
                        print("foundUser is nil, not showing sheet")
                    }
                }
            }
            .sheet(isPresented: $isShowingSheet) {
                if let user = foundUserData.user {
                    AddFrTwo(foundUser: user, userManager: userManager, isPresented: $isShowingSheet)
                        .onDisappear {
                            presentationMode.wrappedValue.dismiss()
                        }
                }
            }
        }
        .onAppear {
            NotificationCenter.default.addObserver(forName: UIResponder.keyboardWillShowNotification, object: nil, queue: .main) { (notification) in
                if let keyboardFrame = notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? CGRect {
                    self.keyboardHeight = keyboardFrame.height
                }
            }
            NotificationCenter.default.addObserver(forName: UIResponder.keyboardWillHideNotification, object: nil, queue: .main) { (notification) in
                self.keyboardHeight = 0
            }
        }
    }

    // Search for user based on ID
    func searchForUser() {
        isShowingSheet = false

        // Check if the userInput is the same as the current user's uniqueUserID
        if let currentUserID = userManager.currentUser?.uniqueUserID, currentUserID == userInput {
            errorMessage = "Cannot add this Spark ID"
            foundUserData.user = nil
            isShowingSheet = false
            return
        }

        userManager.searchForUser(by: userInput) { result in
            switch result {
            case .success(let user):
                self.foundUserData.user = user
                self.errorMessage = nil
                self.isShowingSheet = true
                print("USERNAME: \(user.userName)")
            case .failure(let error):
                self.errorMessage = "Not a valid Spark ID. Please retry."
                self.isShowingSheet = false
                self.foundUserData.user = nil
            }
        }
    }

    func hideKeyboard() {
        UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
    }

    func shareSparkID() {
        guard let sparkID = userManager.currentUser?.uniqueUserID else {
            print("No Spark ID available")
            return
        }
        let shareContent = "add me: \(sparkID)\n\nsent from SparkRice⚡"
        let activityViewController = UIActivityViewController(activityItems: [shareContent], applicationActivities: nil)

        // Presenting the share sheet
        if let keyWindow = UIApplication.shared.keyWindow {
            if let presentedViewController = keyWindow.rootViewController?.presentedViewController {
                presentedViewController.present(activityViewController, animated: true, completion: nil)
            } else {
                keyWindow.rootViewController?.present(activityViewController, animated: true, completion: nil)
            }
        }
    }

    func shareSparkLink() {
        guard let sparkID = userManager.currentUser?.uniqueUserID else {
            print("No Spark ID available")
            return
        }
        let sparkLink = "www.sparkapps.org/users/\(sparkID)"
        let shareContent = "add me: \(sparkLink)\n\nsent from SparkRice⚡"
        let activityViewController = UIActivityViewController(activityItems: [shareContent], applicationActivities: nil)

        // Presenting the share sheet
        if let keyWindow = UIApplication.shared.keyWindow {
            if let presentedViewController = keyWindow.rootViewController?.presentedViewController {
                presentedViewController.present(activityViewController, animated: true, completion: nil)
            } else {
                keyWindow.rootViewController?.present(activityViewController, animated: true, completion: nil)
            }
        }
    }
}
