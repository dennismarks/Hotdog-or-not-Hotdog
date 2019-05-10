//
//  ViewController.swift
//  Hotdog or not Hotdog
//
//  Created by Dennis M on 2019-05-09.
//  Copyright © 2019 Dennis M. All rights reserved.
//

import UIKit
import CoreML
import Vision

class ViewController: UIViewController {

    @IBOutlet weak var imageView: UIImageView!
    let imagePicker = UIImagePickerController()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        imagePicker.delegate = self
        imagePicker.sourceType = .camera
        imagePicker.allowsEditing = true
    }
    
    @IBAction func cameraTapped(_ sender: UIBarButtonItem) {
        present(imagePicker, animated: true, completion: nil)
    }
    
    func detect(image: CIImage) {
        // vncoremlmodel - comes from the vision framework; allows us to perform an image analysisn request that uses our coreml model to process images
        guard let model = try? VNCoreMLModel(for: Inceptionv3().model) else {fatalError("loading coreML model failed")}
        let requst = VNCoreMLRequest(model: model) { (request, error) in
            guard let results = request.results as? [VNClassificationObservation] else {fatalError("model failed to proccess image")}
            print(results)
            if let firstResult = results.first  {
                let formatedConfidence = String(format: "%.2f %", firstResult.confidence)
                self.navigationItem.title = "\(formatedConfidence) – \(firstResult.identifier)"
            }
        }
        // perfrom request
        let handler = VNImageRequestHandler(ciImage: image)
        do {
            try handler.perform([requst])
        } catch {
            print(error)
        }
    }
}

extension ViewController: UIImagePickerControllerDelegate {
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        if let userPickedImage = info[UIImagePickerController.InfoKey.originalImage] as? UIImage {
            imageView.image = userPickedImage
            // allow us to use the vision framework and the coreML
            guard let ciimage = CIImage(image: userPickedImage) else {fatalError("couldn't convert to ciimage")}
            detect(image: ciimage)
        }
        imagePicker.dismiss(animated: true, completion: nil)
    }
    
}


extension ViewController: UINavigationControllerDelegate {
    
}
