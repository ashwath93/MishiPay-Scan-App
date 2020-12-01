//
//  BarCodeVCViewModel.swift
//  MishiPay-Scan-App
//
//  Created by Ashwath R on 29/11/20.
//

import UIKit
import AVFoundation
import CoreData

protocol BarCodeVCViewModelDelegate: AnyObject {
    func barCodeVCViewModel(_ viewModel: BarCodeVCViewModel, addVideoPreviewLayer layer: CALayer)
    func barCodeVCViewModel(_ viewModel: BarCodeVCViewModel, showAlertWithTitle title: String,
                            message: String)
    func barCodeVCViewModel(_ viewModel: BarCodeVCViewModel, didSucceedWithResult text: String)
}

class BarCodeVCViewModel: NSObject {
    
    let captureSession = AVCaptureSession()
    weak var delegate: BarCodeVCViewModelDelegate?
    lazy var metaDataOutput = AVCaptureMetadataOutput()
    
    var cartItemsCount: Int {
        let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
        let fetchRequest: NSFetchRequest<Cart> = Cart.fetchRequest()
        do {
            let result = try? context.fetch(fetchRequest)
            if let items = result?.first?.items {
                guard let cartItems = try? NSKeyedUnarchiver.unarchiveTopLevelObjectWithData(items) as? [Item]
                else { return 0 }
                return cartItems.endIndex 
            } else {
                return 0
            }
        }
    }
    
    func performInitialSetup() {
        addMetaDataOutput()
        addCameraPreviewLayer()
    }
    
    func startCamera() {
        guard !captureSession.isRunning else { return }
        captureSession.startRunning()
    }
    
    func addItemToCart(name: String) {
        
        let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
        let item = Item(context: context)
        item.name = name
        item.price = 10
        item.image = UIImage(named: "men")?.jpegData(compressionQuality: 1.0)
        
        let fetchRequest: NSFetchRequest<Cart> = Cart.fetchRequest()
        do {
            
            let result = try context.fetch(fetchRequest)
            if let items = result.first?.items {
                guard var cartItems = try NSKeyedUnarchiver.unarchiveTopLevelObjectWithData(items) as? [Item] else { return }
                if cartItems.first(where: { $0.name == item.name }) != nil {
                    delegate?.barCodeVCViewModel(self, showAlertWithTitle: "Item already added",
                                                 message: "Item already added in cart")
                    return
                } else {
                    cartItems.append(item)
                    Utilities.saveCartItems(cartItems)
                }
            } else {
                let cart = Cart(context: context)
                cart.items = try NSKeyedArchiver.archivedData(withRootObject: [item], requiringSecureCoding: false)
                try context.save()
            }
        } catch {
            print("Failed")
        }
    }
    
    //MARK:- Private Method(s)
    private func addCameraPreviewLayer() {
        let cameraPreviewLayer = AVCaptureVideoPreviewLayer(session: captureSession)
        cameraPreviewLayer.videoGravity = .resizeAspectFill
        cameraPreviewLayer.connection?.videoOrientation = .portrait
        delegate?.barCodeVCViewModel(self, addVideoPreviewLayer: cameraPreviewLayer)
        captureSession.startRunning()
    }
    
    private func addMetaDataOutput() {
        // Make sure the actually is a back camera on this particular iPhone.
        guard let backCamera = AVCaptureDevice.default(.builtInWideAngleCamera, for: .video, position: .back)
        else {
            delegate?.barCodeVCViewModel(self, showAlertWithTitle: "Camera error",
                                         message: "There seems to be no camera on your device.")
            return
        }

        // Set up the input and output stream.
        do {
            let captureDeviceInput = try AVCaptureDeviceInput(device: backCamera)
            captureSession.addInput(captureDeviceInput)
        } catch {
            delegate?.barCodeVCViewModel(self, showAlertWithTitle: "Camera error",
                                         message: "Your camera can't be used as an input device.")
            return
        }
        captureSession.addOutput(metaDataOutput)
        metaDataOutput.setMetadataObjectsDelegate(self, queue: .main)
        metaDataOutput.metadataObjectTypes = metaDataOutput.availableMetadataObjectTypes
    }
}

extension BarCodeVCViewModel: AVCaptureMetadataOutputObjectsDelegate {
    func metadataOutput(_ output: AVCaptureMetadataOutput, didOutput metadataObjects: [AVMetadataObject],
                        from connection: AVCaptureConnection) {
        guard let metadataObject = metadataObjects.first else {
            return
        }
        captureSession.stopRunning()
        guard let readableObject = metadataObject as? AVMetadataMachineReadableCodeObject else { return }
        guard let stringValue = readableObject.stringValue else { return }
        AudioServicesPlaySystemSound(SystemSoundID(kSystemSoundID_Vibrate))          
        delegate?.barCodeVCViewModel(self, didSucceedWithResult: stringValue)
    }
}
