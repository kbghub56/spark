//
//  AddFriends1RS.swift
//  spark
//
//  Created by Kabir Borle on 2/28/24.
//

import SwiftUI
import CoreImage.CIFilterBuiltins
// Utility function to generate a QR code suitable for dark mode by inverting colors
func generateDarkModeQRCode(from string: String) -> UIImage {
    let context = CIContext()
    let filter = CIFilter.qrCodeGenerator()
    filter.message = Data(string.utf8)
    
    if let qrCodeImage = filter.outputImage,
       let invertedImage = qrCodeImage.inverted(),
       let cgImage = context.createCGImage(invertedImage, from: invertedImage.extent) {
        return UIImage(cgImage: cgImage)
    }

    return UIImage(systemName: "xmark.circle") ?? UIImage()
}

extension CIImage {
    func inverted() -> CIImage? {
        guard let filter = CIFilter(name: "CIColorInvert") else { return nil }
        filter.setValue(self, forKey: "inputImage")
        return filter.outputImage
    }
}

struct AddFriends: View {
    @EnvironmentObject var userManager: UserManager
    @State private var searchUserID = ""
    @State private var foundUser: User?
    @State private var errorMessage: String?
    @State private var isShowingResults = false
    @State private var shouldNavigate = false
    @ObservedObject private var keyboard = KeyboardResponder()
    @State private var isShared = false
    @State private var sparkID: String = ""
    @Binding var showingAddFriendView: Bool // Add this line
    @State private var isShowingAddFrTwo = false // Add this line
    @Environment(\.presentationMode) var presentationMode



    var userID: String = "UserUniqueIdentifier"
    var qrCodeImage: UIImage {
        let urlString = "https://example.com/user/\(userID)"
        return generateDarkModeQRCode(from: urlString)
    }
    
    var body: some View {
    NavigationView {
        
        ZStack {
            Color.black.edgesIgnoringSafeArea(.all)
            
            VStack(spacing: 30) {
//                VStack(spacing: 5) {
//                    HStack {
//                        Text(userManager.currentUser?.uniqueUserID ?? "No ID")
//                            .font(.system(size: 17))
//                            .foregroundColor(.white)
//                            .multilineTextAlignment(.leading)
//                            .padding(.trailing, 60)
//                        
//                        Spacer()
//                        
//                        ZStack {
//                            VStack {
//                                Button(action: {
//                                    withAnimation {
//                                        self.isShared.toggle()
//                                    }
//                                }) {
//                                    Image(systemName: "square.and.arrow.up")
//                                        .font(.system(size: 24))
//                                        .foregroundColor(.white)
//                                }
//                            }
//                        }
//                    }
//                }
//                
//                .padding(.horizontal, 16)
                
                VStack(spacing:5){
                    HStack {
                        Text("Spark-ID: \(userManager.currentUser?.uniqueUserID ?? "")")
                            .font(.system(size: 17))
                            .foregroundColor(.white)
                            .multilineTextAlignment(.leading)
                            .padding(.trailing, 60)
                        
                        Spacer()
                        
                        ZStack {
                            VStack {
                                Button(action: {
                                    withAnimation {
                                        self.isShared.toggle()
                                    }
                                }) {
                                    Image(systemName: "square.and.arrow.up")
                                        .font(.system(size: 24))
                                        .foregroundColor(.white)
                                }
                            }
                        }
                    }
                }
                .padding(.horizontal, 16)
                
                Image(uiImage: generateDarkModeQRCode(from: "UserSpecificString"))
                    .resizable()
                    .interpolation(.none)
                    .scaledToFit()
                    .cornerRadius(50)
                    .padding(.horizontal, 16)
                    .overlay(
                        VStack {
                            Spacer()
                            Image(systemName: "lock.fill")
                                .font(.title)
                                .foregroundColor(.white)
                            Text("coming soon ...")
                                .font(.subheadline)
                                .foregroundColor(.white)
                            Spacer()
                        }
                    ).frame(maxWidth: .infinity)

                
                Text("Add Friend:")
                    .font(.system(size: 20, weight: .bold))
                    .foregroundColor(.white)
                
                VStack {
                    TextField("Spark-ID", text: $searchUserID)
                        .padding(.horizontal, 32)
                        .frame(height: 50)
                        .background(Color.white)
                        .cornerRadius(50)
                        .foregroundColor(.black)
                        .padding(.horizontal, 32)
                    
                    if let errorMessage = errorMessage {
                        Text(errorMessage)
                            .foregroundColor(.red)
                            .font(.caption)
                            .padding(.top, 4)
                    }
                }
                
                Button(action: {
                    searchForUser()
                }) {
                    Text("Continue")
                        .font(.system(size: 17, weight: .bold))
                        .foregroundColor(.black)
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, 15)
                .background(.white)
                .cornerRadius(25)
                .padding(.horizontal, 32)
                .padding(.top, 25)
                
            }
            
            
            .padding(.horizontal, 32)
//            if let errorMessage = errorMessage {
//                                Text(errorMessage)
//                                    .foregroundColor(.red)
//                                    .frame(maxWidth: .infinity, alignment: .leading)
//                                    .padding(.leading, 32)
//                                    .padding(.top, 16)
//                            }
        }
    }
    .sheet(isPresented: $isShowingAddFrTwo) {
                AddFrTwo(foundUser: foundUser, userManager: userManager, isPresented: $isShowingAddFrTwo)
                    .onDisappear {
                        presentationMode.wrappedValue.dismiss()
                    }
            }

        }
        
    func searchForUser() {
        shouldNavigate = false
        isShowingResults = false
        
        userManager.searchForUser(by: searchUserID) { result in
            switch result {
            case .success(let user):
                foundUser = user
                errorMessage = nil
                isShowingAddFrTwo = true // Present AddFrTwo using a sheet
            case .failure(let error):
                errorMessage = error.localizedDescription
                foundUser = nil
            }
            isShowingResults = true
        }
    }
}



//struct AddFriends_Previews: PreviewProvider {
//    static var previews: some View {
//        AddFriends().environmentObject(UserManager())
//    }
//}
//// Extension to invert QR code colors for dark mode


//// An intermediary view to forward the user object to the actual destination
//struct IntermediaryView: View {
//    var foundUser: User?
//    var userManager: UserManager
//
//    var body: some View {
//        // Directly load AddFrTwo view with the foundUser
//        // This is assuming AddFrTwo can handle a nil foundUser appropriately
//        AddFrTwo(foundUser: foundUser, userManager: userManager)
//    }
//}
