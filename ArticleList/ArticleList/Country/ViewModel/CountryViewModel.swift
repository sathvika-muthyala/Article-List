//
//  CountryViewModel.swift
//  ArticleList
//
//  Created by sathvika muthyala on 9/18/25.
//

import UIKit

protocol CountryViewModelProtocol: AnyObject{
    var countryList: [Country] { get }
    var errorMessage: String? { get }
    func getDataFromServer<T: Decodable>(
        type: T.Type,
        closure: @escaping (NetworkState?) -> Void
    )
    func getCountryName(row: Int) -> String
    func getCount() -> Int
    func getCode(row: Int) -> String
    func getRegion(row: Int) -> String
    func getCapital(row: Int) -> String
}

class CountryViewModel: CountryViewModelProtocol {
    
    // MARK: - Properties
    var errorState: NetworkState?  
    var countryList: [Country] = []
    private var filteredList: [Country] = []
    private let networkManager: Network
    
    init(networkManager: Network = NetworkManager.shared) {
        self.networkManager = networkManager
    }
    
    // MARK: - Networking
    func getDataFromServer<T: Decodable>(
        type: T.Type,
        closure: @escaping (NetworkState?) -> Void
    ){
        networkManager.getData(from: Server.countryApi.rawValue) { [weak self] fetchedState in
            guard let self = self else { return }
            
            switch fetchedState {
            case .isLoading, .invalidURL, .errorFetchingData, .noDataFromServer:
                self.errorState = fetchedState
                
            case .success(let data):
                if let countries = self.networkManager.parse(data: data, type: [Country].self) {
                    self.countryList = countries
                    self.filteredList = countries
                } else {
                    self.errorState = .errorFetchingData
                }
            }
            
            DispatchQueue.main.async { closure(self.errorState) }
        }
    }


    
    // MARK: - Helpers
    func getCount() -> Int {
        return filteredList.count
    }
    
    func getCountryName(row: Int) -> String {
        guard row >= 0, row < filteredList.count else { return "" }
        return filteredList[row].countryName ?? ""
    }
    
    func getCode(row: Int) -> String {
        guard row >= 0, row < filteredList.count else { return "" }
        return filteredList[row].code ?? ""
    }
    
    func getRegion(row: Int) -> String {
        guard row >= 0, row < filteredList.count else { return "" }
        return filteredList[row].region ?? ""
    }
    
    func getCapital(row: Int) -> String {
        guard row >= 0, row < filteredList.count else { return "" }
        return filteredList[row].capital ?? ""
    }
    
    // MARK: - Filtering
    func filterCountries(query: String) {
        if query.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            filteredList = countryList
        } else {
            filteredList = countryList.filter {
                $0.countryName?.localizedCaseInsensitiveContains(query) ?? false ||
                $0.capital?.localizedCaseInsensitiveContains(query) ?? false ||
                $0.code?.localizedCaseInsensitiveContains(query) ?? false
            }
        }
    }
}
