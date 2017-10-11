//
//  CameraCell.swift
//  Pods
//
//  Created by Joakim Gyllström on 2015-09-26.
//
//

import UIKit
import AVFoundation

/**
*/
final class CameraCell: UICollectionViewCell {
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var cameraBackground: UIView!
    weak var cameraOverlayView: UIView?
    var cameraOverlayAlpha: CGFloat {
        get {
            return cameraOverlayView?.alpha ?? 0
        }
        set {
            if session != nil && newValue > 0 {
                if cameraOverlayView == nil {
                    let overlayView = UIView(frame: cameraBackground.bounds)
                    overlayView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
                    overlayView.backgroundColor = .black
                    cameraBackground.addSubview(overlayView)
                    cameraOverlayView = overlayView
                }
                cameraOverlayView?.alpha = newValue
            } else {
                cameraOverlayView?.removeFromSuperview()
            }
        }
    }
    @objc var takePhotoIcon: UIImage? {
        didSet {
            imageView.image = takePhotoIcon
            
            // Apply tint to image
            imageView.image = imageView.image?.withRenderingMode(.alwaysTemplate)
        }
    }
    
    @objc var session: AVCaptureSession?
    @objc var captureLayer: AVCaptureVideoPreviewLayer?
    @objc let sessionQueue = DispatchQueue(label: "AVCaptureVideoPreviewLayer", attributes: [])
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        // Don't trigger camera access for the background
        guard AVCaptureDevice.authorizationStatus(for: AVMediaType.video) == .authorized else {
            return
        }
        
        do {
            // Prepare avcapture session
            session = AVCaptureSession()
            session?.sessionPreset = AVCaptureSession.Preset.medium
            
            // Hook upp device
            let device = AVCaptureDevice.default(for: AVMediaType.video)
            let input = try AVCaptureDeviceInput(device: device!)
            session?.addInput(input)
            
            // Setup capture layer

            guard session != nil else {
                return
            }
          
            let captureLayer = AVCaptureVideoPreviewLayer(session: session!)
            captureLayer.frame = bounds
            captureLayer.videoGravity = AVLayerVideoGravity.resizeAspectFill
            cameraBackground.layer.addSublayer(captureLayer)

            self.captureLayer = captureLayer
        } catch {
            session = nil
        }
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        captureLayer?.frame = bounds
    }
    
    @objc func startLiveBackground() {
        sessionQueue.async { () -> Void in
            self.session?.startRunning()
        }
    }
    
    @objc func stopLiveBackground() {
        sessionQueue.async { () -> Void in
            self.session?.stopRunning()
        }
    }
}
