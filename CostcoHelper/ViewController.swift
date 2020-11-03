//
//  ViewController.swift
//  CostcoHelper
//
//  Created by Daniel Luo on 11/2/20.
//

import UIKit
import Vision

class ViewController: UIViewController {

    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var textView: UITextView!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    
    var request = VNRecognizeTextRequest(completionHandler: nil)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        stopAnimating()
    }
    
    private func startAnimating() {
        self.activityIndicator.startAnimating()
    }
    
    private func stopAnimating() {
        self.activityIndicator.stopAnimating()
    }

    @IBAction func touchUpInsideCameraButton(_ sender: Any) {
        setUpGallery()
    }
    
    private func setUpGallery() {
        
        if UIImagePickerController.isSourceTypeAvailable(.photoLibrary) {
            
            let imagePhotoLibraryPicker = UIImagePickerController()
            imagePhotoLibraryPicker.delegate = self
            imagePhotoLibraryPicker.allowsEditing = false
            imagePhotoLibraryPicker.sourceType = .photoLibrary
            self.present(imagePhotoLibraryPicker, animated: true, completion: nil)
            
        }
    }
    
    private func setUpVisionTextRecognitionimage(image: UIImage?) {
        
        // set up TextRecognition
    
        var textString = ""
        
        request = VNRecognizeTextRequest(completionHandler: { (request, error) in
            guard let observations = request.results as? [VNRecognizedTextObservation] else {fatalError("Received Invalid Observation")}
            
            for observation in observations {
                guard let topCandidate = observation.topCandidates(1).first else { print("No candidate")
                    continue
                }
                
                textString += "\n\(topCandidate.string)"
                
                DispatchQueue.main.async {
                    self.stopAnimating()
                    self.textView.text = textString
                }
            }
        })
        
        // Add some properties
        
        request.customWords = ["HI"]
        request.minimumTextHeight = 0.03
        request.recognitionLevel = .fast
        request.recognitionLanguages = ["en_US"]
        request.usesLanguageCorrection = true
        
        let requests = [request]
        
        // Creating request handler
        DispatchQueue.global(qos: .userInitiated).async {
            
            guard let img = image?.cgImage else {fatalError("Missing image to scan")}
            let handle = VNImageRequestHandler(cgImage: img, options: [:])
            try? handle.perform(requests)
            
        }
        
    }
}

extension ViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        
        picker.dismiss(animated: true, completion: nil)
        
        startAnimating()
        self.textView.text = ""
        
        let image = info[UIImagePickerController.InfoKey.originalImage] as? UIImage
        self.imageView.image = image
        
        setUpVisionTextRecognitionimage(image: image)
    }
}
