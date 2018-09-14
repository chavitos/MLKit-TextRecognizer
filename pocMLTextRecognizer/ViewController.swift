//
//  ViewController.swift
//  pocMLTextRecognizer
//
//  Created by Tiago Chaves on 13/09/2018.
//  Copyright © 2018 iCarros. All rights reserved.
//

import UIKit
import FirebaseMLVision

class ViewController: UIViewController {

    @IBOutlet weak var image: UIImageView!
    @IBOutlet weak var plateRecognized: UILabel!
    
    var textDetector:VisionTextDetector!
    let plateRegex = "[A-Z]{3}( |-| -|- | - )?[0-9]{4}"
    let images = ["placa1","placa2","placa3","placa4"]
    var imageIndex = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //text detector init
        let vision = Vision.vision()
        textDetector = vision.textDetector()
        
        image.image = UIImage(named: images[imageIndex])
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    @IBAction func changeImage(_ sender: Any) {
    
        if imageIndex < images.count - 1 {
            imageIndex += 1
            image.image = UIImage(named: images[imageIndex])
        }else{
            imageIndex = 0
            image.image = UIImage(named: images[imageIndex])
        }
    }
    
    @IBAction func captureText(_ sender: Any) {
        textRecognition(atImage: self.image.image!)
    }
    
    func textRecognition(atImage image:UIImage) {
        let visionImage = VisionImage(image: image)
        textDetector.detect(in: visionImage) { (features, error) in
            self.processResult(from: features, error: error)
        }
    }
    
    func processResult(from text: [VisionText]?, error: Error?) {
        
        guard let features = text else { return }
        var textFound = ""
        
        for text in features {
            if let block = text as? VisionTextBlock {
                print(block.text)
                textFound = textFound + block.text
            }
        }
        print(textFound)
        if let plate = listMatches(for: plateRegex, inString: textFound).first {
            print(plate)
            plateRecognized.text = "Placa: \(plate)"
        }else{
            plateRecognized.text = "Placa não detectada"
        }
    }
    
    func listMatches(for pattern: String, inString string: String) -> [String] {
        guard let regex = try? NSRegularExpression(pattern: pattern, options: []) else {
            return []
        }
        
        let range = NSRange(string.startIndex..., in: string)
        let matches = regex.matches(in: string, options: [], range: range)
        
        return matches.map {
            let range = Range($0.range, in: string)!
            return String(string[range])
        }
    }
}

