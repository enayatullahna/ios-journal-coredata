//
//  Entry+Convenience.swift
//  Journal
//
//  Created by Enayatullah Naseri on 7/10/19.
//  Copyright © 2019 Enayatullah Naseri. All rights reserved.
//

import Foundation
import CoreData

enum EntryMood: String, CaseIterable {
    
    case 😡
    case 😐
    case 🤪
}

extension Entry {
    
    var entryRepresentation: EntryRepresentation? {
        guard let title = self.title,
            let mood = self.mood,
            let timestamp = self.timestamp,
            let identifier = self.identifier else {return nil}
        
        return EntryRepresentation(title: title, bodyText: bodyText, mood: mood, timestamp: timestamp, identifier: identifier)
    }
    convenience init(title: String, bodyText: String?, timestamp: Date = Date(), identifier: String = UUID().uuidString, mood: EntryMood = .🤪, context: NSManagedObjectContext = CoreDataStack.shared.mainContext) {
        self.init(context: context)
        self.title = title
        self.bodyText = bodyText
        self.timestamp = timestamp
        self.identifier = identifier
        self.mood = mood.rawValue
    }
    
    // Initialize an entry object from EntryRepresentation
    convenience init?(entryRepresentation: EntryRepresentation, context: NSManagedObjectContext = CoreDataStack.shared.mainContext) {
        guard let mood = EntryMood(rawValue: entryRepresentation.mood!),
            let identifier = UUID(uuidString: entryRepresentation.identifier) else { return nil }
        
        self.init(title: entryRepresentation.title,
                  bodyText: entryRepresentation.bodyText,
                  timestamp: entryRepresentation.timestamp,
                  identifier: identifier.uuidString,
                  mood: mood,
                  context: context)
    }
}
