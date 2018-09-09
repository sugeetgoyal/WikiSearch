//
//  BaseNetworkModel.swift
//  WikiSearch
//  Created by Sugeet-Home on 09/09/18.
//  Copyright © 2018 Sugeet-Home. All rights reserved.
//

import Foundation
import UIKit

extension Array where Element: BaseNetworkModel {

	public func toNSDictionaryArray() -> [NSDictionary] {
		var subArray = [NSDictionary]()
		for item in self {
			subArray.append(item.toJson())
		}
		return subArray
	}

	/**
	Converts the array to JSON.

	:returns: The array as JSON, wrapped in NSData.
	*/
	public func toJson(_ prettyPrinted: Bool = false) -> Data? {
		let subArray = self.toNSDictionaryArray()

		if JSONSerialization.isValidJSONObject(subArray) {
			do {
				let json = try JSONSerialization.data(withJSONObject: subArray, options: (prettyPrinted ? .prettyPrinted: JSONSerialization.WritingOptions()))
				return json
			} catch let error as NSError {
				print("ERROR: Unable to serialize json, error: \(error)")
			}
		}

		return nil
	}

	/**
	Converts the array to a JSON string.

	:returns: The array as a JSON string.
	*/
	public func toJsonString(_ prettyPrinted: Bool = false) -> String? {
		if let jsonData = toJson(prettyPrinted) {
			return NSString(data: jsonData, encoding: String.Encoding.utf8.rawValue) as String?
		}

		return nil
	}
}

private class SortedDictionary: NSMutableDictionary {
	var dictionary1 = [String: AnyObject]()

	override fileprivate var count: Int {
		return dictionary1.count
	}

	override fileprivate func keyEnumerator() -> NSEnumerator {
		let sortedKeys: NSArray = dictionary1.keys.sorted() as NSArray
		return sortedKeys.objectEnumerator()
	}

	override fileprivate func setValue(_ value: Any?, forKey key: String) {
		dictionary1[key] = value as AnyObject?
	}

	override fileprivate func object(forKey aKey: Any) -> Any? {
		if let key = aKey as? String {
			return dictionary1[key]
		}

		return nil
	}
}

public class BaseNetworkModel {
	public func toJson() -> NSDictionary {
		return Mirror(reflecting: self).toJson()
	}
}

extension Mirror {
	public func formatKey(_ key: String) -> String {
		return key
	}

	public func formatValue(_ value: Any?, forKey: String) -> Any? {
		return value
	}

	func setValue(_ dictionary: NSDictionary, value: Any?, forKey: String) {
		dictionary.setValue(formatValue(value, forKey: forKey), forKey: formatKey(forKey))
	}

	public func toJson() -> NSDictionary {
		let propertiesDictionary = SortedDictionary()
		for (propName, propValue) in self.children {
			if isEnum(propValue) {
				setValue(propertiesDictionary, value: "\(propValue)" as AnyObject?, forKey: propName!)
			} else if let propValue: AnyObject = self.unwrap(propValue) as AnyObject?, let propName = propName {
				if let serializablePropValue = propValue as? BaseNetworkModel {
					setValue(propertiesDictionary, value: serializablePropValue.toJson(), forKey: propName)
				} else if let arrayPropValue = propValue as? [BaseNetworkModel] {
					let subArray = arrayPropValue.toNSDictionaryArray()
					setValue(propertiesDictionary, value: subArray as AnyObject?, forKey: propName)
				} else if let arrayPropValue = propValue as? [String] {
					setValue(propertiesDictionary, value: arrayPropValue as AnyObject?, forKey: propName)
                } else if propValue is Int || propValue is Double || propValue is Float || propValue is Bool || propValue is CGFloat {
					setValue(propertiesDictionary, value: propValue, forKey: propName)
				} else if let dataPropValue = propValue as? Data {
					setValue(propertiesDictionary,
					         value: dataPropValue.base64EncodedString(options: .lineLength64Characters) as AnyObject?, forKey: propName)
				} else if let datePropValue = propValue as? Date {
					setValue(propertiesDictionary, value: datePropValue.timeIntervalSince1970 as AnyObject?, forKey: propName)
				} else if let stringValue = propValue as? String {
					setValue(propertiesDictionary, value: stringValue, forKey: propName)
                } else if let arrayPropValue = propValue as? [Double] {
                    setValue(propertiesDictionary, value: arrayPropValue as AnyObject?, forKey: propName)
                } else if let anyPropValue = propValue as? [String:Any] {
                    setValue(propertiesDictionary, value: anyPropValue, forKey: propName)
                } else if let anyPropValue = propValue as? Array<[String:Any]> {
                    setValue(propertiesDictionary, value: anyPropValue, forKey: propName)
                }
			} else if let propValue: Int8 = propValue as? Int8 {
				setValue(propertiesDictionary, value: NSNumber(value: propValue as Int8), forKey: propName!)
			} else if let propValue: Int16 = propValue as? Int16 {
				setValue(propertiesDictionary, value: NSNumber(value: propValue as Int16), forKey: propName!)
			} else if let propValue: Int32 = propValue as? Int32 {
				setValue(propertiesDictionary, value: NSNumber(value: propValue as Int32), forKey: propName!)
			} else if let propValue: Int64 = propValue as? Int64 {
				setValue(propertiesDictionary, value: NSNumber(value: propValue as Int64), forKey: propName!)
			} else if let propValue: UInt8 = propValue as? UInt8 {
				setValue(propertiesDictionary, value: NSNumber(value: propValue as UInt8), forKey: propName!)
			} else if let propValue: UInt16 = propValue as? UInt16 {
				setValue(propertiesDictionary, value: NSNumber(value: propValue as UInt16), forKey: propName!)
			} else if let propValue: UInt32 = propValue as? UInt32 {
				setValue(propertiesDictionary, value: NSNumber(value: propValue as UInt32), forKey: propName!)
			} else if let propValue: UInt64 = propValue as? UInt64 {
				setValue(propertiesDictionary, value: NSNumber(value: propValue as UInt64), forKey: propName!)
			} else {
				setValue(propertiesDictionary, value: nil, forKey: propName!)
			}
		}

		if let parent = self.superclassMirror {
			for (propertyName, value) in parent.toJson() {
				setValue(propertiesDictionary, value: value as AnyObject?, forKey: propertyName as! String)
			}
		}

		return propertiesDictionary
	}

	/**
	Converts the class to JSON.
	- returns: The class as JSON, wrapped in NSData.
	*/
	public func toJson1(_ prettyPrinted: Bool = false) -> Data? {
		let dictionary = self.toJson()

		if JSONSerialization.isValidJSONObject(dictionary) {
			do {
				let json = try JSONSerialization.data(withJSONObject: dictionary, options: (prettyPrinted ? .prettyPrinted: JSONSerialization.WritingOptions()))
				return json
			} catch let error as NSError {
				print("ERROR: Unable to serialize json, error: \(error)")
			}
		}

		return nil
	}

	/**
	Converts the class to a JSON string.
	- returns: The class as a JSON string.
	*/
	public func toJsonString(_ prettyPrinted: Bool = false) -> String? {
		if let jsonData = self.toJson1(prettyPrinted) {
			return NSString(data: jsonData, encoding: String.Encoding.utf8.rawValue) as String?
		}

		return nil
	}


	/**
	Unwraps 'any' object. See http://stackoverflow.com/questions/27989094/how-to-unwrap-an-optional-value-from-any-type
	- returns: The unwrapped object.
	*/
	func unwrap(_ any: Any) -> Any? {
		let mi = Mirror(reflecting: any)
		if mi.displayStyle != .optional {
			return any
		}

		if mi.children.count == 0 { return nil }
		let (_, some) = mi.children.first!
		return some
	}

	func isEnum(_ any: Any) -> Bool {
		return Mirror(reflecting: any).displayStyle == .enum
	}
}
