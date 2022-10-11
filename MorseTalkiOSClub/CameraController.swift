//
//  CameraController.swift
//  MorseTalk
//
//  Created by Rahul Narayanan on 9/18/22.
//

import SwiftUI
import AVKit

// MARK: - File Information
/**
 We don't need to change anything in this class. It just handles the camera input.
 */
class CameraController: NSObject {
    var captureSession: AVCaptureSession?
    var camera: AVCaptureDevice?
    var cameraInput: AVCaptureDeviceInput?
    var previewLayer: AVCaptureVideoPreviewLayer?
    
    enum CameraControllerError: Swift.Error {
       case captureSessionAlreadyRunning
       case captureSessionIsMissing
       case inputsAreInvalid
       case invalidOperation
       case noCamerasAvailable
       case unknown
    }
    
    func prepare(completionHandler: @escaping (Error?) -> Void){
        func createCaptureSession(){
            self.captureSession = AVCaptureSession()
        }
        func configureCaptureDevices() throws {
            let camera = AVCaptureDevice.default(.builtInWideAngleCamera, for: .video, position: .front)
            
            self.camera = camera
            
            try camera?.lockForConfiguration()
            camera?.unlockForConfiguration()
                
        }
        
        func configureDeviceInputs() throws {
            guard let captureSession = self.captureSession else { throw CameraControllerError.captureSessionIsMissing }
            
            captureSession.sessionPreset = .high
            
            
            if let camera = self.camera {
                self.cameraInput = try AVCaptureDeviceInput(device: camera)
                   
                if captureSession.canAddInput(self.cameraInput!) { captureSession.addInput(self.cameraInput!)}
                else { throw CameraControllerError.inputsAreInvalid }
                   
            }
            
            else { throw CameraControllerError.noCamerasAvailable }
               
            captureSession.startRunning()
               
        }
           
        DispatchQueue(label: "prepare").async {
            do {
                createCaptureSession()
                try configureCaptureDevices()
                try configureDeviceInputs()
            }
                
            catch {
                DispatchQueue.main.async{
                    completionHandler(error)
                }
                
                return
            }
            
            DispatchQueue.main.async {
                completionHandler(nil)
            }
        }
    }
    
    func displayPreview(on view: UIView) throws {
        guard let captureSession = self.captureSession, captureSession.isRunning else { throw CameraControllerError.captureSessionIsMissing }
            
        self.previewLayer = AVCaptureVideoPreviewLayer(session: captureSession)
            self.previewLayer?.videoGravity = AVLayerVideoGravity.resizeAspectFill
        self.previewLayer?.connection?.videoOrientation = .portrait
        
        if let orientation = view.window?.windowScene?.interfaceOrientation {
            // print("Orientation: ", orientation.rawValue)

            switch orientation {
            case .portrait:
                self.previewLayer?.connection?.videoOrientation = .portrait
            case .portraitUpsideDown:
                self.previewLayer?.connection?.videoOrientation = .portraitUpsideDown
            case .landscapeLeft:
                self.previewLayer?.connection?.videoOrientation = .landscapeLeft
            case .landscapeRight:
                self.previewLayer?.connection?.videoOrientation = .landscapeRight
            default:
                self.previewLayer?.connection?.videoOrientation = .portrait
            }
        } else {
            self.previewLayer?.connection?.videoOrientation = .portrait
        }
        
        
        view.layer.insertSublayer(self.previewLayer!, at: 0)
        self.previewLayer?.frame = view.frame
    }
    
}
