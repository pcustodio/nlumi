//
//  AboutViewController.swift
//  nlumi
//
//  Created by Paulo Custódio on 02/03/2020.
//  Copyright © 2020 Paulo Custódio. All rights reserved.
//

import UIKit

class AboutViewController: UIViewController {
    
    @IBOutlet weak var mainTxt: UILabel!
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //large title
        navigationController?.navigationBar.prefersLargeTitles = true
        mainTxt.sizeToFit()
        
    }

    @IBAction func shareThis(_ sender: UIBarButtonItem) {
        if let urlStr = NSURL(string: "https://apps.apple.com/pt/story/id1495860553?l=en") {
            let objectsToShare = [urlStr]
            let activityVC = UIActivityViewController(activityItems: objectsToShare, applicationActivities: nil)

            if UIDevice.current.userInterfaceIdiom == .pad {
                if let popup = activityVC.popoverPresentationController {
                    popup.sourceView = self.view
                    popup.sourceRect = CGRect(x: self.view.frame.size.width / 2, y: self.view.frame.size.height / 4, width: 0, height: 0)
                }
            }

            self.present(activityVC, animated: true, completion: nil)
        }
    }
}
