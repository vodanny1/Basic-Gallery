//
//  DetailViewController.swift
//  Challenge3
//
//  Created by Danny Vo on 2020-06-19.
//  Copyright © 2020 Danny Vo. All rights reserved.
//

import UIKit

class DetailViewController: UIViewController {
    @IBOutlet var imgView: UIImageView!
    @IBOutlet var captionLabel: UILabel!
    var selectedImage: Picture?
    var imagePath: String?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .action, target: self, action: #selector(shareTapped))
        
        if let imageToLoad = selectedImage {
            //imgView.image = UIImage(named: imageToLoad.image)
            let imagePath = getDocumentsDirectory().appendingPathComponent(imageToLoad.image)
            imgView.image = UIImage(contentsOfFile: imagePath.path)
            captionLabel.text = imageToLoad.caption
        }
    }
    
    @objc func shareTapped() {
        guard let image = imgView.image?.jpegData(compressionQuality: 0.8) else {
            print("No image found")
            return
        }
        
        let vc = UIActivityViewController(activityItems: [image], applicationActivities: [])
        vc.popoverPresentationController?.barButtonItem = navigationItem.rightBarButtonItem
        present(vc, animated: true)
    }
    
    func getDocumentsDirectory() -> URL {
        let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        return paths[0]
    }

}
