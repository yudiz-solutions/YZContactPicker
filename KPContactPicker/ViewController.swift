//
//  ViewController.swift
//  ContactPickerDemo
//
//  Created by Yudiz on 12/28/16.
//  Copyright © 2016 Yudiz. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
    
    @IBOutlet var lblName: UILabel!
    @IBOutlet var lblConNo: UILabel!
    @IBOutlet var lblEmail: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        KPContactManager.shared.contactMustContain = [.phone]
        // Do any additional setup after loading the view, typically from a nib.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}


// MARK: - Button Action
extension ViewController{

    @IBAction func selectContact(sender: UIButton){
        let pickerVC = UIStoryboard(name: "KPContact", bundle: nil).instantiateViewController(withIdentifier: "KPContactPickerVC") as! KPContactPickerVC
        pickerVC.selectionBlock = { [unowned self] contact in
            self.lblName.text = contact.fullName
            if let ph = contact.phoneNo.first{
                self.lblConNo.text = ph.phoneNumber
            }else{
                self.lblConNo.text = "-"
            }
            if let email = contact.emails.first{
                self.lblEmail.text = email.email
            }else{
                self.lblEmail.text = "-"
            }
        }
        self.navigationController?.pushViewController(pickerVC, animated: true)
    }
}
