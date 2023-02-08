//
//  HypeController.swift
//  Hype
//
//  Created by Stef Castillo on 1/27/23.
//

import UIKit
import CloudKit

/**
 Allows us to write functions to cloudkit
 */
class HypeController {
    ///shared instance
    static let shared = HypeController()
    
    ///Source of Truth array
    var hypes: [Hype] = []
    
    ///Constant to store our publicCloudDatabase
    let publicDB = CKContainer.default().publicCloudDatabase
    
    //MARK: CRUD Functions
    
    //Create
    func saveHype(with text: String, photo: UIImage?, completion: @escaping (Bool) -> Void) {
        guard let currentUser = UserController.shared.currentUser else { completion(false) ; return}
        let reference = CKRecord.Reference(recordID: currentUser.recordID, action: .none)
        //Init a Hype Object
        let newHype = Hype(body: text, hypePhoto: photo, userReference: reference)
        
        //Package into the newHype into a CKRecord
        let hypeRecord = CKRecord(hype: newHype)
        
        //Saving the hypeRecord to the cloud
        publicDB.save(hypeRecord) { (record, error) in
            //Handling the error if there is one
            if let error = error {
                print("Error in \(#function) : \(error.localizedDescription) \n---\n \(error)")
                completion(false)
                return
            }
            
            //Unwrapping the record that was saved
            guard let record = record,
                  //ensuring that we can initialize the hype from that record
                    let savedHype = Hype(ckRecord: record)
            else { completion(false) ; return}
            
            //Add it to our SoT array
            print("Saved Hype Successfully")
            self.hypes.insert(savedHype, at: 0)
            completion(true)
        }
    }
    
    //Fetch
    func fetchHypes(completion: @escaping (Bool) -> Void) {
        
        //Step 3 - Init the requisite predicate for the query
        let predicate = NSPredicate(value: true)
        
        //Step 2 - Initilaize the request query for the .perform method
        let query = CKQuery(recordType: HypeStrings.recordTypeKey, predicate: predicate)
        
        //Step 1 - Perform a query on the database
        publicDB.perform(query, inZoneWith: nil) { (records, error) in
            //Handle the optional error
            if let error = error {
                print("Error in \(#function) : \(error.localizedDescription) \n---\n \(error)")
                completion(false)
                return
            }
            //Unwrap the found records
            guard let records = records else { completion(false); return}
            print("Fetched all hypes")
            
            //Compact map through the found records to return the non-nil Hype objects
            let fetchedHypes = records.compactMap { Hype(ckRecord: $0) }
            
            //Set our source of truth
            self.hypes = fetchedHypes
            completion(true)
        }
        
        
    }
    
    func update(_ hype: Hype, completion: @escaping (Bool) -> Void) {
        
        guard hype.userReference?.recordID == UserController.shared.currentUser?.recordID else { completion(false); return}
        
        //Step 3 - Define the records to be updated
        let recordsToUpdate = CKRecord(hype: hype)
        //Step 2 - Create the requisite opeartion
        let operation = CKModifyRecordsOperation(recordsToSave: [recordsToUpdate])
        //Step 4 - Set the properties for the opeartion
        operation.savePolicy = .changedKeys
        operation.qualityOfService = .userInteractive
        operation.modifyRecordsCompletionBlock = { (records, _ , error) in
            //Handle the error
            if let error = error {
                print("Error in \(#function) : \(error.localizedDescription) \n--\n \(error)")
                completion(false)
                return
            }
            //Ensure the records were returned and updated
            guard let record = records?.first else { completion(false); return}
            print("Updated \(record.recordID.recordName) successfully in CloudKit")
            completion(true)
        }
        //Step 1 - Add operation to the Database
        publicDB.add(operation)
    }
    
    func delete(_ hype: Hype, completion: @escaping (Bool) -> Void) {
        
        guard hype.userReference?.recordID == UserController.shared.currentUser?.recordID else { completion(false); return}
        
        //Step2 - Declared opeartion
        let operation = CKModifyRecordsOperation(recordIDsToDelete: [hype.recordID])
        
        //Step 3 - Set the properties on the opeartion
        operation.savePolicy = .changedKeys
        operation.qualityOfService = .userInteractive
        operation.modifyRecordsCompletionBlock = { (_, recordIDs, error) in
            if let error = error {
                print("Error in \(#function) : \(error.localizedDescription) \n--\n \(error)")
                completion(false)
                return
            }
            
            guard let recordIDs = recordIDs else { completion(false); return }
            print("\(recordIDs) were removed successfully")
            completion(true)
            }
        //Step 1 - Add operation to the database
        publicDB.add(operation)
        }
    
    func subscribeForRemoteNotifications(completion: @escaping (Error?) -> Void) {
        //Step 3 - Delcare the requisite predicate
        let predicate = NSPredicate(value: true)
        //Step 2 - Declare the subscription
        let subscription = CKQuerySubscription(recordType: HypeStrings.recordTypeKey, predicate: predicate, options: .firesOnRecordCreation)
        
        //Step 4 - Setting the subscription properties
        let notificationInfo = CKSubscription.NotificationInfo()
        notificationInfo.title = "Choo choo"
        notificationInfo.alertBody = "Can't stop the Hype Train"
        notificationInfo.shouldBadge = true
        notificationInfo.soundName = "default"
        subscription.notificationInfo = notificationInfo
        
        //Step 1 -Call the save (subscription) function on the database
        publicDB.save(subscription) { _, error in
            if let error = error {
                completion(error)
            }
            completion(nil)
        }
    }
    
}//End of Class
