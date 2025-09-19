//
//  extensions.swift
//  ArticleList
//
//  Created by sathvika muthyala on 9/15/25.
//

import UIKit

extension UIViewController {
    func showAlert(title: String, message: String) {
        let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alertController.addAction(UIAlertAction(title: "OK", style: .default))
        self.present(alertController, animated: true)
    }
}


extension ArticleViewModel {
    var errorMessage: String? {
        guard let errorState = errorState else { return ""}
        switch errorState {
        case .isLoading:
            return "Data Loading"
        case .invalidURL:
            return "Invalid URL"
        case .errorFetchingData:
            return "Error fetching data"
        case .noDataFromServer:
            return "No data from server"
        default:
            return ""
            
        }
    }
}

extension CountryViewModel {
    var errorMessage: String? {
        guard let errorState = errorState else { return ""}
        switch errorState {
        case .isLoading:
            return "Data Loading"
        case .invalidURL:
            return "Invalid URL"
        case .errorFetchingData:
            return "Error fetching data"
        case .noDataFromServer:
            return "No data from server"
        default:
            return ""
            
        }
    }
}
