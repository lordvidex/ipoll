//
//  Entity+Converter.swift
//  iPoll
//
//  Created by Evans Owamoyo on 28.03.2022.
//

import Foundation

extension PollEntity {
    func toPoll() -> Poll {
        
        return Poll(id: id!,
                    title: title!,
                    isAnonymous: isAnonymous,
                    options: options?.toArray(of: PollOptionEntity.self).map { $0.toPollOption() })
    }
    
    func copyProperties(of poll: Poll, with pollOptions: [PollOptionEntity]) {
        id = poll.id
        title = poll.title
        isAnonymous = poll.isAnonymous
        pollOptions.forEach { addToOptions($0) }
    }
}

extension PollOptionEntity {
    func toPollOption() -> PollOption {
        PollOption(id: id!,
                   title: title!,
                   votesId: (votesId?.toArray(of: VoteEntity.self) ?? []).map { $0.id! })
    }
    
    func copyProperties(of option: PollOption, with votes: [VoteEntity]) {
        id = option.id
        title = option.title
        votes.forEach { addToVotesId($0) }
    }
}
