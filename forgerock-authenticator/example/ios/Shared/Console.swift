//
//  Copyright (c) 2022 ForgeRock. All rights reserved.
//
//  This software may be modified and distributed under the terms
//  of the MIT license. See the LICENSE file for details.
//

import Foundation

public func debugLog(_ object: Any?, file: String = #file, function: String = #function, line: Int = #line) {
    #if DEBUG
    let className = file.components(separatedBy: "/").last
    Swift.print("\(className!) : \(function) : \(line) : \(object ?? "")")
    #endif
}

public func debugLog(_ object: Any..., file: String = #file, function: String = #function, line: Int = #line) {
    #if DEBUG
    let className = file.components(separatedBy: "/").last
    for item in object {
        Swift.print("\(className!) : \(function) : \(line) : \(item)")
    }
    #endif
}
