//
//  QRScannerViewController.swift
//  iPoll
//
//  Created by Evans Owamoyo on 15.03.2022.
//

import UIKit
import AVFoundation

class QRScannerViewController: UIViewController, AVCaptureMetadataOutputObjectsDelegate {

    // MARK: private variables
    private var captureSession: AVCaptureSession?
    private var previewLayer: AVCaptureVideoPreviewLayer!
    private var onError: ((String) -> Void)?

    init(onError: @escaping (String) -> Void) {
        super.init(nibName: nil, bundle: nil)
        self.onError = onError
    }

    required init?(coder: NSCoder) {
        fatalError("QRScannerViewController does not have a decoder")
    }
    override func viewDidLoad() {
        super.viewDidLoad()

        view.backgroundColor = .black

        captureSession = AVCaptureSession()

        // get the video input from the capture device
        guard let videoCaptureDevice = AVCaptureDevice.default(for: .video) else { showError(); return }
        guard let videoInput = try? AVCaptureDeviceInput(device: videoCaptureDevice) else { showError(); return }

        // add the video input to the session
        if captureSession!.canAddInput(videoInput) {
            captureSession!.addInput(videoInput)
        } else {
            showError()
            return
        }

        // add the output layer that looks for QR input to the capture session
        let metaDataOutput = AVCaptureMetadataOutput()
        if captureSession!.canAddOutput(metaDataOutput) {
            captureSession!.addOutput(metaDataOutput)
            metaDataOutput.setMetadataObjectsDelegate(self, queue: .main)
            metaDataOutput.metadataObjectTypes = [.qr]
        } else {
            showError()
            return
        }

        // add a preview layer
        previewLayer = AVCaptureVideoPreviewLayer(session: captureSession!)
        previewLayer.frame = view.layer.bounds
        previewLayer.videoGravity = .resizeAspectFill
        view.layer.addSublayer(previewLayer)

        captureSession!.startRunning()

    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        if captureSession?.isRunning == false {
            captureSession?.startRunning()
        }
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)

        if captureSession?.isRunning == true {
            captureSession?.stopRunning()
        }
    }

    func metadataOutput(_ output: AVCaptureMetadataOutput,
                        didOutput metadataObjects: [AVMetadataObject],
                        from connection: AVCaptureConnection) {
        captureSession?.stopRunning()

        if let metadata = metadataObjects.first {
            // read the object
            guard let readableObject = metadata as? AVMetadataMachineReadableCodeObject else { return }
            guard let stringValue = readableObject.stringValue else { return } // get stringValue

            AudioServicesPlaySystemSound(SystemSoundID(kSystemSoundID_Vibrate)) // vibrate
            self.navigationController?.popViewController(animated: true)
            goToPoll(code: stringValue)
        }

    }

    private func showError() {
        let alert = UIAlertController(title: "Error Initialising Camera",
                                      message: "Camera could not start to read QR code",
                                      preferredStyle: .alert)
        let action = UIAlertAction(title: "Close", style: .default) { _ in
            self.dismiss(animated: true) {
                self.navigationController?.popViewController(animated: true)
            }
        }
        alert.addAction(action)
        present(alert, animated: true)
    }

    private func goToPoll(code: String) {
        if let url = URL(string: code) {
            Router.to(url) { [self] reason in
                onError?(reason)
            }

        }
    }
}
