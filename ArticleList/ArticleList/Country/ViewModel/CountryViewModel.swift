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
        type: T.Type
    ) async -> NetworkState?
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
        type: T.Type
    ) async -> NetworkState? {
        do {
            // 1. Fetch raw data
            let data = try await networkManager.getData(from: Server.countryApi.rawValue)
            do {
                let decoded = try networkManager.parse(data: data, type: type)

                if let countries = decoded as? [Country] {
                    self.countryList = countries
                    self.filteredList = countries
                    self.errorState = nil  
                } else {
                    self.errorState = .decodingError(NSError(
                        domain: "Decoding",
                        code: -1,
                        userInfo: [NSLocalizedDescriptionKey: "Unexpected type decoded"]
                    ))
                }
            } catch let parseError as NetworkState {
                self.errorState = parseError
            } catch {
                self.errorState = .decodingError(error)
            }

        } catch let networkError as NetworkState {
            self.errorState = networkError
        } catch {
            self.errorState = .errorFetchingData
        }

        return errorState
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

