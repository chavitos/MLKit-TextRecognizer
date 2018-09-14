//
//  CamViewController.swift
//  pocMLTextRecognizer
//
//  Created by Tiago Chaves on 14/09/2018.
//  Copyright © 2018 iCarros. All rights reserved.
//

import UIKit
import SwiftyCam

class CamViewController: SwiftyCamViewController {

    let segue = "camToDetail"
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        self.cameraDelegate = self
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let vc = segue.destination as? DetailViewController {
            if let photo = sender as? UIImage {
                vc.photo = photo
            }
        }
    }
    
    @IBAction func takePhoto(_ sender: Any) {
        takePhoto()
    }
}

extension CamViewController:SwiftyCamViewControllerDelegate {
    
    func swiftyCam(_ swiftyCam: SwiftyCamViewController, didTake photo: UIImage) {
        
        var pictureOriented:UIImage
        
        guard let cgImage = photo.cgImage else { return }
        
        switch UIDevice.current.orientation{
        case .portrait:
            pictureOriented = UIImage(cgImage: cgImage, scale: 2.0, orientation: UIImageOrientation.right)
            break
        case .portraitUpsideDown:
            pictureOriented = UIImage(cgImage: cgImage, scale: 2.0, orientation: UIImageOrientation.left)
            break
        case .landscapeLeft:
            pictureOriented = UIImage(cgImage: cgImage, scale: 2.0, orientation: UIImageOrientation.up)
            break
        case .landscapeRight:
            pictureOriented = UIImage(cgImage: cgImage, scale: 2.0, orientation: UIImageOrientation.down)
            break
        default:
            pictureOriented = photo
            break
        }
        
        performSegue(withIdentifier: segue, sender: pictureOriented.scaleAndRotate())
    }
}

extension UIImage {
    
    func scaleAndRotate() -> UIImage {
        // No-op if the orientation is already correct
        if imageOrientation == .up {
            return self
        }
        
        // We need to calculate the proper trans    ion to make the image upright.
        // We do it in 2 steps: Rotate if Left/Right/Down, and then flip if Mirrored.
        var transform = CGAffineTransform.identity
        
        switch imageOrientation {
        case .down, .downMirrored:
            transform = transform.translatedBy(x: self.size.width, y: self.size.height)
            transform = transform.rotated(by:CGFloat(Double.pi))
            break;
            
        case .left, .leftMirrored:
            transform = transform.translatedBy(x: self.size.width, y: 0)
            transform = transform.rotated(by:CGFloat(Double.pi/2))
            break;
            
        case .right, .rightMirrored:
            transform = transform.translatedBy(x: 0, y: self.size.height)
            transform = transform.rotated(by:CGFloat(-Double.pi/2))
            break;
        case .up, .upMirrored:
            break;
        }
        
        switch imageOrientation {
        case .upMirrored, .downMirrored:
            transform.translatedBy(x: self.size.width, y: 0)
            transform.scaledBy(x: -1, y: 1)
            break;
            
        case .leftMirrored, .rightMirrored:
            transform.translatedBy(x: self.size.height, y: 0)
            transform.scaledBy(x: -1, y: 1)
            break;
        case .up, .down, .left, .right:
            break;
        }
        
        // Now w2e draw the underlying CGImage into a new context, applying the transform
        // calculated above.
        guard
            let cgImg = self.cgImage,
            let colorSpace = cgImg.colorSpace,
            let ctx: CGContext = CGContext(data: nil,
                                           width: Int(size.width), height: Int(size.height),
                                           bitsPerComponent: cgImg.bitsPerComponent,
                                           bytesPerRow: 0,
                                           space: colorSpace,
                                           bitmapInfo: CGImageAlphaInfo.premultipliedLast.rawValue)
            else { return UIImage() }
        
        ctx.concatenate(transform)
        
        switch imageOrientation {
        case .left, .leftMirrored, .right, .rightMirrored:
            ctx.draw(cgImg, in: CGRect(x: 0, y: 0, width: size.height, height: size.width))
            break
        default:
            ctx.draw(cgImg, in: CGRect(x: 0, y: 0, width: size.width, height: size.height))
            break
        }
        
        // And now we just create a new UIImage from the drawing context
        if let cgImage: CGImage = ctx.makeImage() {
            return UIImage(cgImage: cgImage)
        } else {
            return UIImage()
        }
    }
}
