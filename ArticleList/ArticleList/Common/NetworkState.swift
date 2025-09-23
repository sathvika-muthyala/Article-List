//
//  NetworkState.swift
//  ArticleList
//
//  Created by sathvika muthyala on 9/15/25.
//

import Foundation

enum NetworkState: Error {
    case isLoading
    case invalidURL
    case errorFetchingData
    case noDataFromServer
    case decodingError(Error)
    case success(Data)
}

