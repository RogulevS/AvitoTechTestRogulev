//
//  Parser.swift
//  AvitoTechTestRogulev
//
//  Created by Rogulev Sergey on 24.10.2022.
//

import Foundation

struct Parser {
    
    func loadData<T: Decodable>(url: String, completion: @escaping (Result<T, Error>) -> Void) {
        guard let url = URL(string: Constants.Strings.urlString) else { return }
        let session = URLSession(configuration: URLSessionConfiguration.default)
        let request = URLRequest(url: url)
        session.dataTask(with: request) { data, response, error in
            if let error = error {
                completion(.failure(error))
            }
            if let data = data {
                do {
                    let result = try JSONDecoder().decode(T.self, from: data)
                    completion(.success(result))
                }
                catch {
                    completion(.failure(error))
                }
            }
        }.resume()
    }
}
    

