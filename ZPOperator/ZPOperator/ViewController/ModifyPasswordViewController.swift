//
//  ModifyPasswordViewController.swift
//  ZPOperator
//
//  Created by 杜进新 on 2017/6/27.
//  Copyright © 2017年 dujinxin. All rights reserved.
//

import UIKit

class ModifyPasswordViewController: UITableViewController {

    @IBOutlet weak var oldTextField: UITextField!
    @IBOutlet weak var newTextField: UITextField!
    @IBOutlet weak var againTextField: UITextField!
    @IBOutlet weak var confirmLabel: UILabel!
    
    var vm = LoginVM()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Table view data source

    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        if section == 0 {
            return 10
        }else{
            return 120
        }
    }
    override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        return UIView()
    }
    
    override func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        return nil
    }
    override func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 0.1
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.section == 1 {
            self.vm.modifyPassword(old: oldTextField.text!, new: newTextField.text!) { (data, msg, isSuccess) in
                if isSuccess {
                    self.navigationController?.popViewController(animated: true)
                }else{
                    
                }
            }
        }
    }
}
