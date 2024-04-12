//
//  initFriendsTester.swift
//  spark
//
//  Created by Kabir Borle on 4/11/24.
//

import SwiftUI

struct InitFriends2: View {
    @State private var isShared = false
        @State private var userInput: String = ""

        var body: some View {
            ZStack {
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

                    Text("Your link:")
                        .font(.system(size: 17))
                        .bold()
                        .foregroundColor(.white)

                    HStack {
                        Text("spark.sampleurl.123456789")
                            .font(.system(size: 17))
                            .foregroundColor(.white)
                            .multilineTextAlignment(.leading)
                            .padding(.trailing, 60)
                        
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

                    Text("Your SparkID:")
                        .font(.system(size: 17))
                        .bold()
                        .foregroundColor(.white)

                    Text("samplespa")
                        .font(.system(size: 17))
                        .foregroundColor(.white)
                        .multilineTextAlignment(.leading)
                        .padding(.trailing, 60)
                    
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
                    }

                    Button(action: {}) {
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
            }
            .padding(16)
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(.black)
        }
}

struct InitFriends2_Previews: PreviewProvider {
    static var previews: some View {
        InitFriends2()
    }
}
