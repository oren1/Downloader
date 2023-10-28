//
//  ViewController.swift
//  Downloader
//
//  Created by oren shalev on 16/10/2023.
//

import UIKit

struct YouTubeResponse: Decodable {
    
    enum CodingKeys: String, CodingKey {
        case result = "result"
    }
    
    enum ResultCodingKeys: String, CodingKey {
        case url = "url"
    }
    
    var url: String
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let result = try container.nestedContainer(keyedBy: ResultCodingKeys.self, forKey: .result)
        url = try result.decode(String.self, forKey: .url)
    }
}


class ViewController: UIViewController, URLSessionDownloadDelegate {
    @IBOutlet weak var progressView: UIProgressView!
    @IBOutlet weak var downloadingLabel: UILabel!
    @IBOutlet weak var textField: UITextField!
    @IBOutlet weak var downloadImageHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var loadingContainerView: UIView!
    private var urlSession: URLSession!
    @IBOutlet weak var buttonBottomContraint: NSLayoutConstraint!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        textField.clearButtonMode = .always
        downloadImageHeightConstraint.constant = view.frame.height * 0.3
        
        let notificationCenter = NotificationCenter.default
        notificationCenter.addObserver(self, selector: #selector(adjustForKeyboard), name: UIResponder.keyboardWillHideNotification, object: nil)
        notificationCenter.addObserver(self, selector: #selector(adjustForKeyboard), name: UIResponder.keyboardWillChangeFrameNotification, object: nil)
        
        textField.placeholder = "Copy paste a youtube url"
        
        urlSession = URLSession(configuration: .default,
                                                 delegate: self,
                                                 delegateQueue: nil)
    }

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

    // MARK: - URLSessionDelegate
    func urlSession(_ session: URLSession, downloadTask: URLSessionDownloadTask, didFinishDownloadingTo location: URL) {
        print("location = \(location)")
        let videoName = UUID().uuidString
        let videoURL = URL(fileURLWithPath: NSTemporaryDirectory())
            .appendingPathComponent(videoName)
            .appendingPathExtension("mp4")
       
        do {
            if let videoData = try? Data(contentsOf: location) {
               try videoData.write(to: videoURL)
                guard UIVideoAtPathIsCompatibleWithSavedPhotosAlbum(videoURL.relativePath) else { return }
                UISaveVideoAtPathToSavedPhotosAlbum(videoURL.relativePath, self, #selector(self.video(_:didFinishSavingWithError:contextInfo:)),nil)
            }
        } catch {
            print("error writing: \(error)")
        }
        
        DispatchQueue.main.async { [weak self] in
            self?.loadingContainerView.isHidden = true
        }

    }
    func urlSession(_ session: URLSession, downloadTask: URLSessionDownloadTask, didWriteData bytesWritten: Int64, totalBytesWritten: Int64, totalBytesExpectedToWrite: Int64) {
        DispatchQueue.main.async { [weak self] in
            let progress = Float(totalBytesWritten) / Float(totalBytesExpectedToWrite)
            self?.progressView.progress = progress
            self?.downloadingLabel.text = "Downloaging \(Int(progress * 100)) %"
            print("total bytes written: \(totalBytesWritten)")
        }
    }
    
    func urlSession(_ session: URLSession, task: URLSessionTask, didCompleteWithError error: Error?) {
        DispatchQueue.main.async { [weak self] in
            if let error = error {
                self?.showError(message: error.localizedDescription)
            }
        }
    }

    func urlSession(_ session: URLSession, didBecomeInvalidWithError error: Error?) {
        DispatchQueue.main.async { [weak self] in
            if let error = error {
                self?.showError(message: error.localizedDescription)
            }
        }
    }

    
   

   
    // MARK: - Actions
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
            do {
                loadingContainerView.isHidden = false
                try await downloadVideo(urlString: url)

            }
            catch {
                showError(message: error.localizedDescription)
            }
        }
    }
    
    
    // MARK: - UI
    @objc func adjustForKeyboard(notification: Notification) {
        guard let keyboardValue = notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue else { return }

        let keyboardScreenEndFrame = keyboardValue.cgRectValue
        let keyboardViewEndFrame = view.convert(keyboardScreenEndFrame, from: view.window)

        if notification.name == UIResponder.keyboardWillHideNotification {
            self.buttonBottomContraint.constant = 24
        } else {
            buttonBottomContraint.constant = keyboardViewEndFrame.height - view.safeAreaInsets.bottom + 24
        }

    }
    func downloadVideo(urlString: String) async throws {
        let endPointUrl = URL(string: "https://videoinfo-ajf6q47xdq-uc.a.run.app/videoinfo")!
        var request = URLRequest(url: endPointUrl)
        request.httpMethod = "POST"
        request.allHTTPHeaderFields = [
            "Content-Type": "application/json"
        ]
        let encodedYoutubeDirectUrl = urlString.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)!

        let body = ["url": encodedYoutubeDirectUrl]
        let bodyData = try? JSONSerialization.data(withJSONObject: body, options: [])
        request.httpBody = bodyData

        
        let (data, _) = try await urlSession.data(for: request)
        
            let decoder = JSONDecoder()
            let result = try decoder.decode(YouTubeResponse.self, from: data)
            print("result = \(result)")
            let theUrl = ""
            guard let videoURL = URL(string: result.url) else { return }
            let task = urlSession.downloadTask(with: videoURL)
            task.resume()
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
    
}

