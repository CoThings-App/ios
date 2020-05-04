//
//  ServerSettingsViewController.swift
//  CoThings
//
//  Created by Neso on 2020/05/02.
//  Copyright © 2020 Rainlab. All rights reserved.
//

import UIKit

class ServerSettingsViewController: UIViewController {

    @IBOutlet weak var serverHostname: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    
    @IBAction func buttonConnectTapped(_ sender: Any) {
        UserDefaults.standard.set(serverHostname.text!, forKey: "serverHostname")
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        guard let initialVC = storyboard.instantiateInitialViewController() else { return }
        self.present(initialVC, animated: true, completion: nil)
    }
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
