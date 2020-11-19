//
//  APIRequest.swift
//  CoThings
//
//  Created by Nesim Tunç on 2020/06/01.
//  Copyright © 2020 CoThings. All rights reserved.
//

import Foundation

protocol APIRequestDelegate: class {
	func onError(_ message: String)
}

public struct APIRequest<Model: Codable> {
	public typealias SuccesCompletionHandler = (_ response: Model) -> Void


	static private func getHostname() -> String? {
		return UserDefaults.standard.string(forKey: ServerHostNameKey)
	}

	static func get(_ delegate: APIRequestDelegate?,
					relativeUrl: String, jsonKey: String,
					success successCallback: @escaping SuccesCompletionHandler
	) {

		guard let hostname = getHostname() else {
			return
		}

		let url = "https://" + hostname + "/" + relativeUrl

		guard let urlComponent = URLComponents(string: url), let usableUrl = urlComponent.url else {
			delegate?.onError("Invalid URL: " + url)
			return
		}

		var request = URLRequest(url: usableUrl)
		request.httpMethod = "GET"

		var dataTask: URLSessionDataTask?
		let defaultSession = URLSession(configuration: .default)

		dataTask =
			defaultSession.dataTask(with: request) { data, response, error in
				defer {
					dataTask = nil
				}

				if (error != nil) {
					delegate?.onError("Got error in APIRequest: " + error!.localizedDescription)
				} else if
					let data = data,
					let response = response as? HTTPURLResponse,
					response.statusCode == 200 {
					guard let model = self.parseModel(with: data, at: jsonKey) else {
						delegate?.onError("Can't parse the json")
						return
					}
					successCallback(model)
				}
		}
		dataTask?.resume()
	}

	static func parseModel(with data: Data, at jsonKey: String) -> Model? {
		do {
			let json = try JSONSerialization.jsonObject(with: data, options: []) as? NSDictionary

			if let dictAtPath = json?.value(forKeyPath: jsonKey) {
				let jsonData = try JSONSerialization.data(withJSONObject: dictAtPath,
														  options: .prettyPrinted)
				let decoder = JSONDecoder()
				decoder.keyDecodingStrategy = .convertFromSnakeCase
				let model =  try decoder.decode(Model.self, from: jsonData)
				return model
			} else {
				return nil
			}
		} catch {
			return nil
		}
	}
}
