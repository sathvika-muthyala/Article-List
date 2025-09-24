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
    
    var errorState: NetworkState?  
    var countryList: [Country] = []
    private var filteredList: [Country] = []
    private let networkManager: Network
    
    init(networkManager: Network = NetworkManager.shared) {
        self.networkManager = networkManager
    }
    
    func getDataFromServer<T: Decodable>(
        type: T.Type,
        closure: @escaping (NetworkState?) -> Void
    ) {
        networkManager.getData(from: Server.countryApi.rawValue) { [weak self] fetchedState in
            guard let self = self else { return }
            
            switch fetchedState {
            case .isLoading, .invalidURL, .errorFetchingData, .noDataFromServer:
                self.errorState = fetchedState
                
            case .success(let data):
                switch self.networkManager.parse(data: data, type: type) {
                case .success(let result):
                    if let countries = result as? [Country] {
                        self.countryList = countries
                        self.filteredList = countries
                        self.errorState = nil   // ✅ only success when we actually decoded countries
                    } else {
                        self.errorState = .decodingError(NSError(
                            domain: "Decoding",
                            code: -1,
                            userInfo: [NSLocalizedDescriptionKey: "Unexpected type decoded"]
                        ))
                    }
                case .failure(let parseError):
                    self.errorState = parseError
                }
                
            case .decodingError:
                self.errorState = fetchedState
            }
            
            DispatchQueue.main.async {
                closure(self.errorState)
            }
        }
    }

    func getCount() -> Int {
        return filteredList.count
    }
    
    func getCountry(row: Int) -> Country? {
        guard row >= 0, row < filteredList.count else { return nil }
        return filteredList[row]
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
    
    func deleteCountry(at index: Int) {
            guard index >= 0 && index < filteredList.count else { return }
            filteredList.remove(at: index)
        }
    
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

extension CountryViewModel {
    var errorMessage: String? {
        guard let errorState = errorState else { return nil }
        
        switch errorState {
        case .isLoading:
            return "Data Loading"
        case .invalidURL:
            return "Invalid URL"
        case .errorFetchingData:
            return "Error fetching data"
        case .noDataFromServer:
            return "No data from server"
        case .decodingError(let error):
            return "Decoding error: \(error.localizedDescription)"
        case .success:
            return nil
        }
    }
}

