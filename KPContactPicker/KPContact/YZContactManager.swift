//
//  YZContactManager.swift
//  MailM8
//
//  Created by Yudiz Solutions Pvt.Ltd. on 30/06/16.
//  Copyright © 2016 Yudiz Solutions Pvt.Ltd. All rights reserved.
//

import Foundation
import Contacts
import UIKit

struct ContactType: OptionSet {
    let rawValue : Int
    static let phone = ContactType(rawValue:1 << 1)
    static let email = ContactType(rawValue:1 << 2)
    static let address = ContactType(rawValue:1 << 3)
}

// MARK: - Public Methods
extension YZContactManager{
    
    /// Check for contact book permission
    ///
    /// - Parameter completionHandler: Returns status granted or not
    func requestForAccess(completionHandler: @escaping (_ accessGranted: Bool) -> Void) {
        let authorizationStatus = CNContactStore.authorizationStatus(for: CNEntityType.contacts)
        switch authorizationStatus {
        case .authorized:
            DispatchQueue.main.async(execute: {
                completionHandler(true)
            })
        case .denied, .notDetermined:
            self.contactStore.requestAccess(for: CNEntityType.contacts, completionHandler: { (access, accessError) -> Void in
                if access {
                    DispatchQueue.main.async(execute: {
                        completionHandler(access)
                    })
                }
                else {
                    DispatchQueue.main.async(execute: {
                        completionHandler(false)
                    })
                }
            })
            
        default:
            DispatchQueue.main.async(execute: {
                completionHandler(false)
            })
        }
    }
    
    
    /// Search contact by name
    ///
    /// - Parameters:
    ///   - term: name of contact which you want to search
    ///   - completion: Returns KPContact array of given name
    func searchContactByName(term: String!,completion:@escaping (_ contacts :[YZContact],_ error: Error?)->()){
        DispatchQueue.global().async {
            var contacts:[YZContact] = []
            let keys = [CNContactFormatter.descriptorForRequiredKeys(for: CNContactFormatterStyle.fullName),CNContactPostalAddressesKey, CNContactEmailAddressesKey, CNContactBirthdayKey,CNContactImageDataKey,CNContactOrganizationNameKey,CNContactPhoneNumbersKey] as [Any]
            let pre = CNContact.predicateForContacts(matchingName: term)
            do{
                let contcs = try self.contactStore.unifiedContacts(matching: pre, keysToFetch: keys as! [CNKeyDescriptor])
                for con in contcs{
                    let kpContect = YZContact(contact: con)
                    if self.validateContact(contact: kpContect){
                        contacts.append(kpContect)
                    }
                }
                DispatchQueue.main.async {
                    completion(contacts, nil)
                }
            }catch let err{
                DispatchQueue.main.async {
                    completion(contacts, err)
                }
            }
        }
    }
    
    
    /// Search by contact Id
    ///
    /// - Parameter term: Contact id
    /// - Returns: return contact object if found.
    func searchContactById(term: String!) -> YZContact?{
        let keys = [CNContactFormatter.descriptorForRequiredKeys(for: CNContactFormatterStyle.fullName),CNContactPostalAddressesKey, CNContactEmailAddressesKey, CNContactBirthdayKey,CNContactImageDataKey,CNContactOrganizationNameKey,CNContactPhoneNumbersKey] as [Any]
        do{
            let contcs: CNContact = try self.contactStore.unifiedContact(withIdentifier: term, keysToFetch: keys as! [CNKeyDescriptor])
            let contact = YZContact(contact: contcs)
            return contact
        }catch{
            return nil
        }
    }
    
    
    
    /// This method return all contact in simple array form
    ///
    /// - Parameter completion: return contact object array and error if occured.
    func fetchContactArray(completion:@escaping (_ contacts :[YZContact],_ error: Error?)->()) {
        DispatchQueue.global().async {
            var contacts:[YZContact] = []
            let keys = [CNContactFormatter.descriptorForRequiredKeys(for: CNContactFormatterStyle.fullName),CNContactPostalAddressesKey, CNContactEmailAddressesKey, CNContactBirthdayKey,CNContactImageDataKey,CNContactOrganizationNameKey,CNContactPhoneNumbersKey] as [Any]
            let request = CNContactFetchRequest(keysToFetch: keys as! [CNKeyDescriptor])
            request.sortOrder = CNContactSortOrder.givenName
            do{
                try self.contactStore.enumerateContacts(with: request) { (contact, pointer) in
                    let kpContect = YZContact(contact: contact)
                    
                    if self.validateContact(contact: kpContect){
                        contacts.append(kpContect)
                    }
                }
                
                DispatchQueue.main.async {
                    completion(contacts, nil)
                }
            }catch let err{
                DispatchQueue.main.async {
                    completion(contacts, err)
                }
            }
        }
    }
    
    /// This method returns Indexed KPContact Array e.g. ["A":[KPContact,KPContact]]
    ///
    /// - Parameter completion: Returns KPContacts e.g. ["A":[KPContact,KPContact]] and error if occur.
    func fetchContactIndexArray(completion:@escaping (_ contacts :[String: [YZContact]],_ error: Error?)->()) {
        
        DispatchQueue.global().async {
            var contacts:[String: [YZContact]] = [:]
            let keys = [CNContactFormatter.descriptorForRequiredKeys(for: CNContactFormatterStyle.fullName),CNContactPostalAddressesKey, CNContactEmailAddressesKey, CNContactBirthdayKey,CNContactImageDataKey,CNContactOrganizationNameKey,CNContactPhoneNumbersKey] as [Any]
            let request = CNContactFetchRequest(keysToFetch: keys as! [CNKeyDescriptor])
            request.sortOrder = CNContactSortOrder.givenName
            do{
                var cons:[YZContact] = []
                try self.contactStore.enumerateContacts(with: request) { (contact, pointer) in
                    let kpContect = YZContact(contact: contact)
                    if self.validateContact(contact: kpContect){
                        cons.append(kpContect)
                    }
                }
                contacts = self.prepareContectIndexData(contacts: cons)
                
                DispatchQueue.main.async {
                    completion(contacts, nil)
                }
            }catch let err{
                DispatchQueue.main.async {
                    completion(contacts, err)
                }
            }
        }
    }
}

class YZContactManager: NSObject {
    
    static let shared = YZContactManager()
    let contactStore = CNContactStore()
    var contactMustContain = ContactType()
    
    /// Create contacts array index wise
    ///
    /// - Parameter contacts: contact object array
    /// - Returns: return alphabet index array
    fileprivate func prepareContectIndexData(contacts: [YZContact])->[String: [YZContact]]{
        let arrAlpha = ["A","B","C","D","E","F","G","H","I","J","K","L","M","N","O","P","Q","R","S","T","U","V","W","X","Y","Z"]
        var arrContacts:[String: [YZContact]] = [:]
        for alpha in arrAlpha{
            let cons = contacts.filter({ (contact) -> Bool in
                if !contact.firstName.isEmpty{
                    return contact.firstName.uppercased().first == alpha.uppercased().first
                }else if !contact.lastName.isEmpty{
                    return contact.lastName.uppercased().first == alpha.uppercased().first
                }else if !contact.orgName.isEmpty{
                    return contact.orgName.uppercased().first == alpha.uppercased().first
                }else{
                    return false
                }
            })
            if !cons.isEmpty{
                arrContacts[alpha] = cons
            }
        }
        
        let nonAlpha = contacts.filter { (contact) -> Bool in
            if !contact.firstName.isEmpty{
                return contact.firstName.uppercased().first! < "A"
            }else if !contact.lastName.isEmpty{
                return contact.lastName.uppercased().first! < "A"
            }else if !contact.orgName.isEmpty{
                return contact.orgName.uppercased().first! < "A"
            }else{
                return false
            }
        }
        
        if !nonAlpha.isEmpty{
            arrContacts["#"] = nonAlpha
        }
        return arrContacts
    }
    
    //MARK:- Validate Contact
    fileprivate func validateContact(contact: YZContact) -> Bool{
        if self.contactMustContain.contains(ContactType.address){
            if checkAddressExists(contact: contact){
                if self.contactMustContain.contains(ContactType.email){
                    if checkEmailExists(contact: contact){
                        if self.contactMustContain.contains(ContactType.phone){
                            return checkPhoneExists(contact: contact)
                        }else{
                            return true
                        }
                    }else{
                        return false
                    }
                }else{
                    if self.contactMustContain.contains(ContactType.phone){
                        return checkPhoneExists(contact: contact)
                    }else{
                        return true
                    }
                }
            }else{
                return false
            }
        }else if self.contactMustContain.contains(ContactType.email){
            if checkEmailExists(contact: contact){
                if self.contactMustContain.contains(ContactType.phone){
                    return checkPhoneExists(contact: contact)
                }else{
                    return true
                }
            }else{
                return false
            }
        }else if self.contactMustContain.contains(ContactType.phone){
            return checkPhoneExists(contact: contact)
        }else{
            return true
        }
    }
    
    fileprivate func checkEmailExists(contact:YZContact) -> Bool {
        return !contact.emails.isEmpty
    }
    
    fileprivate func checkAddressExists(contact:YZContact) -> Bool {
        return !contact.addresses.isEmpty
    }
    
    fileprivate func checkPhoneExists(contact:YZContact) -> Bool {
        return !contact.phoneNo.isEmpty
    }
}

