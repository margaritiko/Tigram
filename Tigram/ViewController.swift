//
//  ViewController.swift
//  Tigram
//
//  Created by Маргарита Коннова on 10/02/2019.
//  Copyright © 2019 Margarita Konnova. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    // MARK: Outlets
    
    @IBOutlet weak var editButton: UIButton!
    @IBOutlet weak var userPhoto: UIImageView!
    @IBOutlet weak var cameraButton: UIButton!
    
    @IBAction func cameraButtonClicked(_ sender: Any) {
        
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        // Edit button's design details
        editButton.layer.cornerRadius = 10
        editButton.layer.borderColor = UIColor.black.cgColor
        editButton.layer.borderWidth = 1
        editButton.contentEdgeInsets = UIEdgeInsets(top: 12, left: 0, bottom: 12, right: 0)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        print("ViewController Lifecycle: [\(#function)]")
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        print("ViewController Lifecycle: [\(#function)]")
    }
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        print("ViewController Lifecycle: [\(#function)]")
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        print("ViewController Lifecycle: [\(#function)]")
        
        // The right place to work with geometry
        userPhoto.layer.cornerRadius = cameraButton.bounds.height / 2
        cameraButton.layer.cornerRadius = cameraButton.bounds.height / 2
        let paddings = cameraButton.bounds.height * 0.22
        cameraButton.imageEdgeInsets = UIEdgeInsets(top: paddings, left: paddings, bottom: paddings, right: paddings)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        print("ViewController Lifecycle: [\(#function)]")
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        print("ViewController Lifecycle: [\(#function)]")
    }

}

