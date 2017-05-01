//
//  ChangeReadState.swift
//  books
//
//  Created by Andrew Bennet on 24/05/2016.
//  Copyright © 2016 Andrew Bennet. All rights reserved.
//

import Eureka
import UIKit

class ReadStateForm: FormViewController {

    let readStateKey = "book-read-state"
    let dateStartedKey = "date-started"
    let dateFinishedKey = "date-finished"
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // The three rows we need in this table
        let readStateSection = Section(header: "Current State", footer: "")
        let readStateRow = SegmentedRow<BookReadState>(readStateKey) {
            $0.options = [.toRead, .reading, .finished]
            // Set a value here so we can be sure that the read state option is *never* null.
            $0.value = .toRead
        }
        readStateSection.append(readStateRow)
        form.append(readStateSection)
        
        let startedReadingRow = DateRow(dateStartedKey){
            $0.title = "Started Reading"
            // Set a value here so we can be sure that the started date is *never* null.
            $0.value = Date.startOfToday()
        }
        let finishedReadingRow = DateRow(dateFinishedKey){
            $0.title = "Finished Reading"
            // Set a value here so we can be sure that the finished date is *never* null.
            $0.value = Date.startOfToday()
        }
        
        // Add the rows to the form
        appendRowToFormInSection(row: startedReadingRow, hiddenCondition: Condition.function([readStateKey]) {_ in 
            return readStateRow.value == .toRead
        })
        appendRowToFormInSection(row: finishedReadingRow, hiddenCondition: Condition.function([readStateKey]) {_ in
            return readStateRow.value != .finished
        })
        
        // Add the change and update detection, now that they are on the form
        readStateRow.onChange{[unowned self] _ in self.onChange() }
        startedReadingRow.onChange{[unowned self] _ in self.onChange() }
        startedReadingRow.cellUpdate{[unowned self] _ in self.onChange() }
        finishedReadingRow.onChange{[unowned self] _ in self.onChange() }
        finishedReadingRow.cellUpdate{[unowned self] _ in self.onChange() }
    }
    
    func appendRowToFormInSection(row: BaseRow, hiddenCondition: Condition?) {
        let newSection = Section()
        newSection.append(row)
        newSection.hidden = hiddenCondition
        form.append(newSection)
    }
    
    func onChange() {
        // Should be overriden
    }
    
    var readState: BookReadState {
        get { return form.values()[readStateKey] as! BookReadState }
        set { form.setValues([readStateKey: newValue]) }
    }
    
    var startedReading: Date? {
        get { return form.values()[dateStartedKey] as? Date }
        set { form.setValues([dateStartedKey: newValue]) }
    }
    
    var finishedReading: Date? {
        get { return form.values()[dateFinishedKey] as? Date }
        set { form.setValues([dateFinishedKey: newValue]) }
    }
    
    var isValid: Bool {
        let now = Date()
        // Check that the dates are ordered correctly and not in the future
        switch readState {
        case .toRead:
            return true
        case .reading:
            return startedReading != nil && startedReading!.compareIgnoringTime(now) != .orderedDescending
        case .finished:
            return startedReading != nil && finishedReading != nil
            && startedReading!.compareIgnoringTime(now) != .orderedDescending
            && finishedReading!.compareIgnoringTime(now) != .orderedDescending
            && startedReading!.compareIgnoringTime(finishedReading!) != .orderedDescending
        }
    }
}
