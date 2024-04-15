//
//  SetTimeRS.swift
//  spark
//
//  Created by Kabir Borle on 2/27/24.
//

//README - this is a button meant to overlay the addevent screen

import SwiftUI

struct SetTime: View {
    @ObservedObject var viewModel: EventDateTimeViewModel
    @Binding var isShowingSetTimePopup: Bool
 //   @State private var endDate: Date = Date().addingTimeInterval(3 * 3600)
    
    var body: some View {
        VStack(spacing: 20) {
            Rectangle()
                .fill(Color.white)
                .frame(width: 390, height: 450)
                .border(Color.white, width: 1)
                .cornerRadius(50)
                .overlay(
                    VStack(spacing: 25) {
                        Text("Set Time")
                            .font(.system(size: 22))
                        
                        DatePicker(
                            "Start:",
                            selection: $viewModel.startTime,
                            in: Date()...,
                            displayedComponents: [.date, .hourAndMinute]
                        )
                        .datePickerStyle(DefaultDatePickerStyle())
                        .padding()
                        
                        DatePicker(
                            "End:",
                            selection: $viewModel.endTime,
                            in: viewModel.startTime...,
                            displayedComponents: [.date, .hourAndMinute]
                        )
                        .datePickerStyle(DefaultDatePickerStyle())
                        .padding()
                        
                        Button(action: {
                            viewModel.timeHasBeenSet = true
                            isShowingSetTimePopup = false
                        }) {
                            Text("Continue")
                                .font(.system(size: 17, weight: .bold))
                                .foregroundColor(.black)
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 15)
                                .background(Color.white)
                                .cornerRadius(40)
                                .padding(.top, 25)
                        }
                        .padding(.horizontal, 96)
                    }
                )
        }
    }
}

//struct SetTime_Previews: PreviewProvider {
//    static var previews: some View {
//        SetTime(viewModel: EventDateTimeViewModel())
//    }
//}
