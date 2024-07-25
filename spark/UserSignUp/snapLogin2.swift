//
//  snapLogin2.swift
//  spark
//
//  Created by Kabir Borle on 4/4/24.
//

import SwiftUI
import FirebaseFirestore

struct SnapAvatar2: View {
    @EnvironmentObject var authViewModel: AuthViewModel
    
    var body: some View {
        GeometryReader { geometry in
            ZStack {
                Color.black.edgesIgnoringSafeArea(.all)
                
                VStack {
                    Text("Your bitmoji is your in app avatar")
                        .font(.largeTitle)
                        .bold()
                        .foregroundColor(.white)
                        .multilineTextAlignment(.center)
                        .padding()
                        .padding(.horizontal, 32)
                    
                    Spacer()
                    
                    if let bitmojiUrl = authViewModel.snapchatBitmojiWalkingUrl {
                        AsyncImage(url: URL(string: bitmojiUrl)) { image in
                            image
                                .resizable()
                                .aspectRatio(contentMode: .fit)
                                .frame(width: 200, height: 200)
                        } placeholder: {
                            ProgressView()
                                .frame(width: 200, height: 200)
                        }
                    } else {
                        Text("Loading Bitmoji...")
                            .font(.title)
                            .foregroundColor(.white)
                    }
                    
                    Spacer()
                    
                    Button(action: {                        
                        authViewModel.completeSignUp()
                    }) {
                        Text("Continue")
                            .font(.system(size: 17, weight: .bold))
                            .foregroundColor(.black)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 15)
                            .background(.white)
                            .cornerRadius(40)
                            .padding(.top, 25)
                            .padding(.horizontal, 32)
                            .offset(y:-20)
                    }
                    
                    
                }
            }
        }
    }
}

struct SnapAvatar2_Previews: PreviewProvider {
    static var previews: some View {
        SnapAvatar2()
    }
}
