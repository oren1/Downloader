//
//  ViewController.swift
//  Downloader
//
//  Created by oren shalev on 16/10/2023.
//

import UIKit
import FirebaseRemoteConfig

enum BusinessModelType: Int {
  case limitedExports = 1, onlyAds
}

struct YouTubeResponse: Decodable {
    
    enum CodingKeys: String, CodingKey {
        case url = "url"
        case error = "error"
    }
    
    var url: String?
    var error: String?
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        url = try? container.decode(String.self, forKey: .url)
        error = try? container.decode(String.self, forKey: .error)
    }
}


class ViewController: UIViewController {
    @IBOutlet weak var progressView: UIProgressView!
    @IBOutlet weak var downloadingLabel: UILabel!
    @IBOutlet weak var textField: UITextField!
    @IBOutlet weak var downloadImageHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var loadingContainerView: UIView!
    private var urlSession: URLSession!
    @IBOutlet weak var buttonBottomContraint: NSLayoutConstraint!
    
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = "Downloader"
        let proButton = createProButton()
        let proBarButtonItem = UIBarButtonItem(customView: proButton)
        navigationItem.rightBarButtonItems = [proBarButtonItem]
        self.navigationItem.setHidesBackButton(true, animated: true)

        textField.clearButtonMode = .always
        downloadImageHeightConstraint.constant = view.frame.height * 0.3
        
        let notificationCenter = NotificationCenter.default
        notificationCenter.addObserver(self, selector: #selector(adjustForKeyboard), name: UIResponder.keyboardWillHideNotification, object: nil)
        notificationCenter.addObserver(self, selector: #selector(adjustForKeyboard), name: UIResponder.keyboardWillChangeFrameNotification, object: nil)
        
        textField.placeholder = "Paste a youtube url"
        
        urlSession = URLSession(configuration: .default,
                                                 delegate: self,
                                                 delegateQueue: nil)

       
    }

    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        if let _ = DownloaderProducts.store.userPurchasedProVersion() {
            navigationItem.rightBarButtonItems?.removeAll()
        }
    }
    
    
    // MARK: - Actions
    @objc func video(
      _ videoPath: String,
      didFinishSavingWithError error: Error?,
      contextInfo info: AnyObject
    ) {
        if error == nil {
            print("success")
        }
        else {
            showError(message: "Video failed to save")
        }

    }
    
    @IBAction func saveButtonTapped(_ sender: Any) {
        view.endEditing(true)
        guard let url = textField.text else {
            let alert = UIAlertController(
              title: "Error",
              message: "Enter a valid url",
              preferredStyle: .alert)
            alert.addAction(UIAlertAction(
              title: "OK",
              style: UIAlertAction.Style.cancel,
              handler: nil))
            present(alert, animated: true, completion: nil)
            // present an alert indicating an error
            return
        }
        

        // start downloading
        Task {

            let businessModelType = RemoteConfig.remoteConfig().configValue(forKey: "business_model_type").numberValue.intValue
            let businessModel = BusinessModelType(rawValue: businessModelType)

            switch businessModel {
                case .limitedExports:
                    guard let _ = DownloaderProducts.store.userPurchasedProVersion() else {
                        print("amountOfDownloads", UserDataManager.amountOfDownloads)
                        if UserDataManager.amountOfDownloads < 2 {
                           return await downloadVideo(urlString: url)
                        }

                        return showPurchaseViewController()
                    }

                    await downloadVideo(urlString: url)
            case .onlyAds:
                InterstitialAd.manager.showAd(controller: self) { [weak self] in
                    Task {
                        await self?.downloadVideo(urlString: url)
                    }
                }
            default:
                fatalError("unknown 'business_model_type' type")
            }

        }
    }
    
    // MARK: - Custom Logic
    @objc func showPurchaseViewController() {
        let purchaseViewController = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "PurchaseViewController") as! PurchaseViewController
        
        if UIDevice.current.userInterfaceIdiom == .phone {
            purchaseViewController.modalPresentationStyle = .fullScreen
        }
        else if UIDevice.current.userInterfaceIdiom == .pad {
            purchaseViewController.modalPresentationStyle = .formSheet
        }
        
        self.present(purchaseViewController, animated: true)
    }
    
    func showSuccessMessageViewController() {
        let successMessageViewController = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "SuccessMessageViewController") as! SuccessMessageViewController
        if UIDevice.current.userInterfaceIdiom == .phone {
            successMessageViewController.modalPresentationStyle = .fullScreen
        }
        self.present(successMessageViewController, animated: true)
    }
    
    // MARK: - UI
    @objc func adjustForKeyboard(notification: Notification) {
        guard let keyboardValue = notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue else { return }

        let keyboardScreenEndFrame = keyboardValue.cgRectValue
        let keyboardViewEndFrame = view.convert(keyboardScreenEndFrame, from: view.window)
        guard let animationDuration = notification.userInfo?[UIResponder.keyboardAnimationDurationUserInfoKey] as? Double else {return}

        if notification.name == UIResponder.keyboardWillHideNotification {
            UIView.animate(withDuration: animationDuration) { [weak self] in
                self?.buttonBottomContraint.constant = 24
                self?.view.updateConstraintsIfNeeded()
                self?.view.layoutIfNeeded()
            }
            
        } else {
            UIView.animate(withDuration: animationDuration) { [weak self] in
                guard let self = self else {return}
                self.buttonBottomContraint.constant = keyboardViewEndFrame.height - view.safeAreaInsets.bottom + 24
                self.view.updateConstraintsIfNeeded()
                self.view.layoutIfNeeded()
            }
        }

    }
    
    func createProButton() -> UIButton {
        let proButton = UIButton(type: .roundedRect)
        proButton.tintColor = .white
        proButton.backgroundColor = .systemBlue
        proButton.setTitle("  Get Pro  ", for: .normal)
        proButton.titleLabel?.font = UIFont.boldSystemFont(ofSize: 16)
        proButton.addTarget(self, action: #selector(showPurchaseViewController), for: .touchUpInside)
        proButton.layer.cornerRadius = 10
        proButton.layer.borderWidth = 0
        proButton.layer.borderColor = UIColor.lightGray.cgColor
        return proButton
    }
    
    func downloadVideo(urlString: String) async {
        do {
            showLoadingContainer()
            let videoURlString = try await NetworkManager.shared.getVideoUrl(urlString: urlString)
            guard let videoURL = URL(string: videoURlString) else { return }
            let task = urlSession.downloadTask(with: videoURL)
            task.resume()
        }
        catch VideoInfoError.gettingDownloadableUrl(let description) {
            showError(message: description)
            self.hideLoadingContainer()
        }
        catch {
            print(error)
            showError(message: error.localizedDescription)
            self.hideLoadingContainer()
        }
    }
    
    func showLoadingContainer() {
        loadingContainerView.isHidden = false
        downloadingLabel.text = "Starting Download"
        activityIndicator.startAnimating()
    }
    
    func hideLoadingContainer() {
        loadingContainerView.isHidden = true
        downloadingLabel.text = ""
        activityIndicator.stopAnimating()
        progressView.progress = 0
    }
    
    func showError(message: String) {
        let alert = UIAlertController(
          title: "Error",
          message: message,
          preferredStyle: .alert)
        alert.addAction(UIAlertAction(
          title: "OK",
          style: UIAlertAction.Style.cancel,
          handler: nil))
        present(alert, animated: true, completion: nil)
    }
    
    
    func showAlert(title: String, message: String) {
        let alert = UIAlertController(
          title: title,
          message: message,
          preferredStyle: .alert)
        alert.addAction(UIAlertAction(
          title: "OK",
          style: UIAlertAction.Style.cancel,
          handler: nil))
        present(alert, animated: true, completion: nil)
    }
}

