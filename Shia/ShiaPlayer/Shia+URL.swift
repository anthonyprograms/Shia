//
//  Shia+URL.swift
//  ShiaPlayer
//
//  Created by Anthony Williams on 10/8/17.
//  Copyright © 2017 Anthony Williams. All rights reserved.
//

extension URL {
    func queryStringComponents() -> [String: Any] {
        var dict = [String: AnyObject]()
        
        // Check for query string
        if let query = self.query {
            
            // Loop through pairings (separated by &)
            for pair in query.components(separatedBy: "&") {
                
                // Pull key, val from from pair parts (separated by =) and set dict[key] = value
                let components = pair.components(separatedBy: "=")
                if (components.count > 1) {
                    dict[components[0]] = components[1] as AnyObject?
                }
            }
            
        }
        
        return dict
    }
}
