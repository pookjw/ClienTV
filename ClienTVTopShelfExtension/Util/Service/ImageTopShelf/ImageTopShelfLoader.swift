//
//  ImageTopShelfLoader.swift
//  ClienTVTopShelfExtension
//
//  Created by Jinwoo Kim on 6/11/21.
//

import Foundation

final class ImageTopShelfLoader {
    enum LoaderError: Error {
        case noCacheFound
    }
    
    static let shared: ImageTopShelfLoader = .init()
    
    private let decoder: JSONDecoder = .init()
    private let userDefaults: UserDefaults = .init(suiteName: ImageTopShelfConstant.suitName) ?? .standard
    
    //
    
    func load() throws -> [ImageTopShelfData] {
        guard let data: Data = userDefaults.data(forKey: ImageTopShelfConstant.imageTopShelfDatasKey) else {
            throw LoaderError.noCacheFound
        }
        
        let datas: [ImageTopShelfData] = try decoder.decode([ImageTopShelfData].self, from: data)

        return datas
    }
}
