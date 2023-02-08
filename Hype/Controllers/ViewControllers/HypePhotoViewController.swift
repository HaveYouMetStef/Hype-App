//
//  HypePhotoViewController.swift
//  Hype
//
//  Created by Stef Castillo on 2/7/23.
//

import UIKit

class HypePhotoViewController: UIViewController {
    
    var image: UIImage?
    
    @IBOutlet weak var hypeTextField: UITextField!
    
    @IBOutlet weak var photoContainerView: UIView!
    override func viewDidLoad() {
        super.viewDidLoad()
        setupViews()
        
    }
    
    @IBAction func cancelButtonTapped(_ sender: Any) {
        dismissView()
    }
    
    @IBAction func confirmButtonTapped(_ sender: Any) {
        guard let text = hypeTextField.text, !text.isEmpty,
              let image = image
        else { return }
        
        HypeController.shared.saveHype(with: text, photo: image) { success in
            if success {
                self.dismissView()
            }
        }
    }
    
    func setupViews() {
        photoContainerView.layer.cornerRadius = photoContainerView.frame.height / 10
        photoContainerView.clipsToBounds = true
    }
    
    func dismissView() {
        DispatchQueue.main.async {
            self.dismiss(animated: true)
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "photoPickerVC" {
            let destinationVC = segue.destination as? PhotoPickerViewController
            destinationVC?.delegate = self
        }
    }
    
}

extension HypePhotoViewController: PhotoPickerDelegate {
    func photoPickerSelected(image: UIImage) {
        self.image = image
    }
    
    
}
