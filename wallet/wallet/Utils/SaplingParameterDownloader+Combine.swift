//
//  SaplingParameterDownloader+Combine.swift
//  ECC-Wallet
//
//  Created by Francisco Gindre on 6/21/21.
//  Copyright © 2021 Francisco Gindre. All rights reserved.
//

import Foundation
import combine_urlsession_downloader
import ZcashLightClientKit
import Combine

extension SaplingParameterDownloader {
    typealias DownloadResult = (spendingParams: URL, outputParams: URL)
    
    static func downloadParametersIfNeeded(spendParamsDownloadURL: URL? = nil, outputParamsDownloadURL: URL? = nil, spendParamsStoreURL: URL? = nil, outputParamsStoreURL: URL? = nil) -> AnyPublisher<DownloadResult,URLError> {
        do {
            let spendURL = try unwrapOrFallBack(url: spendParamsStoreURL) {
                try URL.spendParamsURL()
            }
            let outputURL = try unwrapOrFallBack(url: outputParamsStoreURL, {
                try URL.outputParamsURL()
            })
            
            guard let spendParamDownloadURL = spendParamsDownloadURL ?? URL(string: spendParamsURLString),
                  let outputParamDownloadURL = outputParamsDownloadURL ?? URL(string: outputParamsURLString) else {
                return Fail.init(error: URLError(.badURL)).eraseToAnyPublisher()
            }
           
            return locate(at: spendURL, orDownload: spendParamDownloadURL)
                .combineLatest(locate(at: outputURL, orDownload: outputParamDownloadURL))
                .map { (spend, output) in
                    DownloadResult(spendingParams: spend, outputParams: output)
                }
                .eraseToAnyPublisher()
            
                
        } catch {
            return Fail.init(error: URLError(.cannotOpenFile)).eraseToAnyPublisher()
        }
    }
    
    static func unwrapOrFallBack(url: URL?, _ fallBack: ( () throws -> URL)) throws -> URL {
        guard let url = url else {
            return try fallBack()
        }
        
        return url
    }
    
    fileprivate static func locate(at fileURL: URL, orDownload from: URL) -> AnyPublisher<URL, URLError> {
        guard !FileManager.default.isFilePresent(fileURL) else {
            return Result.success(fileURL).publisher.eraseToAnyPublisher()
        }
        
        return URLSession.shared.downloadTaskPublisher(for: from)
            .map { (url: URL, response: URLResponse) in
                url
            }
            .tryMap({ url in
                do {
                    try FileManager.default.moveItem(at: url, to: fileURL)
                    return fileURL
                } catch {
                    throw URLError(.cannotMoveFile)
                }
            })
            .mapError({ e in
                guard let error = e as? URLError else {
                    return URLError(.badURL)
                }
                return error
            })
            .eraseToAnyPublisher()
    }
}

extension FileManager {
    func isFilePresent(_ url: URL) -> Bool {
        (try? self.attributesOfItem(atPath: url.path)) != nil
    }
}
