//
//  NoteVC.swift
//  FoodApp
//
//  Created by iMac on 01/08/20.
//  Copyright © 2020 Mitesh's MAC. All rights reserved.
//

import UIKit

class NoteVC: UIViewController {

    @IBOutlet weak var btn_ok: UIButton!
    @IBOutlet weak var text_viewNote: UITextView!
    var Note = String()
    override func viewDidLoad() {
        super.viewDidLoad()
        self.text_viewNote.text = Note
        cornerRadius(viewName: btn_ok, radius: 6.0)
        cornerRadius(viewName: text_viewNote, radius: 6.0)
    }
    

    @IBAction func btnTap_Ok(_ sender: UIButton) {
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func btnTap_dismiss(_ sender: UIButton) {
        self.dismiss(animated: true, completion: nil)
    }
}
