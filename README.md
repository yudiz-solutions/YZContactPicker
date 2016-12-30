# KPContactPicker
KPContactPicker allow user to fetch contact from contact book, it allows user to filter contact by email, phone number and address. also user search contact by name.

## Screen shots
<br>
![Alt text](/../ScreenShot/Simulator%20Screen%20Shot%20Dec%2030%2C%202016%2C%2011.42.26%20AM.png?raw=true "Optional Title")
![Alt text](/../ScreenShot/Simulator%20Screen%20Shot%20Dec%2030%2C%202016%2C%2011.35.14%20AM.png?raw=true "Optional Title")

## Usages
- Set contactMustContain property if you want any specific contact with type (eg. phone, email, address)
```
KPContactManager.shared.contactMustContain = [.phone]
```
- Init KPContactPickerVC form KPContact story board and push into navigation controller or present.
```
let pickerVC = UIStoryboard(name: "KPContact", bundle: nil).instantiateViewController(withIdentifier: "KPContactPickerVC") as! KPContactPickerVC
pickerVC.selectionBlock = { contact in
    // Add your code here
}
self.navigationController?.pushViewController(pickerVC, animated: true)
```
KPContectPickerVC return selected contact in selection block.

## API Description
If you want create your custom UI with contacts the following API's will help ypu
- Request for contact book permission or check permission
```
KPContactManager.shared.requestForAccess { (accessGranted) in
    if accessGranted{
       // Access granted.
    }else{
       // Access denied.
    }
}
```

- Fetch contacts from Contacts framwork in alphabet index wise.
ex. ["A" : [KPContact, KPContact], "B" " [..,..]]
```
KPContactManager.shared.fetchContactIndexArray(completion: { (contcs, error) in
    // Add your code here
})
```

- Fetch contacts form Contacts framwork in simpel array fromat like. `[KPContact, KPContact]`
```
KPContactManager.shared.fetchContactArray { (concts, error) in
    // Add your code here            
}
```

- Search contact from name
```
KPContactManager.shared.searchContactByName(term: "Name") { (contcs, error) in
    // Add your code here
}
```
