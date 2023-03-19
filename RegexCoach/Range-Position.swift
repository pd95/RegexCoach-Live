//
//  Range-Position.swift
//  RegexCoach
//
//  Created by Philipp on 19.03.23.
//

import Foundation

extension Range<String.Index> {
    func position(in string: String) -> String {
        let start = string.distance(from: string.startIndex, to: lowerBound)
        let end = string.distance(from: string.startIndex, to: upperBound)
        return "\(start)-\(end)"
    }
}
