//
//  NetworkManager.swift
//  iPoll
//
//  Created by Evans Owamoyo on 19.03.2022.
//

import Foundation
import Alamofire

protocol NetworkServiceProtocol {
    func getUser(completion: @escaping (Result<User, IPollError>) -> Void)
    func createPoll(_ poll: Poll, completion: @escaping (Result<Poll, IPollError>) -> Void)
}

class NetworkService {
    // MARK: private variables
    private static var userId: String?
    private var user: User?
    private let baseUrl = "https://llopi.herokuapp.com/v1"
    private var usersEndpoint: String {
        "\(baseUrl)/users"
    }
    
    private var pollsEndpoint: String {
        "\(baseUrl)/poll"
    }
    
    private var requestHeader: HTTPHeaders? {
        if let userId = NetworkService.userId {
            return [HTTPHeader(name: "user_id", value: userId)]
        } else {
            return nil
        }
    }
    
    private init() {}
    
    // single instance
    public static let shared = NetworkService()
    
    // MARK: public functions
    
    /// Reads id from the KeyChain and sets it \
    /// If `id` does not exist in the keychain, it gets the UUID of the device
    /// and sets it as `id` in the KeyChain
    public static func configure() {
        self.userId = "12345"
    }
    
    public func getUser(completion: @escaping (Result<User, IPollError>) -> Void) {
        AF.request(usersEndpoint,
                   headers: requestHeader)
            .validate(statusCode: [200, 201])
            .responseDecodable(of: User.self) { response in
                switch response.result {
                    case .success(let user):
                        completion(.success(user))
                    case .failure(_):
                        completion(.failure(IPollError(message: response.description)))
                }
            }
    }
    
    public func createPoll(title: String, options: [String], completion: @escaping (Result<Poll, IPollError>) -> Void) {
        let params = ["title": title, "options": options] as [String : Any]
        AF.request(pollsEndpoint,method: .post, parameters: params, headers: requestHeader).validate(statusCode: [200, 201])
            .responseDecodable(of: Poll.self) { result in
                print(result.result)
            }
    }
    
}
