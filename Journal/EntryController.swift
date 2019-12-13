//
//  EntryController.swift
//  Journal
//
//  Created by Enayatullah Naseri on 7/10/19.
//  Copyright © 2019 Enayatullah Naseri. All rights reserved.
//

import Foundation
import CoreData

let baseURL = URL(string: "https://journalnew-6352f.firebaseio.com/")!

class EntryController {
    
    typealias CompletionHandler = (Error?) -> Void
    
    init() {
        fetchEntryFromServer()
    }
    
    // Fetch entry from the server
    
    func fetchEntryFromServer(completion: @escaping CompletionHandler = { _ in }) {
        let requestURL = baseURL.appendingPathExtension("json")
        
        URLSession.shared.dataTask(with: requestURL) { (data, _, error) in
            if let error = error {
                NSLog("Error Fetching entry: \(error)")
                completion(error)
                return
            }
            
            guard let data = data else {
                NSLog("No data returned by the data entry")
                completion(NSError())
                return
            }
            
            do {
                let entryRepresentation = Array(try JSONDecoder().decode([String : EntryRepresentation].self, from: data).values)
                try self.updateEntries(with: entryRepresentation)
                completion(nil)
            } catch {
                NSLog("Error decoding task representation: \(error)")
                completion(nil)
                return
            }
        }.resume()
    }
    
    private func updateEntries(with representations: [EntryRepresentation]) throws {
        for entryRep in representations {
            guard let uuid = UUID(uuidString: entryRep.identifier) else {continue}
            
            let entry = self.entry(forUUID: uuid)
            
            if let entry = entry {
                self.update(entry: entry, with: entryRep)
            } else {
                let _ = Entry(entryRepresentation: entryRep)
            }
            
        }
        
        try self.saveToPersistentStore()
    }
    
    private func entry(forUUID uuid: UUID) -> Entry? {
        let fetchrequest: NSFetchRequest<Entry> = Entry.fetchRequest()
        fetchrequest.predicate = NSPredicate(format: "identifier == %@", uuid as NSUUID)
        
        do {
            let moc = CoreDataStack.shared.mainContext
            return try moc.fetch(fetchrequest).first
        } catch {
            NSLog("Error fetching entry with uuid \(uuid): \(error)")
            return nil
        }
        
    }
    
    
    
    //PUT Request
    func put(entry: Entry, completion: @escaping CompletionHandler = { _ in }) {
        
        let uuid = entry.identifier ?? UUID().uuidString
        let requestURL = baseURL.appendingPathComponent(uuid).appendingPathExtension("json")
        
        var request = URLRequest(url: requestURL)
        request.httpMethod = "PUT"
        
        do {
            guard var representation = entry.entryRepresentation else {
                completion(NSError())
                return
            }
            representation.identifier = uuid
            entry.identifier = uuid
            try saveToPersistentStore()
            request.httpBody = try JSONEncoder().encode(representation)
        } catch {
            NSLog("Error encoding entry \(entry): \(error)")
        }
        
        URLSession.shared.dataTask(with: request) { (data, _, error) in
            if let error = error {
                NSLog("Error putting entry to server: \(error)")
                completion(error)
                return
            }
            completion(nil)
        }.resume()
        
    }
    
    func update(entry: Entry, with representation: EntryRepresentation) {
        entry.title = representation.title
        entry.bodyText = representation.bodyText
        entry.timestamp = representation.timestamp
        entry.mood = representation.mood
    
    }
    
    func saveToPersistentStore() throws {
        let moc = CoreDataStack.shared.mainContext
        try moc.save()
    }

    func deleteEntryFromServer(_ entry: Entry, completion: @escaping CompletionHandler = { _ in }) {
        
        guard let uuid = entry.identifier else {
            completion(NSError())
            return
        }
        
        let requestURL = baseURL.appendingPathComponent(uuid).appendingPathExtension("json")
        var request = URLRequest(url: requestURL)
        request.httpMethod = "DELETE"
        
        URLSession.shared.dataTask (with: request) { (_, response, error) in
            print(response!)
            completion(error)
            
        }.resume()

    }
}
