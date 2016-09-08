//
//  Utils.swift
//  AdyenDL
//
//  Created by Oleg Lutsenko on 7/27/16.
//  Copyright © 2015 Adyen. All rights reserved.
//

import Foundation

extension Array where Element : Equatable {
    
    mutating func removeObject(object : Element) {
        if let index = self.indexOf(object) {
            self.removeAtIndex(index)
        }
    }
    
    mutating func removeObjects(objects : [Element]) {
        for object in objects {
            if let index = self.indexOf(object) {
                self.removeAtIndex(index)
            }
        }
    }
    
}

extension Dictionary {
    
    mutating func formUnion(
        dictionary: Dictionary<Key, Value>) {
        for (key, value) in dictionary {
            self[key] = value
        }
    }
    
    mutating func formUnion<S: SequenceType where
        S.Generator.Element == (Key,Value)>(sequence: S) {
        for (key, value) in sequence {
            self[key] = value
        }
    }
    
}

extension NSURL {
    
    class func queryStringWith(parameters: [String: String]) -> String {
        var queryString = ""
        let allowedCharacters = NSMutableCharacterSet.URLHostAllowedCharacterSet().mutableCopy() as! NSMutableCharacterSet
        allowedCharacters.removeCharactersInString("+:=")
        for (key, value) in parameters {
            guard let value = value.stringByAddingPercentEncodingWithAllowedCharacters(allowedCharacters) else {
                queryString = ""
                break
            }
            queryString = queryString + key + "=" + value + "&"
        }
        
        return queryString
    }
    
    func urlByAppending(parameters: Dictionary<String, String>) -> NSURL {
        let parametersQuery = NSURL.queryStringWith(parameters)
        let absoluteString = "\(self.absoluteString)\(self.query != nil ? "&" : "?")\(parametersQuery)"
        return NSURL(string: absoluteString) ?? self
    }
    
    func queryParameters() -> [String: String]? {
        let urlComponents = NSURLComponents(URL: self, resolvingAgainstBaseURL: true)
        var parameters = [String: String]()
        _ = urlComponents?.queryItems?.map({parameters[$0.name] = ($0.value ?? "")})
        return parameters
    }
    
}

extension NSMutableURLRequest {
    
    func setHTTPBodyWith(parameters: [String: String]) {
        let queryString = NSURL.queryStringWith(parameters)
        self.HTTPBody = queryString.dataUsingEncoding(NSUTF8StringEncoding)
    }
    
}