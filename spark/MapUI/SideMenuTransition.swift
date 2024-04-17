//
//  SideMenuTransition.swift
//  spark
//
//  Created by Kabir Borle on 4/16/24.
//

import Foundation
import SwiftUI

struct SideMenuTransition: ViewModifier {
    let isPresented: Bool
    let onCompletion: () -> Void
    
    func body(content: Content) -> some View {
        content
            .animation(.easeInOut(duration: 0.1), value: isPresented)
            .onChange(of: isPresented) { newValue in
                if !newValue {
                    // Call the completion closure when the side menu is fully faded out
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                        onCompletion()
                    }
                }
            }
    }
}
