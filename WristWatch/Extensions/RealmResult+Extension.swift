//
//  RealmResult+Extension.swift
//  WristWatch
//
//  Created by Marcio Duarte on 2021-03-31.
//

import Foundation
import RealmSwift

/// Extension to convert Results to an array
extension Results {
    /// Return the result as an array
    func asList() -> [Element] {
        return compactMap {
            $0
        }
    }
}

