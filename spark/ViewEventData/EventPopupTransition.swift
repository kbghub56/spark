//
//  EventPopupTransition.swift
//  spark
//
//  Created by Kabir Borle on 4/8/24.
//

import SwiftUI

struct EventPopupTransition: ViewModifier {
    let isPresented: Bool
    let onCompletion: () -> Void
    
    func body(content: Content) -> some View {
        content
        //    .opacity(isPresented ? 1 : 0)
            .animation(.easeInOut(duration: 0.1), value: isPresented)
            .onChange(of: isPresented) { newValue in
                if !newValue {
                    // Call the completion closure when the pop-up is fully faded out
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                        onCompletion()
                    }
                }
            }
    }
}
