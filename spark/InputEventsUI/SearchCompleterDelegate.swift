//
//  SearchCompleterDelegate.swift
//  spark
//
//  Created by Kabir Borle on 2/12/24.
//

import MapKit

class SearchCompleterDelegate: NSObject, MKLocalSearchCompleterDelegate {
    var didUpdateResults: (([MKLocalSearchCompletion]) -> Void)?
    var didFailWithError: ((Error) -> Void)?
    
    func completerDidUpdateResults(_ completer: MKLocalSearchCompleter) {
        didUpdateResults?(completer.results)
    }
    
    func completer(_ completer: MKLocalSearchCompleter, didFailWithError error: Error) {
        didFailWithError?(error)
    }
}

class EventInputViewModel: ObservableObject {
    @Published var searchResults: [MKLocalSearchCompletion] = []
}
