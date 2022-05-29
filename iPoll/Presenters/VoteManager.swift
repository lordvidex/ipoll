//
//  VoteManager.swift
//  iPoll
//
//  Created by Evans Owamoyo on 20.03.2022.
//

import Foundation
import SocketIO

enum IPAction {
    case vote
    case fetch
    case update
}

// MARK: - delegate
protocol VoteManagerDelegate: AnyObject {
    func didReceivePoll(_ voteManager: VoteManager, sender: IPAction, poll: Poll)
    func didFail(_ voteManager: VoteManager, sender: IPAction, with error: IPollError)
}

// MARK: - protocol
protocol VoteManagerProtocol {
    func fetchPoll(_ id: String)
    func vote(pollId: String, optionId: String)
}

// MARK: - VoteManager
class VoteManager: VoteManagerProtocol {
    private let network: NetworkService = .shared
    private let local: PersistenceService = .shared
    private let pollManager = PollManager()

    // create a manager that connects to the socket API with a room param
    private var socketManager = SocketManager(socketURL: URL(string: "https://llopi.herokuapp.com")!,
                                              config: [.log(false), .compress, .connectParams(["EIO": "3"])])

    private weak var socket: SocketIOClient?

    weak var delegate: VoteManagerDelegate?

    func fetchPoll(_ id: String) {
        // temporarily return local version of poll
        var localPoll: Poll?
        if let poll = local.fetchPoll(with: id) {
            delegate?.didReceivePoll(self, sender: .fetch, poll: poll)
            localPoll = poll
        }

        // get live result from server and set up the live socket thereafter
        network.getPoll(id) { [weak self] result in
            if let self = self {
                switch result {
                    case .success(var poll):
                        if localPoll != nil {
                            poll = localPoll!.copyWith(poll)
                        }
                        self.delegate?.didReceivePoll(self, sender: .fetch, poll: poll)
                        self.persistPoll(poll)   // persist to local
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

    /*
     * saves poll to localstorage
     * * Method is called after it has been gotten initially from the networkservice
     */
    func persistPoll(_ poll: Poll) {
        DispatchQueue.global(qos: .utility).async {
            self.local.savePoll(poll)
            self.pollManager.fetchVisitedPolls()
        }
        
    }

    // MARK: - WebSocket Functions
    private func setupSocket(room: String) {
        socket = socketManager.socket(forNamespace: "/live")

        // register vote event
        socket?.on(clientEvent: .connect, callback: { _, _ in
            self.joinRoom(room: room)
        })
        socket?.on("vote", callback: { data, _ in
            guard let dataInfo = data.first else { return }
            if let poll: Poll = try? SocketParser.convert(data: dataInfo) {
                self.delegate?.didReceivePoll(self, sender: .update, poll: poll)
            } else {
                print("Error parsing")
            }
        })

        socket?.connect()  // connect the socket
    }

    func joinRoom(room: String) {
        socket?.emit("joinRoom", with: [room])
    }

    func closeSocket() {
        socket?.disconnect()
        socket?.removeAllHandlers()
        socketManager.disconnect()
        socket = nil
    }
}
