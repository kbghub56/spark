//import SwiftUI
//
//struct SnapAvatar3: View {
//    @Environment(\.presentationMode) var presentationMode
//    @EnvironmentObject var authViewModel: AuthViewModel
//    
//    @State private var selectedAvatar: String?
//    
//    var body: some View {
//        ZStack {
//            Color.black.edgesIgnoringSafeArea(.all)
//            
//            VStack() {
//                Text("Default Avatar")
//                    .font(.largeTitle)
//                    .bold()
//                    .foregroundColor(.white)
//                    .multilineTextAlignment(.center)
//                    .padding()
//                    .padding(.vertical, 32)
//                
//                HStack(spacing: 32) {
//                    Button(action: {
//                        selectedAvatar = "DefaultMan"
//                    }) {
//                        ZStack {
//                            Color.white
//                                .frame(width: 150, height: 150)
//                                .cornerRadius(10)
//                            
//                            Image("DefaultMan")
//                                .resizable()
//                                .scaledToFit()
//                                .frame(height: 140)
//                                .clipped()
//                                .opacity(selectedAvatar == "DefaultMan" ? 1.0 : 0.5)
//                        }
//                    }
//                    
//                    Button(action: {
//                        selectedAvatar = "DefaultWoman"
//                    }) {
//                        ZStack {
//                            Color.white
//                                .frame(width: 150, height: 150)
//                                .cornerRadius(10)
//                            
//                            Image("DefaultWoman")
//                                .resizable()
//                                .scaledToFit()
//                                .frame(height: 140)
//                                .clipped()
//                                .opacity(selectedAvatar == "DefaultWoman" ? 1.0 : 0.5)
//                        }
//                    }
//                }
//                Spacer()
//            }
//            
//            VStack(spacing: 32) {
//                Spacer()
//                
//                Button(action: {
//                    if let selectedAvatar = selectedAvatar {
//                            authViewModel.updateUserDefaultAvatar(avatarName: selectedAvatar)
//                        }
//                }) {
//                    Text("Continue")
//                        .font(.system(size: 17))
//                        .foregroundColor(.black)
//                }
//                .frame(maxWidth: .infinity)
//                .padding(.vertical, 15)
//                .background(.white)
//                .cornerRadius(25)
//                .padding(.top, 25)
//                .padding(.horizontal, 64)
//                
//                Button(action: {
//                    self.presentationMode.wrappedValue.dismiss()
//                }) {
//                    Text("Login with Snapchat")
//                        .underline()
//                        .bold()
//                        .foregroundColor(.white)
//                }
//                .padding(.bottom)
//            }
//        }
//    }
//}
//
//struct SnapAvatar3_Previews: PreviewProvider {
//    static var previews: some View {
//        SnapAvatar3()
//    }
//}
