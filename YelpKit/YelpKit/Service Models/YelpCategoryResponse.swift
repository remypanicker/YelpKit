//
//  YelpCategoryResponse.swift
//  Eateries
//
//  Created by Kasey Schindler on 10/24/18.
//  Copyright © 2018 Curiously Creative, LLC. All rights reserved.
//

struct YelpCategoryResponse: Decodable {
    let categories: [YelpCategory]?
}