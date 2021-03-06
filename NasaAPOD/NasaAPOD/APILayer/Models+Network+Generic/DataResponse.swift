//Created by mehboob Alam

import Foundation


///**Note:** I do not knwo the contract as of now so i just created it to showcase, and hence its not used in thsi app
/// A generic Data response, on the basis of API contract with frontend and server
struct DataResponse<ResponseType: Decodable>: Decodable {
    var data: ResponseType?
    let status: String?
    let message: String?
    let errorCode: String?

    private enum CodingKeys: String, CodingKey {
        case data
        case status
        case message
        case errorCode
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        data = try container.decode(ResponseType.self, forKey: .data)

        message = try? container.decode(String.self, forKey: .message)
        errorCode = try? container.decode(String.self, forKey: .errorCode)
        if let value = try? container.decode(Int.self, forKey: .status) {
            status = String(value)
        } else {
            status = try? container.decode(String.self, forKey: .status)
        }
    }
}
