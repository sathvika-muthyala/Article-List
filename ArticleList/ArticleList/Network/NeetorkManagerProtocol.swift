//
//  NeetorkManagerProtocol.swift
//  ArticleList
//
//  Created by sathvika muthyala on 9/9/25.
//

import Foundation

protocol NetworkManagerProtocol {
    func fetchData(from url: String, completion: @escaping (ArticleList?) -> Void)
    func fetchImage(from url: URL, completion: @escaping (Data?) -> Void)
}

