//
//  WeaponSkin.swift
//  
//
//  Created by Tomas Martins on 02/09/19.
//

import Foundation

/// Object that represents a CSGO item, such as weapon skins, stickers, agents, patches and others.
@objc public class Skin: NSObject, NSCoding, Decodable {
    /// Contains all the information about the item
    @objc public let itemInfo: ItemInfo?
    /// The error message, in case the API returns an error
    @objc public let error: String?
    /// The error code, in case the API returns an error
    public let code: Int?
    
    //Objective-C only properties
    /// The error code, in case the API returns an error, in NSNumber type.
    /// This property can only be accessed through Objective-C
    @available(swift, obsoleted: 1.0)
    @objc public var nsCode: NSNumber? {
        return code as NSNumber?
    }
    
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
    
    //MARK: - NSCoding methods
    public func encode(with coder: NSCoder) {
        coder.encode(itemInfo, forKey: CodingKeys.itemInfo.rawValue)
        coder.encode(code, forKey: CodingKeys.code.rawValue)
        coder.encode(error, forKey: CodingKeys.error.rawValue)
    }
    
    private init(itemInfo: ItemInfo?, error: String?, code: Int?) {
        self.itemInfo = itemInfo
        self.error = error
        self.code = code
    }
    
    required convenience public init?(coder: NSCoder) {
        let itemInfo = coder.decodeObject(forKey: CodingKeys.itemInfo.rawValue) as? ItemInfo
        let code = coder.decodeObject(forKey: CodingKeys.code.rawValue) as? Int
        let error = coder.decodeObject(forKey: CodingKeys.error.rawValue) as? String
        self.init(itemInfo: itemInfo, error: error, code: code)
    }
}

// MARK: - Properties

public extension Skin {
    /// Boolean value indicating whether the skin is StatTrak
    @objc var isStatTrak: Bool {
        guard let weaponInfo = self.itemInfo, weaponInfo.statTrak != nil else {
            return false
        }
        return true
    }
    
    /// Boolean value indicating whether the skin has painting applied
    @objc var isVanilla: Bool {
        guard let weaponInfo = self.itemInfo, weaponInfo.name == "-" else {
            return false
        }
        return true
    }
    
    /// Boolean value indicating whether the skin is a Souvenir
    @objc var isSouvenir: Bool {
        guard let weaponInfo = self.itemInfo, weaponInfo.qualityName == "Souvenir" else {
            return false
        }
        return true
    }
    
    /// String representing the item's inspect link
    @objc var inspectLink: String? {
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
    
    @objc var rarity: Rarity {
        return Rarity(skin: self)
    }
    
    /// Returns the URL to get the screenshot of the item
    /**
     Creates a URL to get the skin's screenshot from cs.deals screnshot service
     
     - Returns: An optional string representing the URL to get the skin's screenshot or nil if it's the inspect link is invalid
    */
    @objc var screenshotURL: String? {
        let baseURL = "https://csgo.gallery/"
        guard let inspectLink = self.inspectLink else { return nil }
        return "\(baseURL)\(inspectLink)"
    }
}
