//
//  Entity+Converter.swift
//  iPoll
//
//  Created by Evans Owamoyo on 28.03.2022.
//

import UIKit

extension PollEntity {
    func toPoll() -> Poll {
        return Poll(id: id!,
                    title: title!,
                    authorId: authorId,
                    isAnonymous: isAnonymous,
                    hasTimeLimit: hasTimeLimit,
                    startTime: startTime!,
                    endTime: endTime,
                    author: Author(name: author!.name,
                                   id: author!.id!),
                    options: options?
            .toArray(of: PollOptionEntity.self)
            .map { $0.toPollOption() },
                    color: color == nil ? nil : UIColor(hexString: color!)
        )
    }
    
    func copyProperties(of poll: Poll, with pollOptions: [PollOptionEntity]) {
        id = poll.id
        title = poll.title
        isAnonymous = poll.isAnonymous
        hasTimeLimit = poll.hasTimeLimit
        startTime = poll.startTime
        endTime = poll.endTime
        color = poll.color?.hexString
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
