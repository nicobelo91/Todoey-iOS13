//
//  DataModel.swift
//  Todoey
//
//  Created by user183145 on 11/21/20.
//  Copyright © 2020 App Brewery. All rights reserved.
//

import Foundation

class Item: Codable {
    var title: String = ""
    var done: Bool = false
}
