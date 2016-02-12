//
//  Array+Remove.swift
//  OBD-II
//
//  Created by Manuel Leitold on 22.11.15.
//  Copyright © 2015 mani1337. All rights reserved.
//

import Foundation

extension Array {
    mutating func removeIndices(indices: [Int]) {
        var removed = 0
        for index in indices {
            self.removeAtIndex(index - (removed++))
        }
    }
}
