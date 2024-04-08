//
//  ClickEventTest.swift
//  spark
//
//  Created by Kabir Borle on 4/9/24.
//

import SwiftUI

struct ClickEvent2: View {
    @State private var isLiked = false
    @State private var isShared = false
    @State private var isBookmarked = false
    
    var body: some View {
        ZStack {
            VStack (spacing: 10){
                Text("Event Name")
                    .font(.system(size: 20))
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.horizontal, 24)
                Text("invite status")
                    .font(.system(size: 17))
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.horizontal, 24)
                Text("location")
                    .font(.system(size: 17))
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.horizontal, 24)
                Text("description")
                    .font(.system(size: 17))
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.horizontal, 24)
                Circle()
                    .fill(Color.white)
                    .frame(width: 100, height: 100)

                    HStack(spacing: 30) {
                        VStack {
                            Button(action: {
                                withAnimation {
                                    self.isLiked.toggle()
                                }
                            }) {
                                Image(systemName: isLiked ? "heart.fill" : "heart")
                                    .font(.system(size: 24 * 1.5))
                                    .scaleEffect(isLiked ? 1.5 : 1)
                                    .foregroundColor(isLiked ? .red : .white)
                                    .offset(y:4)
                            }
                        }
                        
                        VStack {
                            Button(action: {
                                withAnimation {
                                    self.isShared.toggle()
                                }
                            }) {
                                Image(systemName: "square.and.arrow.up")
                                    .font(.system(size: 24 * 1.5))
                                    .scaleEffect(isShared ? 1.5 : 1)
                                    .foregroundColor(.white)
                            }
                        }
                        
                    }
                    Text("if >0 friends liked display profiles of mutuals")
                        .font(.system(size: 17))
                        .foregroundColor(.white)
                        .padding()
                    
                    
                    Button(action: {
                        print("Done button tapped")                 }) {
                            Text("Done")
                                .foregroundColor(.black)                         .font(.system(size: 17))
                                .padding()                         .background(Color.white)
                                .cornerRadius(10)
                                .scaleEffect(0.8)
                        }
                }
                .frame(width: 390, height: 450)
                .background(.black)
                .cornerRadius(50)
            }
            .frame(width: 430, height: 932)
            .background(.white)
    }
}

struct ClickEvent2_Previews: PreviewProvider {
    static var previews: some View {
        ClickEvent2()
    }
}
