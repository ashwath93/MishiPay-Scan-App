//
//  BarCodeViewController.swift
//  MishiPay-Scan-App
//
//  Created by Ashwath R on 29/11/20.
//

import UIKit

class BarCodeViewController: UIViewController {    
    let viewModel = BarCodeVCViewModel()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        viewModel.delegate = self
        viewModel.performInitialSetup()        
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        viewModel.startCamera()
        navigationController?.isNavigationBarHidden = true
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillAppear(animated)        
        navigationController?.isNavigationBarHidden = false
    }

    @IBAction func dismissPage() {
        if let navigationController = navigationController {
            navigationController.popViewController(animated: true)
        } else {
            dismiss(animated: true)
        }
    }
}

extension BarCodeViewController: BarCodeVCViewModelDelegate {
    
    func barCodeVCViewModel(_ viewModel: BarCodeVCViewModel, addVideoPreviewLayer layer: CALayer) {
        layer.frame = view.frame
        view.layer.insertSublayer(layer, at: 0)
    }
    
    func barCodeVCViewModel(_ viewModel: BarCodeVCViewModel, didSucceedWithResult text: String) {
        let addToCartAction = UIAlertAction(title: "Add to Cart", style: .default) { _ in
            self.viewModel.addItemToCart(name: text)
            let barCodeViewController = UIStoryboard(name: "Main", bundle: nil)
                .instantiateViewController(identifier: "CartViewController")
            self.navigationController?.pushViewController(barCodeViewController, animated: true)
        }
        let scanAgainAction = UIAlertAction(title: "Scan Again", style: .default) { _ in
            self.viewModel.startCamera()
        }
        showAlert(withTitle: "Matched", message: "\(text) found", actions: [addToCartAction, scanAgainAction])
    }
    
    func barCodeVCViewModel(_ viewModel: BarCodeVCViewModel, showAlertWithTitle title: String, message: String) {
        let alertAction = UIAlertAction(title: "OK", style: .default) { _ in
            self.viewModel.startCamera()
        }
        showAlert(withTitle: title, message: message, actions: [alertAction])
    }
}
