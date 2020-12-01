//
//  ViewController.swift
//  MishiPay-Scan-App
//
//  Created by Ashwath R on 29/11/20.
//

import UIKit
import AVFoundation

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
    }

    //MARK:- Private Method(s)
    @IBAction private func checkPermissions() {
        
        let status = AVCaptureDevice.authorizationStatus(for: .video)
        switch status {
        case .authorized:
            cameraAccessProvidedAction()
        case .denied, .restricted:
            cameraAccessDeniedAction()
        case .notDetermined:
            // Prompt the user for access.
            AVCaptureDevice.requestAccess(for: .video) { granted in
                DispatchQueue.main.async {
                    if granted {
                        self.cameraAccessProvidedAction()
                    } else {
                        self.cameraAccessDeniedAction()
                    }
                }
            }
        default:
            break
        }
    }
    
    private func cameraAccessProvidedAction() {
        let barCodeViewController = UIStoryboard(name: "Main", bundle: nil)
            .instantiateViewController(identifier: "BarCodeViewController")
        navigationController?.pushViewController(barCodeViewController, animated: true)
    }
    
    private func cameraAccessDeniedAction() {
        let openSettingsAction: (UIAlertAction) -> () = { _ in
            UIApplication.shared.open(URL(string: UIApplication.openSettingsURLString)!)
        }
        self.showAlert(withTitle: "Permission Required",
                       message: "Please provide permission to Camera!",
                       actions: [UIAlertAction(title: "OK", style: .default, handler: openSettingsAction)])
    }
}

extension UIViewController {
    func showAlert(withTitle title: String, message: String, actions: [UIAlertAction] = []) {
        let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
        for action in actions {
            alertController.addAction(action)
        }
        present(alertController, animated: true)
    }
}
