//
//  CommentListAPI.swift
//  ClienTVAPI
//
//  Created by Jinwoo Kim on 6/7/21.
//

import Foundation
import Combine

protocol CommentListAPI {
    func getCommentList(path: String) -> Future<[Comment], Error>
}

enum CommentListAPIError: Error, LocalizedError {
    case nilError
    case parseError
    case responseError(Int)
    
    var errorDescription: String? {
        switch self {
        case .nilError:
            return "nil 에러!"
        case .parseError:
            return "파싱 에러!"
        case .responseError(let code):
            return "HTTP response 에러! (코드 : \(code))"
        }
    }
}
