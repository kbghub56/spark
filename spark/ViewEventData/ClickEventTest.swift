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
                HStack{
                    VStack(spacing: 15){
                        Text("Party at Martel Sundeck")
                            .font(.system(size: 20))
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity, alignment: .leading)
                        Text("Friends and Mutuals")
                            .font(.system(size: 17))
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity, alignment: .leading)
                        Text("Martel College, 99 Sunset Boullevard, Houston Texas 03042")
                            .font(.system(size: 17))
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity, alignment: .leading)
                        Text("Texas party. wear texas themed attire. make sure you have tickets before entering.")
                            .font(.system(size: 17))
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity, alignment: .leading)
                        Text("time")
                            .font(.system(size: 17))
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity, alignment: .leading)
                    }
                    Circle()
                        .fill(Color.white)
                        .frame(width: 100, height: 100)
                }.padding(.top, 32)
                    .padding(.horizontal, 24)
                Spacer()
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
                        .padding(.bottom, 32)
                        .padding(.horizontal, 24)

                    
                }
                .frame(width: 385, height: 450)
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
