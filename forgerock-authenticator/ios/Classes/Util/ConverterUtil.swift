//
//  Copyright (c) 2022 ForgeRock. All rights reserved.
//
//  This software may be modified and distributed under the terms
//  of the MIT license. See the LICENSE file for details.
//

import Foundation

class ConverterUtil {
    
    /// Convert  JSON string to Dictionary
    /// - Throws: exception if JSON string cannot be converted to dictionary
    /// - Returns: Dictionary
    static func convertStringToDictionary(jsonString: String) -> [String:AnyObject]? {
        if let data = jsonString.data(using: .utf8) {
           do {
               let json = try JSONSerialization.jsonObject(with: data, options: .mutableContainers) as? [String:AnyObject]
               return json
           } catch {
               print("Something went wrong")
           }
        }
        return nil
    }

    /// Convert Dictionary to JSON string
    /// - Throws: exception if dictionary cannot be converted to JSON data or when data cannot be converted to UTF8 string
    /// - Returns: JSON string
    static func convertDictionaryToString(dictionary: [String: Any]) -> String? {
        if let theJSONData = try?  JSONSerialization.data(
          withJSONObject: dictionary,
          options: .prettyPrinted
          ),
          let jsonString = String(data: theJSONData, encoding: String.Encoding.utf8) {
            return jsonString
          }

        return nil
    }

}
