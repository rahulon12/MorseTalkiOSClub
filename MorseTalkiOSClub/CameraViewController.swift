//
//  CameraViewController.swift
//  MorseTalk
//
//  Created by Rahul Narayanan on 9/18/22.
//

import UIKit
import SwiftUI
import Vision
import AVKit

// MARK: - File Information.
/**
 Most of this file is UIKit, NOT SwiftUI. All it does is bring up the camera view so the user can see themselves, and we can implement any processing we want to do on each frame. Read the MARK's and Comments to understand what the code does.
 */

final class CameraViewController: UIViewController, AVCaptureVideoDataOutputSampleBufferDelegate {
    
    // MARK: Instance Variables
    private(set) var cameraController = CameraController()
    private var previewView: UIView!
    private var bufferOrientation: CGImagePropertyOrientation = .leftMirrored
    private var frameCounter = 0
        
    override func viewDidLoad() {
        super.viewDidLoad()
        // Here we usually implement anything we want to do when the view LOADS for the first time.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        // Here we implement anything we want to do EACH time the view is GOING TO appear.
        startCamera()
    }
    
    // Not too important. It ensures the view oriented correctly whenever iOS decides to redraw the view.
    override func viewDidLayoutSubviews() {
        if let orientation = view.window?.windowScene?.interfaceOrientation {
            previewView.frame = view.frame
            cameraController.previewLayer?.frame = previewView.frame

            // print("Orientation: ", orientation.rawValue)

            switch orientation {
            case .portrait:
                self.cameraController.previewLayer?.connection?.videoOrientation = .portrait
                self.bufferOrientation = .leftMirrored
            case .landscapeLeft:
                self.cameraController.previewLayer?.connection?.videoOrientation = .landscapeLeft
                self.bufferOrientation = .upMirrored
            case .landscapeRight:
                self.cameraController.previewLayer?.connection?.videoOrientation = .landscapeRight
                self.bufferOrientation = .downMirrored
            default:
                self.cameraController.previewLayer?.connection?.videoOrientation = .portrait
            }
        } else {
            self.cameraController.previewLayer?.connection?.videoOrientation = .portrait
        }
    }
    
    // Prepares and starts the camera feed.
    func startCamera() {
        previewView = UIView()
        previewView.contentMode = .scaleAspectFit
        previewView.translatesAutoresizingMaskIntoConstraints = false
        
        if !view.subviews.contains(previewView) {
            view.addSubview(previewView)
            let constraints = [
                previewView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
                previewView.centerYAnchor.constraint(equalTo: view.centerYAnchor),
                previewView.widthAnchor.constraint(equalTo: view.widthAnchor),
                previewView.heightAnchor.constraint(equalTo: view.heightAnchor),
                previewView.topAnchor.constraint(equalTo: view.topAnchor, constant: 8),
                previewView.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: 8),
                previewView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 8),
                previewView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: 8)
            ]
            NSLayoutConstraint.activate(constraints)
        }
        
        cameraController.prepare {(error) in
            if let error = error {
                print(error)
            }
            let dataOutput = AVCaptureVideoDataOutput()
            dataOutput.setSampleBufferDelegate(self, queue: DispatchQueue(label: "videoQueue"))
            if let captureSession = self.cameraController.captureSession, captureSession.canAddOutput(dataOutput) {
                self.cameraController.captureSession?.addOutput(dataOutput)
            }
            
            try? self.cameraController.displayPreview(on: self.previewView)
        }
    }
    
    // Stops the camera feed.
    func stopCamera() {
        cameraController.captureSession?.stopRunning()
    }
    
    // Here we implement anything we want to do AFTER the view has appeared.
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        // ensures the screen doesn't dim out when the camera is on.
        UIApplication.shared.isIdleTimerDisabled = true
        
        if AVCaptureDevice.authorizationStatus(for: .video) == .denied {
            let alert = UIAlertController(title: "Grant Access", message: "Enable MorseTalk to access your device's camera in the Settings app.", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "Dismiss", style: .default))
            self.present(alert, animated: true)
        }
    }
    
    // Here we implement anything we want to do AFTER the view has disappeared.
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        stopCamera()
        UIApplication.shared.isIdleTimerDisabled = false
    }
    
    // MARK: - Camera Processing
    /**
     This is the most important method. This function runs everytime the camera is fed a new frame. We do all our processing here.
     */
    func captureOutput(_ output: AVCaptureOutput, didOutput sampleBuffer: CMSampleBuffer, from connection: AVCaptureConnection) {
        
    }
}

// MARK: - UIViewControllerRepresentable
/**
 This struct is necessary for us to use our UIKit view in SwiftUI. We can put it in any SwiftUI view by just adding "CameraFeedView()".
 */
struct CameraFeedView: UIViewControllerRepresentable {
    
    public typealias UIViewControllerType = CameraViewController
    
    func makeUIViewController(context: Context) -> CameraViewController {
        let cameraVC = CameraViewController()
        return cameraVC
    }
    
    func updateUIViewController(_ uiViewController: CameraViewController, context: Context) {
        
    }
}
