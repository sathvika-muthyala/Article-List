import Foundation
protocol Network {
    func getData(from serverUrl: String?, closure: @escaping (NetworkState) -> Void)
    func parse<T: Decodable>(data: Data?, type: T.Type) -> Result<T, NetworkState>
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
    
    func parse<T: Decodable>(data: Data?, type: T.Type) -> Result<T, NetworkState> {
            guard let data = data else {
                return .failure(.noDataFromServer)
            }
            do {
                let decoder = JSONDecoder()
                let results = try decoder.decode(T.self, from: data)
                return .success(results)
            } catch {
                return .failure(.decodingError(error))
            }
        }
}
