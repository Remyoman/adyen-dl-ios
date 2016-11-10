//
//  Utils.swift
//  AdyenDL
//
//  Created by Oleg Lutsenko on 7/27/16.
//  Copyright © 2015 Adyen. All rights reserved.
//

import Foundation

extension Array where Element : Equatable {
    
    mutating func removeObject(_ object : Element) {
        if let index = self.index(of: object) {
            self.remove(at: index)
        }
    }
    
    mutating func removeObjects(_ objects : [Element]) {
        for object in objects {
            if let index = self.index(of: object) {
                self.remove(at: index)
            }
        }
    }
    
}

extension Dictionary {
    
    mutating func formUnion(
        _ dictionary: Dictionary<Key, Value>) {
        for (key, value) in dictionary {
            self[key] = value
        }
    }
    
    mutating func formUnion<S: Sequence>(_ sequence: S) where
        S.Iterator.Element == (Key,Value) {
        for (key, value) in sequence {
            self[key] = value
        }
    }
    
}

extension URL {
    
    static func queryStringWith(_ parameters: [String: String]) -> String {
        var queryString = ""
        let allowedCharacters = (NSMutableCharacterSet.urlHostAllowed as NSCharacterSet).mutableCopy() as! NSMutableCharacterSet
        allowedCharacters.removeCharacters(in: "+:=")
        for (key, value) in parameters {
            guard let value = value.addingPercentEncoding(withAllowedCharacters: allowedCharacters as CharacterSet) else {
                queryString = ""
                break
            }
            queryString = queryString + key + "=" + value + "&"
        }
        
        return queryString
    }
    
    func urlByAppending(_ parameters: Dictionary<String, String>) -> URL {
        let parametersQuery = URL.queryStringWith(parameters)
        let absoluteString = "\(self.absoluteString)\(self.query != nil ? "&" : "?")\(parametersQuery)"
        return URL(string: absoluteString) ?? self
    }
    
    func queryParameters() -> [String: String]? {
        let urlComponents = URLComponents(url: self, resolvingAgainstBaseURL: true)
        var parameters = [String: String]()
        _ = urlComponents?.queryItems?.map({parameters[$0.name] = ($0.value ?? "")})
        return parameters
    }
    
}

extension NSMutableURLRequest {
    
    func setHTTPBodyWith(_ parameters: [String: String]) {
        let queryString = URL.queryStringWith(parameters)
        self.httpBody = queryString.data(using: String.Encoding.utf8)
    }
    
}
