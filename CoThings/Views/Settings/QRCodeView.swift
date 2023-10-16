//
//  QRCodeView.swift
//  CoThings
//
//  Created by Quentin on 22/05/2020.
//  Copyright © 2020 CoThings. All rights reserved.
//

import Foundation
import SwiftUI
import AVFoundation
import UIKit

struct QRCodeView: UIViewControllerRepresentable {

    private var onFoundCode: (String) -> Void

    private var onCameraError: () -> Void

    init(onFoundCode: @escaping (String) -> Void, 
         onCameraError: @escaping () -> Void) {
        self.onFoundCode = onFoundCode
        self.onCameraError = onCameraError
    }

    func makeUIViewController(context: Context) -> QRCodeViewController {
        let controller = QRCodeViewController()
        controller.foundQRCode = onFoundCode
        controller.failedToOpenCamera = onCameraError
        return controller
    }

    func updateUIViewController(_ uiViewController: QRCodeViewController, context: Context) {}

}

class QRCodeViewController: UIViewController {
    private var captureSession: AVCaptureSession!
    private var previewLayer: AVCaptureVideoPreviewLayer!
    private var sessionQueue = DispatchQueue(label: "AvCaptureSession")
    private var qrCodeNotValidLabel = UILabel()

    var foundQRCode: (String) -> Void = {_ in}
    var failedToOpenCamera: () -> Void = {}

    override func viewDidLoad() {
        super.viewDidLoad()

        view.backgroundColor = UIColor.black
        captureSession = AVCaptureSession()

        guard let videoCaptureDevice = AVCaptureDevice
            .default(.builtInWideAngleCamera,
                     for: .video, position: .back) else { return }

        let videoInput: AVCaptureDeviceInput

        do {
            videoInput = try AVCaptureDeviceInput(device: videoCaptureDevice)
        } catch {
            failedToOpenCamera()

            return
        }

        if (captureSession.canAddInput(videoInput)) {
            captureSession.addInput(videoInput)
        } else {
            failedToOpenCamera()

            return
        }

        let metadataOutput = AVCaptureMetadataOutput()

        if (captureSession.canAddOutput(metadataOutput)) {
            captureSession.addOutput(metadataOutput)

            metadataOutput.setMetadataObjectsDelegate(self, queue: DispatchQueue.main)
            metadataOutput.metadataObjectTypes = [.qr]
        } else {
            failedToOpenCamera()

            return
        }

        previewLayer = AVCaptureVideoPreviewLayer(session: captureSession)
        previewLayer.frame = view.layer.bounds
        previewLayer.videoGravity = .resizeAspectFill
        view.layer.addSublayer(previewLayer)

        let titleLabel = UILabel()
        titleLabel.text = "Scan QR code"
        titleLabel.font = .systemFont(ofSize: 20, weight: .heavy)
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(titleLabel)
        titleLabel.topAnchor.constraint(equalTo: view.topAnchor, 
                                        constant: 20).isActive = true
        titleLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true

        let dismissButton = UIButton()
        let crossImage = UIImage(systemName: "multiply", 
                                 withConfiguration: UIImage.SymbolConfiguration(pointSize: 35,
                                                                                weight: .regular,
                                                                                scale: .large))
        dismissButton.setImage(crossImage, for: .normal)
        dismissButton.tintColor = .white
        dismissButton.addTarget(self, action: #selector(onTapDismissButton), for: .touchUpInside)
        dismissButton.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(dismissButton)
        dismissButton.topAnchor.constraint(equalTo: view.topAnchor, constant: 15).isActive = true
        dismissButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 15).isActive = true
        dismissButton.heightAnchor.constraint(equalToConstant: 35).isActive = true
        dismissButton.widthAnchor.constraint(equalTo: dismissButton.heightAnchor).isActive = true


        qrCodeNotValidLabel.text = ""
        qrCodeNotValidLabel.font = .systemFont(ofSize: 15, weight: .bold)
        qrCodeNotValidLabel.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(qrCodeNotValidLabel)
        qrCodeNotValidLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        qrCodeNotValidLabel.centerYAnchor.constraint(equalTo: view.centerYAnchor).isActive = true


        sessionQueue.async {
            self.captureSession.startRunning()
        }
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        if (!self.captureSession.isRunning) {
            sessionQueue.async {
                self.captureSession.startRunning()
            }
        }
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)

        if (self.captureSession.isRunning) {
            sessionQueue.async {
                self.captureSession.stopRunning()
            }
        }
    }

    @objc private func onTapDismissButton() {
        dismiss(animated: true)
    }

    override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        return .portrait
    }
}

extension QRCodeViewController: AVCaptureMetadataOutputObjectsDelegate {
    func metadataOutput(_ output: AVCaptureMetadataOutput, didOutput metadataObjects: [AVMetadataObject], from connection: AVCaptureConnection) {

        if let metadataObject = metadataObjects.first {
            guard let readableObject = metadataObject as? AVMetadataMachineReadableCodeObject else { return }
            guard let stringValue = readableObject.stringValue else { return }
            guard stringValue.hasPrefix("https://") else {
                qrCodeNotValidLabel.text = "Invalid QR code"
                DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
                    self.qrCodeNotValidLabel.text = ""
                }
                return
            }
            captureSession.stopRunning()
            AudioServicesPlaySystemSound(SystemSoundID(kSystemSoundID_Vibrate))
            dismiss(animated: true, completion: {
                self.foundQRCode(stringValue)
            })
        }
    }
}
