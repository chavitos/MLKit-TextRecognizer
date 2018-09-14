//
//  DetailViewController.swift
//  pocMLTextRecognizer
//
//  Created by Tiago Chaves on 14/09/2018.
//  Copyright © 2018 iCarros. All rights reserved.
//

import UIKit
import FirebaseMLVision

class DetailViewController: UIViewController {

    @IBOutlet weak var plateRecognized: UILabel!
    @IBOutlet weak var textRecognized: UILabel!
    
    var photo:UIImage?
    var textDetector:VisionTextDetector!
    let plateRegex = "[A-Z]{3}( |-| -|- | - )?[0-9]{4}"
    
    override func viewDidLoad() {
        super.viewDidLoad()

        //text detector init
        let vision = Vision.vision()
        textDetector = vision.textDetector()
        textRecognition(atImage: photo!)
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
        textRecognized.text = textFound
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
