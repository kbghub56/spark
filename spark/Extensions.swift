//
//  Extensions.swift
//  spark
//
//  Created by Rahul Shah on 6/19/24.
//

import UIKit

extension UIApplication {
    func endEditing() {
        sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
    }
}
