//
//  KeyBoardResponder.swift
//  spark
//
//  Created by Kabir Borle on 4/8/24.
//

import Combine
import SwiftUI

class KeyboardResponder: ObservableObject {
    private var cancellables: Set<AnyCancellable> = []
    @Published var currentHeight: CGFloat = 0

    init() {
        let keyboardWillShow = NotificationCenter.default.publisher(for: UIResponder.keyboardWillShowNotification)
            .map { $0.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? CGRect }
            .map { $0?.height ?? 0 }

        let keyboardWillHide = NotificationCenter.default.publisher(for: UIResponder.keyboardWillHideNotification)
            .map { _ in CGFloat(0) }

        Publishers.Merge(keyboardWillShow, keyboardWillHide)
            .subscribe(on: RunLoop.main)
            .assign(to: \.currentHeight, on: self)
            .store(in: &cancellables)
    }
}

