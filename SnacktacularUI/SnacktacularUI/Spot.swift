//
//  Spot.swift
//  SnacktacularUI
//
//  Created by Roi Jacob on 7/27/25.
//

import Foundation
import FirebaseFirestore

struct Spot: Identifiable, Codable {
    @DocumentID var id: String?
    var name = ""
    var address = ""
}
