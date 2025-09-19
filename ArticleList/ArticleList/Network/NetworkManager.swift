import Foundation
protocol Network {
    func getData(from serverUrl: String?, closure: @escaping (NetworkState) -> Void)
    func parse<T: Decodable>(data: Data?, type: T.Type) -> T?
}

class NetworkManager: Network {
    
    static let shared = NetworkManager()
    private init() {}
    
    var state: NetworkState = .isLoading
    
    func getData(from serverUrl: String?, closure: @escaping (NetworkState) -> Void) {
        guard let apiUrl = serverUrl, let serverURL = URL(string: apiUrl) else {
            state = .invalidURL
            closure(state)
            return
        }
        
        URLSession.shared.dataTask(with: serverURL) { [weak self] data, response, error in
            guard let self = self else { return }
            
            if error != nil {
                self.state = .errorFetchingData
                closure(self.state)
                return
            }
            
            guard let data = data else {
                self.state = .noDataFromServer
                closure(self.state)
                return
            }
            
            self.state = .success(data)
            closure(self.state)
        }.resume()
    }
    
    func parse<T: Decodable>(data: Data?, type: T.Type) -> T? {
        guard let data = data else {
            print("No data to parse")
            return nil
        }
        do {
            let decoder = JSONDecoder()
            let fetchedResult = try decoder.decode(T.self, from: data)
            return fetchedResult
        } catch {
            print("Decoding error:", error)
            return nil
        }
    }
}
