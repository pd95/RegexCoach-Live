//
//  Match.swift
//  RegexCoach
//
//  Created by Philipp on 19.03.23.
//

import Foundation

struct Match: Identifiable {
    var id = UUID()
    var text: String
    var position: String
    var groups: [Match]?
    var range: Range<String.Index>
    var replacement: String = ""
}
