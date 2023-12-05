//
//  ViewController+URLSessionDownloadDelegate.swift
//  Downloader
//
//  Created by oren shalev on 09/11/2023.
//

import Foundation
import AVKit

extension ViewController: URLSessionDownloadDelegate {
   
    func urlSession(_ session: URLSession, didCreateTask task: URLSessionTask) {
        print("started task")
        activityIndicator.stopAnimating()
        downloadingLabel.text = "Downloading..."
    }
    
    func urlSession(_ session: URLSession, downloadTask: URLSessionDownloadTask, didFinishDownloadingTo location: URL) {
        print("location = \(location)")
        let videoName = UUID().uuidString
        let videoURL = URL(fileURLWithPath: NSTemporaryDirectory())
            .appendingPathComponent(videoName)
            .appendingPathExtension("mp4")
        print("videoURL = \(videoURL)")

        do {
            if let videoData = try? Data(contentsOf: location) {
               try videoData.write(to: videoURL)
                guard UIVideoAtPathIsCompatibleWithSavedPhotosAlbum(videoURL.relativePath) else { return }
                UISaveVideoAtPathToSavedPhotosAlbum(videoURL.relativePath, self, #selector(self.video(_:didFinishSavingWithError:contextInfo:)),nil)
                DispatchQueue.main.async { [weak self] in
                    UserDataManager.amountOfDownloads += 1
                    self?.showSuccessMessageViewController()
                }
            }
        } catch {
            print("error writing: \(error)")
        }
        
        DispatchQueue.main.async { [weak self] in
            self?.hideLoadingContainer()
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
                self?.hideLoadingContainer()
            }
        }
    }

    func urlSession(_ session: URLSession, didBecomeInvalidWithError error: Error?) {
        DispatchQueue.main.async { [weak self] in
            if let error = error {
                self?.showError(message: error.localizedDescription)
                self?.hideLoadingContainer()
            }
        }
    }
}
