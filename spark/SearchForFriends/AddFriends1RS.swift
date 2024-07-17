//
//  AddFriends1RS.swift
//  spark
//
//  Created by Kabir Borle on 2/28/24.
//

import SwiftUI
import UIKit
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
    @State private var sparkID: String = ""
    @Binding var showingAddFriendView: Bool
    @State private var isShowingAddFrTwo = false
    @Environment(\.presentationMode) var presentationMode
    
    var userID: String = "UserUniqueIdentifier"
    var qrCodeImage: UIImage {
        let uniqueUserID = userManager.currentUser?.uniqueUserID ?? ""
        let urlString = "www.sparkapps.org/users/\(uniqueUserID)"
        return generateDarkModeQRCode(from: urlString)
    }
    var body: some View {
            ZStack {
                Color.black.edgesIgnoringSafeArea(.all)
                
                VStack(spacing: 30) {
                    VStack(spacing: 8) {
                        HStack {
                            let uniqueUserID = userManager.currentUser?.uniqueUserID ?? ""
                            let urlString = "www.sparkapps.org/users/" + uniqueUserID
                            Text("Your Link: \(urlString)")
                                .font(.system(size: 17))
                                .foregroundColor(.white) // Set the text color to white
                                .tint(.white)
                                .textSelection(.enabled) //disables directly clicking on own link
                            // .lineLimit(1) // Limit the text to a single line
                                .textContentType(.none) // Treat the text as plain text, not as a link
                                .multilineTextAlignment(.leading)
                                .padding(.trailing, 60)
                            
                            Spacer()
                            
                            ZStack {
                                VStack {
                                    ShareLink(item: "Add me: \(urlString)\n\nSent from SparkRice⚡") {
                                        Image(systemName: "square.and.arrow.up")
                                            .font(.system(size: 24))
                                            .foregroundColor(.white)
                                    }
                                }
                            }
                        }
                        HStack {
                            Text("Spark-ID: \(userManager.currentUser?.uniqueUserID ?? "")")
                                .font(.system(size: 17))
                                .foregroundColor(.white)
                                .multilineTextAlignment(.leading)
                                .textSelection(.enabled)
                                .padding(.trailing, 60)
                            
                            Spacer()
                            
                            ZStack {
                                VStack {
                                    ShareLink(item: "Add me: \(userManager.currentUser?.uniqueUserID ?? "")\n\nSent from SparkRice⚡") {
                                        Image(systemName: "square.and.arrow.up")
                                            .font(.system(size: 24))
                                            .foregroundColor(.white)
                                    }
                                }
                            }
                        }
                    }
                    .padding(.horizontal, 16)
                    
                    Image(uiImage: qrCodeImage)
                        .resizable()
                        .interpolation(.none)
                        .scaledToFit()
                        .cornerRadius(50)
                        .padding(.horizontal, 16)
                        .frame(maxWidth: .infinity)
                    
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
            }
        .sheet(isPresented: $isShowingAddFrTwo) {
            AddFrTwo(foundUser: foundUser, userManager: userManager, isPresented: $isShowingAddFrTwo)
                .onDisappear {
                    presentationMode.wrappedValue.dismiss()
                }
        }
    }
    
    func shareSparkID() {
        guard let sparkID = userManager.currentUser?.uniqueUserID else {
            print("No Spark ID available")
            return
        }
        let shareContent = "Add me: \(sparkID)\n\nSent from SparkRice⚡"
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
        let shareContent = "Add me: \(sparkLink)\n\nSent from SparkRice⚡"
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
    
    func searchForUser() {
        shouldNavigate = false
        isShowingResults = false
        
        // Check if the searchUserID is the same as the current user's uniqueUserID
        if let currentUserID = userManager.currentUser?.uniqueUserID, currentUserID == searchUserID {
            errorMessage = "Cannot add this Spark ID"
            foundUser = nil
            isShowingResults = true
            return
        }
        
        userManager.searchForUser(by: searchUserID) { result in
            switch result {
            case .success(let user):
                if user.isFullyLoaded() {
                                    foundUser = user
                                    errorMessage = nil
                                    isShowingAddFrTwo = true
                                } else {
                                    // User found but details not fully loaded
                                    errorMessage = "We had trouble finding your friend, please try again."
                                    foundUser = nil
                                }
            case .failure(let error):
                errorMessage = error.localizedDescription
                foundUser = nil
            }
            isShowingResults = true
        }
    }
}
