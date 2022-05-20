//
//  NetworkManager.swift
//  iPoll
//
//  Created by Evans Owamoyo on 19.03.2022.
//

import Foundation
import Alamofire
import SwiftyJSON
import KeychainAccess

protocol NetworkServiceProtocol {
    func getUser(completion: @escaping (Result<User, IPollError>) -> Void)
    func createPoll(poll: PollDto, completion: @escaping (Result<Poll, IPollError>) -> Void)
    func getPoll(_ id: String, completion: @escaping (Result<Poll, IPollError>) -> Void)
    func vote(pollId: String, optionId: String, completion: @escaping (Result<Poll, IPollError>) -> Void)
}

class NetworkService: NetworkServiceProtocol {
    // - MARK: private variables
    private static let keychain = Keychain(service: "dev.lordvidex.ipoll")
    static var userId: String? // id of this device
    static var username: String? // user registered name
    
    private var user: User? // the user data with his polls
    
    private var dataDecoder: DataDecoder?
    
    private let baseUrl = "https://llopi.herokuapp.com/v1" // the base url for making api calls
    
    private var usersEndpoint: String {
        "\(baseUrl)/users"
    }
    
    private var pollsEndpoint: String {
        "\(baseUrl)/poll"
    }
    
    // required header for making api requests to server
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
    
    // - MARK: public functions
    
    /// Reads id from the KeyChain and sets it \
    /// If `id` does not exist in the keychain, it gets the UUID of the device
    /// and sets it as `id` in the KeyChain
    public static func configure() {
        DispatchQueue.global().async {
            do {
                let userId = try keychain
//                    .authenticationPrompt("Authenticate to login to iPoll")
                    .get("userId")
                self.username = try keychain.get("username")
                self.userId = userId
            } catch let error {
                print("error occured \(error)")
            }
        }
    }
    
    public func getUser(completion: @escaping (Result<User, IPollError>) -> Void) {
        AF.request(usersEndpoint,
                   headers: requestHeader)
        .responseDecodable(of: User.self, decoder: getDecoder()) { response in
            switch response.result {
            case .success(let user):
                completion(.success(user))
            case .failure:
                completion(.failure(self.decodeError(from: response)))
            }
        }
    }
    
    private func generateUniqueId() -> String {
        return UIDevice.current.identifierForVendor!.uuidString
    }
    
    public func setUser(name: String?, completion: @escaping (Result<User, IPollError>) -> Void) {
        // generate id and save to keychain
        let id = generateUniqueId()
        DispatchQueue.global().async {
            do {
                // Should be the secret invalidated when passcode is removed? If not then use `.WhenUnlocked`
                try NetworkService.keychain
                    .set(id, key: "userId")
                try NetworkService.keychain
                    .set(name ?? "", key: "username")
            } catch let error {
                print(error.localizedDescription)
            }
        }
        NetworkService.shared.createUser(User(id: id,
                                              name: name,
                                              participatedPolls: [],
                                              createdPolls: [])) { completion($0) }
        
        // update the id on the NetworkService
        NetworkService.userId = id
    }
    
    private func createUser(_ user: User, completion: @escaping (Result<User, IPollError>) -> Void) {
        AF.request("\(usersEndpoint)/register",
                   method: .post,
                   parameters: ["user_id": user.id, "name": user.name as Any],
                   encoding: JSONEncoding.default)
        .responseDecodable(
            of: User.self,
            decoder: getDecoder()) { [weak self] response in
                switch response.result {
                case .success(let user):
                    self?.user = user
                    completion(.success(user))
                case .failure(let error):
                    completion(.failure(IPollError(message: error.errorDescription)))
                }
            }
    }
    
    private func encode(_ pollDto: PollDto) throws -> JSON {
        // encode the `PollDto`
        let encoder = JSONEncoder()
        encoder.dateEncodingStrategy = .formatted(.iso8601Full)
        guard let data = try? encoder.encode(pollDto) else {
            // encoding failed
            throw IPollError(message: "Error decoding Create Poll [PollDto]")
        }
        
        guard let jsonData = try? JSON(data: data) else {
            // converting to JSON failed
            throw IPollError(message: "Converting class Data to JSON failed")
        }
        return jsonData
    }
    
    public func createPoll(poll: PollDto,
                           completion: @escaping (Result<Poll, IPollError>) -> Void) {
        
        do {
            let jsonData = try encode(poll)
            AF.request(pollsEndpoint, method: .post,
                       parameters: jsonData.dictionaryObject,
                       encoding: JSONEncoding.default,
                       headers: requestHeader)
            .responseDecodable(of: Poll.self, decoder: getDecoder()) { response in
                switch response.result {
                case .success(let poll):
                    completion(.success(poll))
                case .failure:
                    completion(.failure(self.decodeError(from: response)))
                }
            }
        } catch {
            completion(.failure((error as? IPollError) ?? IPollError(message: "UnExpected error \(error)")))
        }
    }
    
    public func editPoll(_ id: String,
                         dto: PollDto,
                         completion: @escaping (Result<Poll, IPollError>) -> Void) {
        
        do {
            let jsonData = try encode(dto)
            //            print(jsonData.dictionaryObject)
            AF.request("\(pollsEndpoint)/\(id)", method: .patch,
                       parameters: jsonData.dictionaryObject,
                       encoding: JSONEncoding.default,
                       headers: requestHeader)
            .responseDecodable(of: Poll.self, decoder: getDecoder()) { response in
                switch response.result {
                case .success(let poll):
                    completion(.success(poll))
                case .failure:
                    completion(.failure(self.decodeError(from: response)))
                }
            }
        } catch {
            completion(.failure((error as? IPollError) ?? IPollError(message: "UnExpected error \(error)")))
        }
    }
    
    public func getPoll(_ id: String, completion: @escaping (Result<Poll, IPollError>) -> Void) {
        AF.request("\(pollsEndpoint)/\(id)", headers: requestHeader)
            .responseDecodable(of: Poll.self, decoder: getDecoder()) { response in
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
        .responseDecodable(of: Poll.self, decoder: getDecoder()) { response in
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
            print(response)
            return IPollError(message: response.error?.errorDescription ?? "An Error Occurred")
        }
    }
    
    private func getDecoder() -> DataDecoder {
        if let dataDecoder = dataDecoder {
            return dataDecoder
        } else {
            let decoder = JSONDecoder()
            decoder.dateDecodingStrategy = .formatted(.iso8601Full)
            dataDecoder = decoder
            return decoder
        }
    }
    
}
