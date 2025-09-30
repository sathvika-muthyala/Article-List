import Foundation

// MARK: - Protocol Definition
protocol Network {
    func getData(from serverUrl: String?) async throws -> Data
    func parse<T: Decodable>(data: Data?, type: T.Type) throws -> T
}

// MARK: - Protocol Definition
final class NetworkManager: Network {
    
    //  Singleton
    static let shared = NetworkManager()
    private init() {}
    
    private(set) var state: NetworkState = .isLoading
    
    // MARK: - Networking
    func getData(from serverUrl: String?) async throws -> Data {
        state = .isLoading
        // Validate the URL
        guard let apiUrl = serverUrl, let serverURL = URL(string: apiUrl) else {
            state = .invalidURL
            throw state
        }
        
        do {
            let (data, response) = try await URLSession.shared.data(from: serverURL)
            // Ensure we have a valid HTTP status
            guard let httpResponse = response as? HTTPURLResponse,
                  (200...299).contains(httpResponse.statusCode) else {
                state = .errorFetchingData
                throw state
            }
            // Ensure we received some data
            guard !data.isEmpty else {
                state = .noDataFromServer
                throw state
            }
            
            state = .success(data)
            return data
        } catch {
            state = .errorFetchingData
            throw state
        }
    }
    
    // MARK: - Parsing
    func parse<T: Decodable>(data: Data?, type: T.Type) throws -> T {
        guard let data = data else {
            state = .noDataFromServer
            throw state
        }
        do {
            let decoder = JSONDecoder()
            let decoded = try decoder.decode(T.self, from: data)
            state = .success(data)
            return decoded
        } catch {
            state = .decodingError(error)
            throw state
        }
    }
}
