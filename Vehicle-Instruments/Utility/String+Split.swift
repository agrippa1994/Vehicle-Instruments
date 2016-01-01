//
//  String+Split.swift
//  OBD-II
//
//  Created by Manuel Stampfl on 22.11.15.
//  Copyright © 2015 mani1337. All rights reserved.
//

import Foundation

extension String {
    func split(chars: String) -> [String] {
        let characterSet = NSCharacterSet(charactersInString: chars)
        var tokens = self.componentsSeparatedByCharactersInSet(characterSet)
        
        // Get indices of strings which are empty
        var indicesToRemove = [Int]()
        for (id, token) in tokens.enumerate() {
            if token.isEmpty {
                indicesToRemove.append(id)
            }
        }
        
        tokens.removeIndices(indicesToRemove)
        return tokens
    }
}
