//
//  YZContactPickerVC.swift
//  ContactPickerDemo
//
//  Created by Yudiz on 12/29/16.
//  Copyright © 2016 Yudiz. All rights reserved.
//

import UIKit

class ContactCell: UITableViewCell {
    @IBOutlet var lblName: UILabel!
    @IBOutlet var lblMoNo: UILabel!
    @IBOutlet var imgView: UIImageView!
    @IBOutlet var lblNoImage: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        imgView.layer.cornerRadius = imgView.frame.height / 2
        imgView.layer.borderWidth = 0.0
        imgView.layer.masksToBounds = true
    }
    
    override func prepareForReuse() {
        imgView.image = nil
    }
}

class YZContactPickerVC: UIViewController {
    
    @IBOutlet var tableView: UITableView!
    @IBOutlet var searchBar: UISearchBar!
    
    var keys: [String] = []
    var contcs: [String: [YZContact]] = [:]
    var searchContcs: [String: [YZContact]] = [:]
    var selectionBlock: ((YZContact)->())?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        prepareForkeyboardNotification()
        YZContactManager.shared.requestForAccess { (accessGranted) in
            if accessGranted{
                YZContactManager.shared.fetchContactIndexArray(completion: { (contcs, error) in
                    self.keys = Array(contcs.keys).sorted()
                    self.contcs = contcs
                    self.searchContcs = contcs
                    self.tableView.reloadData()
                })
            }else{
                print("No Access!!!. You can allow access in Settings > Privacy > Contacts")
            }
        }
        
        // Do any additional setup after loading the view, typically from a nib.
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
}


// MARK: - Tableview methods
extension YZContactPickerVC: UITableViewDelegate, UITableViewDataSource{
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return keys.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return searchContcs[keys[section]]!.count
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return keys[section]
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 61
    }
    
    func sectionIndexTitles(for tableView: UITableView) -> [String]? {
        return ["#","A","B","C","D","E","F","G","H","I","J","K","L","M","N","O","P","Q","R","S","T","U","V","W","X","Y","Z"]
    }
    
    func tableView(_ tableView: UITableView, sectionForSectionIndexTitle title: String, at index: Int) -> Int{
        if keys.contains(title){
            return keys.firstIndex(of: title)!
        }
        return -1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as! ContactCell
        let conct = searchContcs[keys[indexPath.section]]![indexPath.row]
        cell.lblName.text = conct.fullName
        
        if let ph = conct.phoneNo.first{
            cell.lblMoNo.text = ph.phoneNumber
        }else if let email = conct.emails.first{
            cell.lblMoNo.text = email.email
        }else{
            cell.lblMoNo.text = ""
        }
        
        if let img = conct.image{
            cell.imgView.image = img
            cell.lblNoImage.isHidden = true
        }else{
            cell.lblNoImage.isHidden = false
            let comp = conct.fullName.components(separatedBy: " ")
            var str = ""
            if !comp.isEmpty{
                for con in comp{
                    str += String(con.first!)
                }
            }
            cell.lblNoImage.text = str
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        selectionBlock?(searchContcs[keys[indexPath.section]]![indexPath.row])
        _ = self.navigationController?.popViewController(animated: true)
    }
}


// MARK: - Search Bar
extension YZContactPickerVC: UISearchBarDelegate{
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String){
        searchContcs = [:]
        keys = []
        if !searchBar.text!.isEmpty{
            for (key,data) in contcs {
                let contcs = data.filter({ (contact) -> Bool in
                    return contact.fullName.contains(searchBar.text!)
                })
                
                if !contcs.isEmpty{
                    searchContcs[key] = contcs
                    self.keys.append(key)
                }
            }
        }else{
            searchContcs = contcs
            keys = Array(searchContcs.keys)
        }
        
        self.keys = keys.sorted()
        tableView.reloadData()
    }
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar){
        searchBar.resignFirstResponder()
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar){
        searchBar.resignFirstResponder()
    }
}

// MARK: - Keyboard Extension
extension YZContactPickerVC {
    func prepareForkeyboardNotification() {
        NotificationCenter.default.addObserver(self, selector: #selector(YZContactPickerVC.keyboardWillShow), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(YZContactPickerVC.keyboardWillHide), name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    
    @objc func keyboardWillShow(notification: NSNotification){
        if let kbSize = (notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue {
            tableView.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: kbSize.height, right: 0)
        }
    }
    
    @objc func keyboardWillHide(notification: NSNotification){
        tableView.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: 20, right: 0)
    }
}
