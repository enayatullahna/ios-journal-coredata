//
//  EntryDetailViewController.swift
//  Journal
//
//  Created by Enayatullah Naseri on 12/4/19.
//  Copyright © 2019 Enayatullah Naseri. All rights reserved.
//

import UIKit

class EntryDetailViewController: UIViewController {

    //Outlets
    @IBOutlet weak var titleTextField: UITextField!
    @IBOutlet weak var detailTextView: UITextView!
    @IBOutlet weak var moodControllSegment: UISegmentedControl!
    
    
    var entryController: EntryController?
    
    var entries: Entry? {
        didSet {
            updateViews()
        }
    }
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        updateViews()
        view.backgroundColor = ColorHelper.backgroundColorNew
    }
    
    @IBAction func saveButtonTapped(_ sender: Any) {
        
        guard let entryName = self.titleTextField.text,
            !entryName.isEmpty else {return}
        
        let moodIndex = moodControllSegment.selectedSegmentIndex
        let mood = EntryMood.allCases[moodIndex]
        let bodyText = self.detailTextView.text
        
        if let entry = self.entries {
            entry.title = entryName
            entry.mood = mood.rawValue
            entry.bodyText = bodyText
            
        } else {
            let _ = Entry(title: entryName, bodyText: bodyText!, mood: mood)
        }
        
        do {
            let moc = CoreDataStack.shared.mainContext
            try moc.save()
        } catch {
            NSLog("Error Saving manged object context: \(error)")
        }

        navigationController?.popViewController(animated: true)
    }
    
        
    
    func updateViews(){
        
        guard isViewLoaded else {return}
            
            let mood: EntryMood
            if let entryMood = entries?.mood {
                mood = EntryMood(rawValue: entryMood)!
            } else {
                mood = .😐
            }
            moodControllSegment.selectedSegmentIndex = EntryMood.allCases.firstIndex(of: mood)!
            
            self.navigationItem.title = entries?.title ?? "Entry"
            titleTextField.text = entries?.title
            detailTextView.text = entries?.bodyText
        }
}
