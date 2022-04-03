//
//  NetworkManager.swift
//  iPoll
//
//  Created by Evans Owamoyo on 19.03.2022.
//

import Foundation
import Alamofire

protocol NetworkServiceProtocol: AnyObject {
    var baseUrl: String { get }
    func getUser(completion: @escaping (Result<User, IPollError>) -> Void)
    func createPoll(title: String, options: [String], completion: @escaping (Result<Poll, IPollError>) -> Void)
    func getPoll(_ id: String, completion: @escaping (Result<Poll, IPollError>) -> Void)
    func vote(pollId: String, optionId: String, completion: @escaping (Result<Poll, IPollError>) -> Void)
}

class NetworkService: NetworkServiceProtocol {
    
    init(url: String) {
        self.baseUrl = url
        configure()
    }
    
    // MARK: private variables
    private var userId: String? // id of this device

    private var user: User? // the user data with his polls

    internal let baseUrl: String // the base url for making api calls

    private var usersEndpoint: String {
        "\(baseUrl)/users"
    }

    private var pollsEndpoint: String {
        "\(baseUrl)/poll"
    }

    // required header for making api requests to server
    private var requestHeader: HTTPHeaders? {
        if let userId = userId {
            return [HTTPHeader(name: "user_id", value: userId)]
        } else {
            return nil
        }
    }

    // MARK: public functions

    /// Reads id from the KeyChain and sets it \
    /// If `id` does not exist in the keychain, it gets the UUID of the device
    /// and sets it as `id` in the KeyChain
    public func configure() {
        self.userId = "A435365S"
    }

    public func getUser(completion: @escaping (Result<User, IPollError>) -> Void) {
        AF.request(usersEndpoint,
                   headers: requestHeader)
            .responseDecodable(of: User.self) { response in
                switch response.result {
                    case .success(let user):
                        completion(.success(user))
                    case .failure:
                        completion(.failure(self.decodeError(from: response)))
                }
            }
    }

    public func createPoll(title: String, options: [String], completion: @escaping (Result<Poll, IPollError>) -> Void) {
        let params = ["title": title, "options": options] as [String: Any]
        AF.request(pollsEndpoint, method: .post, parameters: params,
                   encoding: URLEncoding.httpBody,
                   headers: requestHeader)
            .responseDecodable(of: Poll.self) { response in
                switch response.result {
                    case .success(let poll):
                        completion(.success(poll))
                    case .failure:
                        completion(.failure(self.decodeError(from: response)))
                }
            }
    }

    public func getPoll(_ id: String, completion: @escaping (Result<Poll, IPollError>) -> Void) {
        AF.request("\(pollsEndpoint)/\(id)", headers: requestHeader)
            .responseDecodable(of: Poll.self) { response in
                switch response.result {
                    case .success(let poll):
                        completion(.success(poll))
                    case .failure:
                        completion(.failure(self.decodeError(from: response)))
                }
        }
    }

    public func vote(pollId: String, optionId: String, completion: @escaping (Result<Poll, IPollError>) -> Void) {
        AF.request("\(pollsEndpoint)/\(pollId)/\(optionId)",
                   method: .post,
                   headers: requestHeader)
            .responseDecodable(of: Poll.self) { response in
                switch response.result {
                    case .success(let poll):
                        completion(.success(poll))
                    case .failure:
                        completion(.failure(self.decodeError(from: response)))
                }
            }
    }

    private func decodeError<T>(from response: DataResponse<T, AFError>) -> IPollError {
        let decoder = JSONDecoder()
        do {
            guard let data = response.data else { throw IPollError() }
            let err = try decoder.decode(IPollError.self, from: data)
            return err
        } catch {
            return IPollError(message: response.error?.errorDescription ?? "An Error Occurred")
        }
    }

}