//
//  CountryModel.swift
//  ArticleList
//
//  Created by sathvika muthyala on 9/18/25.
//

import Foundation

struct Country: Decodable{
    let capital: String?
    let code: String?
    let countryName: String?
    let region: String?
    
    enum CodingKeys: String, CodingKey {
        case capital = "capital"
        case code = "code"
        case countryName = "name"
        case region = "region"
    }
    
}
