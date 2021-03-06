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
import FirebaseAuth

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
    /// First: checks if user is authenticated by firebase
    /// ELSE:
    /// Reads id from the KeyChain and sets it \
    /// If `id` does not exist in the keychain, it gets the UUID of the device
    /// and sets it as `id` in the KeyChain
    public static func configure() {
        if let user = Auth.auth().currentUser {
            self.userId = user.uid
            self.username = user.displayName ?? user.email ?? ""
            print("User id is \(userId) and username is \(username)")
        } else {
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
    }
    
    /// Deletes the user authentication details from the KeyChain and logs out from firebase
    public static func logout(completion: @escaping () -> Void) {
        if Auth.auth().currentUser != nil {
            try? Auth.auth().signOut()
        }
        
        DispatchQueue.global(qos: .userInitiated).async {
            do {
                try keychain.remove("userId")
                try keychain.remove("username")
                NetworkService.shared.user = nil
                NetworkService.userId = nil
                NetworkService.username = nil
                completion()
            } catch let error {
                print(error.localizedDescription)
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
    
    /// Logs in the user / creates a new account for this user
    /// if id is not specified, the Device UUID is used as id and registered on the server
    public func setUser(id: String?,
                        name nam: String?,
                        completion: @escaping (Result<User, IPollError>) -> Void) {
        // generate id and save to keychain
        let id = id ?? NetworkService.userId ?? generateUniqueId()
        let name = nam ?? NetworkService.username ?? ""
        DispatchQueue.global().async {
            do {
                // Should be the secret invalidated when passcode is removed? If not then use `.WhenUnlocked`
                try NetworkService.keychain
                    .set(id, key: "userId")
                try NetworkService.keychain
                    .set(name, key: "username")
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
        NetworkService.username = name
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
    
    public func getPollVoters(poll: String,
                              option: String,
                              completion: @escaping (Result<PollOption, IPollError>) -> Void) {
        AF.request("\(pollsEndpoint)/\(poll)/\(option)/", headers: requestHeader)
            .responseDecodable(of: PollOption.self, decoder: getDecoder()) { response in
                switch response.result {
                case .success(let option):
                    completion(.success(option))
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
