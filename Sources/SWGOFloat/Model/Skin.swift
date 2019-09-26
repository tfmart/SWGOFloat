//
//  WeaponSkin.swift
//  
//
//  Created by Tomas Martins on 02/09/19.
//

import Foundation

public class Skin: Decodable {
    /// Contains all the information about the skin
    public let itemInfo: ItemInfo?
    /// The error message, in case the API returns an error
    public let error: String?
    /// The error code, in case the API returns an error
    public let code: Int?
    
    private enum CodingKeys: String, CodingKey {
        case error, code
        case itemInfo = "iteminfo"
    }
    
    required public init(from decoder:Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.itemInfo = try? container.decode(ItemInfo.self, forKey: .itemInfo)
        self.code = try? container.decode(Int.self, forKey: .code)
        self.error = try? container.decode(String.self, forKey: .error)
    }
}

// MARK: - Extension

public extension Skin {
    /// Boolean value indicating whether the skin is StatTrak
    var isStatTrak: Bool {
        guard let weaponInfo = self.itemInfo, weaponInfo.statTrak != nil else {
            return false
        }
        return true
    }
    
    /// Boolean value indicating whether the skin has painting applied
    var isVanilla: Bool {
        guard let weaponInfo = self.itemInfo, weaponInfo.name == "-" else {
            return false
        }
        return true
    }
    
    /// String representing the item's inspect link
    var inspectLink: String? {
        let baseURL = "steam://rungame/730/76561202255233023/+csgo_econ_action_preview%20"
        var optionalParameter: String
        guard let aParameter = self.itemInfo?.aParameter, let dParameter = self.itemInfo?.dParameter else { return nil }
        if let parameter = self.itemInfo?.inventoryParameter {
            optionalParameter = "S\(parameter)"
        } else if let parameter = self.itemInfo?.marketParameter {
            optionalParameter = "M\(parameter)"
        } else {
            return nil
        }
        return "\(baseURL)\(optionalParameter)A\(aParameter)D\(dParameter)"
    }
    
    /// Returns the URL to get the screenshot of the item
    /**
     Creates a URL to get the skin's screenshot from cs.deals screnshot service
     
     - Returns: An optional string representing the URL to get the skin's screenshot or nil if it's the inspect link is invalid
    */
    func getScreenshotURL() -> String? {
        let baseURL = "csgo.gallery/"
        guard let inspectLink = self.inspectLink else { return nil }
        return "\(baseURL)\(inspectLink)"
    }
}

