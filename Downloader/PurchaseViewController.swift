//
//  PurchaseViewController.swift
//  VideoSpeed
//
//  Created by oren shalev on 23/07/2023.
//

import UIKit
import StoreKit
import FirebaseRemoteConfig

class PurchaseViewController: UIViewController {

    var product: SKProduct!
    var productIdentifier: ProductIdentifier!
    
    @IBOutlet weak var priceLabel: UILabel!
    @IBOutlet weak var backButton: UIButton!
    @IBOutlet weak var oneTimeChargeLabel: UILabel!
    var onDismiss: VoidClosure?
    
    @IBOutlet weak var unlimitedDownloadsContainer: UIView!
    @IBOutlet weak var unlimitedDownloadsContainerHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var adsLabel: UILabel!
    
    lazy var loadingView: LoadingView = {
        loadingView = LoadingView()
        return loadingView
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
               
        let businessModelType = RemoteConfig.remoteConfig().configValue(forKey: "business_model_type").numberValue.intValue
        let businessModel = BusinessModelType(rawValue: businessModelType)

        switch businessModel {
        case .limitedExports:
            productIdentifier = DownloaderProducts.proVersion
            unlimitedDownloadsContainer.isHidden = false
            unlimitedDownloadsContainerHeightConstraint.constant = 34
        case .onlyAds:
            productIdentifier = DownloaderProducts.ProVersionOnlyAds
            unlimitedDownloadsContainer.isHidden = true
            unlimitedDownloadsContainerHeightConstraint.constant = 0
            adsLabel.text = "Remove Ads"
        default:
            fatalError()
        }

        product = UserDataManager.main.products.first {$0.productIdentifier == productIdentifier}
        priceLabel.text = product.localizedPrice
        
        view.layoutIfNeeded()
        
        if UIDevice.current.userInterfaceIdiom == .pad {
            backButton.isHidden = true
        }
        
        NotificationCenter.default.addObserver(self, selector: #selector(purchaseCompleted), name: .IAPManagerPurchaseNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(restoreCompleted), name: .IAPManagerRestoreNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(purchaseFailed), name: .IAPManagerPurchaseFailedNotification, object: nil)
    }
    
    @IBAction func purchaseButtonTapped(_ sender: Any) {
        guard DownloaderProducts.store.canMakePayments() else {
            showCantMakePaymentAlert()
            return
        }
        
        showLoading()
        DownloaderProducts.store.buyProduct(product)
    }
    
    @IBAction func restoreButtonTapped(_ sender: Any) {
        showLoading()
        DownloaderProducts.store.restorePurchases()
    }
    
    @IBAction func backButtonTapped(_ sender: Any) {
        onDismiss?()
        dismiss(animated: true)
    }
    
    
    func showCantMakePaymentAlert() {
        let alertController = UIAlertController(title: "Error", message: "Payment Not Available", preferredStyle: .alert)
        let action = UIAlertAction(title: "OK", style: .default, handler: nil)
        alertController.addAction(action)
        
        present(alertController, animated: true, completion: nil)
    }
    
    // MARK: - NotificationCenter Selectors
    @objc func purchaseCompleted(notification: Notification) {
        onDismiss?()
        hideLoading()
        dismiss(animated: true)
    }

    
    
    @objc func restoreCompleted(notification: Notification) {
        onDismiss?()
        hideLoading()
        dismiss(animated: true)
    }
    
    @objc func purchaseFailed(notification: Notification) {
        hideLoading()
        if let text = notification.object as? String {
            let alertController = UIAlertController(title: text, message: nil, preferredStyle: .alert)
            let action = UIAlertAction(title: "OK", style: .default, handler: nil)
            alertController.addAction(action)
            present(alertController, animated: true, completion: nil)
        }
    }
 
//    func showLoading() {
//        disablePresentaionDismiss()
//        loadingView.activityIndicator.startAnimating()
//        view.addSubview(loadingView)
//        loadingView.translatesAutoresizingMaskIntoConstraints = false
//
//        let constraints = [
//            loadingView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
//            loadingView.leftAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leftAnchor),
//            loadingView.rightAnchor.constraint(equalTo: view.safeAreaLayoutGuide.rightAnchor),
//            loadingView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
//        ]
//        NSLayoutConstraint.activate(constraints)
//    }
//
//    func hideLoading() {
//        enablePresentationDismiss()
//        loadingView.activityIndicator.stopAnimating()
//        loadingView.removeFromSuperview()
//    }
//
//    func disablePresentaionDismiss() {
//        isModalInPresentation = true
//    }
//
//    func enablePresentationDismiss() {
//        isModalInPresentation = false
//    }
}
