//
//  Router.swift
//  MovieVault
//
//  Created by Mohammad Shariq on 10/09/25.
//

import Foundation


final class Router: ObservableObject {
    struct Target: Identifiable, Equatable { let id: Int }

    @Published var target: Target?

    //Trims the URL and Generate Target Object to open a page with desired specifications
    func handle(url: URL) {

        guard url.scheme == "MovieVault" else {
            return
        }
        let path = url.path.trimmingCharacters(in: CharacterSet(charactersIn: "/"))
        let parts = path.split(separator: "/").map(String.init)
        if parts.count == 2,
           parts[0].lowercased() == "movie",
           let id = Int(parts[1]) {
            target = Target(id: id)
        }
    }

}
