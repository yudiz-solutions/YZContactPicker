//
//  KPContactModel.swift
//  ContactPickerDemo
//
//  Created by Yudiz on 12/28/16.
//  Copyright © 2016 Yudiz. All rights reserved.
//

import Foundation
import UIKit
import Contacts

class KPContact: NSObject {
    let contactId: String
    let firstName: String
    let lastName: String
    let DOB: Date?
    let image: UIImage?
    let orgName: String
    var phoneNo:[KPPhoneNo]
    var addresses:[KPPostalAddress]
    var emails:[KPEmail]
    
    var fullName : String{
        if !firstName.isEmpty && !lastName.isEmpty{
            return firstName + " " + lastName
        }else if !firstName.isEmpty{
            return firstName
        }else if !lastName.isEmpty{
            return lastName
        }else if !orgName.isEmpty{
            return orgName
        }else{
            return ""
        }
    }
    
    // init contact form default Apple contact entity.
    init(contact: CNContact) {
        contactId = contact.identifier
        firstName = contact.givenName
        lastName = contact.familyName
        if let date = contact.birthday?.date{
            DOB = date
        }else{
            DOB = nil
        }
        
        if let imgData = contact.imageData{
            image = UIImage(data: imgData)
        }else{
            image = nil
        }
        
        orgName = contact.organizationName
        phoneNo = []
        for phNo in contact.phoneNumbers {
            let phone = KPPhoneNo(phone: phNo.value)
            phoneNo.append(phone)
        }
        
        emails = []
        for email in contact.emailAddresses {
            let emailAdd = KPEmail(emailAdd: email.value as String)
            emails.append(emailAdd)
        }
        
        addresses = []
        for add in contact.postalAddresses {
            let address = KPPostalAddress(add: add.value)
            addresses.append(address)
        }
        super.init()
    }
    
    override func isEqual(_ object: Any?) -> Bool {
        return contactId == (object as! KPContact).contactId
    }
}

class KPPhoneNo: NSObject {
    let phoneNumber: String
    init(phone: CNPhoneNumber) {
        phoneNumber = phone.stringValue
    }
}

class KPEmail: NSObject {
    let email: String
    init(emailAdd: String) {
        email = emailAdd
    }
}


class KPPostalAddress: NSObject {
    var street: String
    var city: String
    var state: String
    var postalCode: String
    var country: String
    var ISOCountryCode: String
    var formattedAddress: String
    var formattedAdd: String
    
    init(add: CNPostalAddress) {
        street = add.street
        city = add.city
        state = add.state
        postalCode = add.postalCode
        country = add.country
        ISOCountryCode = add.isoCountryCode
        let formatter = CNPostalAddressFormatter()
        formattedAddress = formatter.string(from: add)
        formattedAdd = formattedAddress.replacingOccurrences(of: "\n", with: ", ")
        super.init()
    }
}
