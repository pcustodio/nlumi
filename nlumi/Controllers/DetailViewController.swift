//
//  DetailViewController.swift
//  nlumi
//
//  Created by Paulo Custódio on 25/02/2020.
//  Copyright © 2020 Paulo Custódio. All rights reserved.
//

import UIKit

class DetailViewController: UIViewController {
  

    @IBOutlet weak var ptLabel: UILabel!
    @IBOutlet weak var gramaticaLabel: UILabel!
    @IBOutlet weak var changanaLabel: UILabel!
    @IBOutlet weak var macuaLabel: UILabel!
    @IBOutlet weak var xirongaLabel: UILabel!
    
    
    var ptWord = ""
    var grWord = ""
    var chWord = ""
    var maWord = ""
    var xiWord = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        ptLabel.text = ptWord
        gramaticaLabel.text = grWord
        changanaLabel.text = chWord
        macuaLabel.text = maWord
        xirongaLabel.text = xiWord
        
    }
    
}
