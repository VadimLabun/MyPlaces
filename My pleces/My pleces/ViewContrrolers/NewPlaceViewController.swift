//
//  NewPlaceViewController.swift
//  My pleces
//
//  Created by Vadim Labun on 8/31/19.
//  Copyright © 2019 Vadim Labun. All rights reserved.
//

import UIKit

class NewPlaceViewController: UITableViewController {
    var curentPlace: Place!
    var imageIsChanged = false

    @IBOutlet var placeType: UITextField!
    @IBOutlet var placeLocation: UITextField!
    @IBOutlet var placeName: UITextField!
    @IBOutlet var placeImage: UIImageView!
    @IBOutlet var saveButton: UIBarButtonItem!
    @IBOutlet var ratingControl: RatingControl!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.tableFooterView = UIView(frame: CGRect(x: 0,
                                                         y: 0,
                                                         width: tableView.frame.size.width,
                                                         height: 1))
        
        saveButton.isEnabled = false
        placeName.addTarget(self,action: #selector(textFieldChanget), for: .editingChanged)
        setupEditScreen()
    }
    //    MARK: Table View Delegate
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.row == 0 {
            let cameraIcon = #imageLiteral(resourceName: "camera")
            let photoIcon = #imageLiteral(resourceName: "photo")
            let actionSheet = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
            let camera = UIAlertAction(title: "Camera", style: .default) { _ in
                self.chooseImagePicker(source: .camera)
            }
            camera.setValue(cameraIcon, forKey: "image")
            camera.setValue(CATextLayerAlignmentMode.left, forKey: "titleTextAlignment")
            let photo = UIAlertAction(title: "Photo", style: .default) { _ in
                self.chooseImagePicker(source: .photoLibrary)
            }
            photo.setValue(photoIcon, forKey: "image")
            photo.setValue(CATextLayerAlignmentMode.left, forKey: "titleTextAlignment")
            let cancel = UIAlertAction(title: "Cancel", style: .cancel)
            actionSheet.addAction(camera)
            actionSheet.addAction(photo)
            actionSheet.addAction(cancel)
            
            present(actionSheet, animated: true)
        } else {
            view.endEditing(true)
        }
    }
    
    //    MARK: Navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        guard
            let identifier = segue.identifier,
            let mapVC = segue.destination as? MapViewController
            else {return}
        
        
            mapVC.inComSegueIdentifier = identifier
            mapVC.MapViewControllerDelegate = self
        
            if identifier == "showMap" {
            mapVC.place.name = placeName.text ?? ""
            mapVC.place.location = placeLocation.text
            mapVC.place.type = placeType.text
            mapVC.place.imageData = placeImage.image?.pngData()
        }
    }
    
    func sevePlace(){
        let image = imageIsChanged ? placeImage.image : nil
    
        let newPlace = Place(name: placeName.text ?? "",
                             location: placeLocation.text,
                             type: placeType.text,
                             imageData: image?.pngData(),
                             rating: Double(ratingControl.rating))
        
        if curentPlace != nil {
            try? realm.write {
                curentPlace?.name = newPlace.name
                curentPlace?.location = newPlace.location
                curentPlace?.type = newPlace.type
                curentPlace?.imageData = newPlace.imageData
                curentPlace?.rating = newPlace.rating
            }
        } else {
            StorageManager.saveObject(newPlace)
        }
        
    }
    
    private func setupEditScreen() {
        if curentPlace != nil {
            setupNavigationBar()
            
            if let data = curentPlace.imageData, let image = UIImage(data: data) {
                placeImage.image = image
                 imageIsChanged = true
            }else {
                placeImage.image = #imageLiteral(resourceName: "imagePlaceholder")
                imageIsChanged = false
            }
        
            placeImage.contentMode = .scaleAspectFill
            placeName.text = curentPlace?.name
            placeLocation.text = curentPlace?.location
            placeType.text = curentPlace?.type
            ratingControl.rating = Int(curentPlace.rating)
        }
    }
    func setupNavigationBar() {
        if let topItem = navigationController?.navigationBar.topItem {
            topItem.backBarButtonItem = UIBarButtonItem(title: "", style: .plain, target: nil, action: nil)
        }
        navigationItem.leftBarButtonItem = nil
        title = curentPlace?.name
        saveButton.isEnabled = true
    }
    
    @IBAction func cancelAction(_ sender: UIBarButtonItem) {
        dismiss(animated: true)
    }
    
}
// MARK: Text Fild delegate
extension NewPlaceViewController: UITextFieldDelegate {
//    скрываем клавиатуру при нажатии на Done
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    @objc private func textFieldChanget() {
        if placeName.text?.isEmpty == false {
            saveButton.isEnabled = true
        } else {
            saveButton.isEnabled = false
        }
    }
}
// MARK: Work with image
extension NewPlaceViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    func chooseImagePicker(source: UIImagePickerController.SourceType) {
        if UIImagePickerController.isSourceTypeAvailable(source) {
            let imagePicker = UIImagePickerController()
            imagePicker.delegate = self
            imagePicker.allowsEditing = true
            imagePicker.sourceType = source
            present(imagePicker, animated: true)
        }
    }
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        placeImage.image = info[.editedImage] as? UIImage
        placeImage.contentMode = .scaleAspectFill
        placeImage.clipsToBounds = true
        imageIsChanged = true
        dismiss(animated: true)
    }
}

extension NewPlaceViewController: MapViewControllerDelegate {
    func getAddress(_ address: String?) {
        placeLocation.text = address
    }
    
    
}

