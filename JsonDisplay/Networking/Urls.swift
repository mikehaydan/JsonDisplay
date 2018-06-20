//
//  Urls.swift
//  ImageSearch
//
//  Created by Mike Haydan on 09/06/2018.
//  Copyright © 2018 Misha Apps. All rights reserved.
//

import Foundation

enum Urls {
    private static let baseUrlString: String = "https://api.tumblr.com"
    
    static let baseUrl: URL = URL(string: baseUrlString)!
    static let searchImage: String = "/v2/tagged"
}
