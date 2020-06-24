//
//  ViewController.swift
//  Challenge3
//
//  Created by Danny Vo on 2020-06-18.
//  Copyright © 2020 Danny Vo. All rights reserved.
//

import UIKit

class ViewController: UICollectionViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    var album = [Picture]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = "Memories"
        
        navigationItem.leftBarButtonItem = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(addNewImage))
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .camera, target: self, action: #selector(takePicture))
        
        let defaults = UserDefaults.standard
        
        if let savedAlbum = defaults.object(forKey: "album") as? Data {
            let jsonDecoder = JSONDecoder()
            
            do {
                album = try jsonDecoder.decode([Picture].self, from: savedAlbum)
            } catch {
                print("Failed to load album")
            }
        }
    }
    
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return album.count
    }
    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "Picture", for: indexPath) as? PictureCell else {
            fatalError("Unable to dequeue PictureCell")
        }
        let picture = album[indexPath.item]
        cell.caption.text = picture.caption
        
        let path = getDocumentsDirectory().appendingPathComponent(picture.image)
        cell.imageView.image = UIImage(contentsOfFile: path.path)
        
        cell.imageView.layer.borderColor = UIColor(white: 0, alpha: 0.3).cgColor
        cell.imageView.layer.borderWidth = 2
        cell.imageView.layer.cornerRadius = 3
        cell.layer.cornerRadius = 7
        
        return cell
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        
        guard let image = info[.editedImage] as? UIImage else { return }
        
        let imageCaption = UUID().uuidString
        let imagePath = getDocumentsDirectory().appendingPathComponent(imageCaption)
        
        if let jpegData = image.jpegData(compressionQuality: 0.8){
            try? jpegData.write(to: imagePath)
        }
        
        let picture = Picture(caption: "Image", image: imageCaption)
        album.append(picture)
        save() // saving image
        collectionView.reloadData()
        
        dismiss(animated: true)
    }
    
    override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        let picture = album[indexPath.item]
        
        let ac = UIAlertController(title: "What do you want to do?", message: nil, preferredStyle: .alert)
        
        ac.addAction(UIAlertAction(title: "Edit Caption", style: .default, handler: {action in self.editCaption(picture)}))
        
        ac.addAction(UIAlertAction(title: "View Post", style: .default, handler: {action in self.viewImage(picture)}))
        
        ac.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        
        present(ac, animated: true)
    }
    
    func getDocumentsDirectory() -> URL {
        let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        return paths[0]
    }

    func viewImage(_ picture: Picture){
        if let vc = storyboard?.instantiateViewController(withIdentifier: "Detail") as? DetailViewController{
            vc.selectedImage = picture
            navigationController?.pushViewController(vc, animated: true)
        }
    }
    
    func editCaption(_ picture: Picture){
        let ac = UIAlertController(title: "Type new caption", message: nil, preferredStyle: .alert)
        ac.addTextField()
        ac.addAction(UIAlertAction(title: "OK", style: .default){ [weak self, weak ac] _ in
            guard let newCaption = ac?.textFields?[0].text else { return }
            picture.caption = newCaption
            self?.save()
            self?.collectionView.reloadData()
        })
        
        ac.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        present(ac, animated: true)
    }
    
    @objc func addNewImage(){
        let picker = UIImagePickerController()
        picker.allowsEditing = true
        picker.delegate = self
        present(picker, animated: true)
    }
    
    @objc func takePicture(){
        if UIImagePickerController.isSourceTypeAvailable(UIImagePickerController.SourceType.camera){
            let imagePicker = UIImagePickerController()
            imagePicker.delegate = self
            imagePicker.sourceType = UIImagePickerController.SourceType.camera
            imagePicker.allowsEditing = true
            present(imagePicker, animated: true)
        } else {
            let alert  = UIAlertController(title: "Warning", message: "You don't have camera", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
            present(alert, animated: true, completion: nil)
        }
    }
    
    func save() {
        let jsonEncoder = JSONEncoder()
        
        if let savedData = try? jsonEncoder.encode(album){
            let defaults = UserDefaults.standard
            defaults.set(savedData, forKey: "album")
        } else {
            print("Failed to saved album")
        }
    }
}

