//
//  VoteManager.swift
//  iPoll
//
//  Created by Evans Owamoyo on 20.03.2022.
//

import Foundation
import SocketIO

enum Action {
    case vote
    case fetch
    case update
}

protocol VoteManagerDelegate: AnyObject {
    func didReceivePoll(_ voteManager: VoteManager,sender: Action, poll: Poll)
    func didFail(_ voteManager: VoteManager,sender: Action, with error: IPollError)
}


protocol VoteManagerProtocol {
    func fetchPoll(_ id: String)
    func vote(pollId: String, optionId: String)
}


class VoteManager: VoteManagerProtocol {
    private let network: NetworkService = .shared
    private var socketManager: SocketManager?
    
    private var socket: SocketIOClient?
    
    weak var delegate: VoteManagerDelegate?
    deinit {
        socket?.disconnect()
        socket?.removeAllHandlers()
        socketManager?.disconnect()
    }
    
    func fetchPoll(_ id: String) {
        network.getPoll(id) { [weak self] result in
            if let self = self {
                switch result {
                    case .success(let poll):
                        self.delegate?.didReceivePoll(self, sender: .fetch, poll: poll)
                        self.setupSocket(room: poll.id)
                    case .failure(let error):
                        self.delegate?.didFail(self, sender: .fetch, with: error)
                }
            }
        }
    }
    
    func vote(pollId: String, optionId: String) {
        network.vote(pollId: pollId, optionId: optionId) { [weak self] result in
            if let self = self {
                switch result {
                    case .success(let poll):
                        self.delegate?.didReceivePoll(self, sender: .vote, poll: poll)
                    case .failure(let error):
                        self.delegate?.didFail(self, sender: .vote, with: error)
                        
                }
            }
        }
    }
    
    private func setupSocket(room: String) {
        // create a manager that connects to the socket API with a room param
        socketManager = SocketManager(socketURL: URL(string: "https://llopi.herokuapp.com")!, config: [.log(true), .compress, .connectParams(["room" : room])])
        
        socket = socketManager!.socket(forNamespace: "/live")
        
        // register connect event
        socket?.on(clientEvent: .connect, callback: { data, ack in
            print("Socket successfully connected with data: \(data)")
        })
        
        // register vote event
        socket?.on("vote", callback: { data, ack in
            guard let dataInfo = data.first else { return }
            print("Data gotten from socket: \(dataInfo)")
            if let poll: Poll = try? SocketParser.convert(data: dataInfo) {
                self.delegate?.didReceivePoll(self, sender: .update, poll: poll)
            }
        })
        
        
        socket?.connect()  // connect the socket
    }
}
