//
//  ImageLoader.swift
//  MovieVault
//
//  Created by Mohammad Shariq on 10/09/25.
//

import Foundation
import SwiftUI

final class ImageLoader: ObservableObject {
    static let shared = ImageLoader()

    private let cache = NSCache<NSURL, UIImage>()
    private let metadataCache = NSCache<NSURL, NSDate>()
    private let ttl: TimeInterval = 60 * 60 // 1 hour

    @MainActor @Published var image: UIImage?

    func load(from url: URL?, cacheKey: String? = nil) async {
        guard let url else { return }
        let key = url as NSURL
        if let cached = cache.object(forKey: key),
           let meta = metadataCache.object(forKey: key) as Date?,
           Date().timeIntervalSince(meta) < ttl {
            await MainActor.run {
                self.image = cached
            }
            return
        }
        do {
            let (data, response) = try await URLSession.shared.data(from: url)
            guard let http = response as? HTTPURLResponse, 200..<300 ~= http.statusCode else { return }
            if let img = UIImage(data: data) {
                cache.setObject(img, forKey: key)
                metadataCache.setObject(NSDate(), forKey: key)
                await MainActor.run {
                    self.image = img
                }
            }
        } catch {
            // ignore
        }
    }
}

struct RemoteImageView: View {
    let url: URL?
    @StateObject private var loader = ImageLoader()

    var body: some View {
        Group {
            if let uiImage = loader.image {
                Image(uiImage: uiImage)
                    .resizable()
                    .scaledToFill()
            } else {
                Rectangle().fill(Color.gray.opacity(0.2))
            }
        }
        .task { await loader.load(from: url) }
    }
}


