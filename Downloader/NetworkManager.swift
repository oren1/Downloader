//
//  NetworkManager.swift
//  Downloader
//
//  Created by oren shalev on 09/11/2023.
//

import Foundation

enum VideoInfoError: Error {
    case gettingDownloadableUrl(description: String)
}


class NetworkManager {
    
    let videoInfoUrl = "https://get-download-url-whg6ncgg5q-uc.a.run.app"
    static let shared = NetworkManager()
    
    func getVideoUrl(urlString: String) async throws -> String {
        let endPointUrl = URL(string: videoInfoUrl)!
        var request = URLRequest(url: endPointUrl)
        request.httpMethod = "POST"
        request.allHTTPHeaderFields = [
            "Content-Type": "application/json"
        ]

        let body = ["url": urlString]
        let bodyData = try? JSONSerialization.data(withJSONObject: body, options: [])
        request.httpBody = bodyData

        
        let (data, _) = try await URLSession.shared.data(for: request)
        let decoder = JSONDecoder()
        let result = try decoder.decode(YouTubeResponse.self, from: data)

        if let error = result.error {
            throw VideoInfoError.gettingDownloadableUrl(description: error)
        }
        else if let url = result.url {
            return url
        }
        
        throw VideoInfoError.gettingDownloadableUrl(description: "Unknown error occured")
    }
}
