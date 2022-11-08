//
//  VNPSDKO.swift
//  TestSwift
//
//  Created by thebv on 25/10/2022.
//

import UIKit

public typealias VNPSDKO_ChangeHandler<PropertyClass> = (
    _ object: PropertyClass?,
    _ keyPath: String,
    _ indexs: [String: Any]?,
    _ indexsMapping: [String: Int]?
) -> Void

public typealias VNPSDKO_ObserveValue = (
    _ keyPath: String,
    _ object: Any?,
    _ change: [NSKeyValueChangeKey : Any]?,
    _ context: UnsafeMutableRawPointer?
) -> Void

extension NSObject {
    var vnpsdk_allKeyPaths: [String : KeyPath<NSObject, Any>] {
        var membersTokeyPaths = [String: KeyPath<NSObject, Any>]()
        let mirror = Mirror(reflecting: self)
        for case (let key?, _) in mirror.children {
            membersTokeyPaths[key] = \Self.[checkedMirrorDescendant: key]
        }
        return membersTokeyPaths
    }
    private subscript(checkedMirrorDescendant key: String) -> Any {
        let m = Mirror(reflecting: self)
        return m.descendant(key) as! NSObject
    }
}


@objc open class VNPSDKObserverProxy: NSObject {
    
    fileprivate var vnpsdk_observerMapping: [String: VNPSDKObserver] = [:]
    
    deinit {
        print("\(#function) \(self)")
        vnpsdk_observerMapping.forEach { (key: String, value: VNPSDKObserver) in
            value.vnpsdk_removeObserver()
        }
    }
    
    func observe<TargetClass: NSObject, PropertyKeyPathClass>(
        target: TargetClass,
        keyPath propertyKeyPath: KeyPath<TargetClass, PropertyKeyPathClass>? = nil,
        changeHandler: @escaping VNPSDKO_ChangeHandler<PropertyKeyPathClass>
    ) {
        var key = ""
        if let _ = propertyKeyPath as? KeyPath<NSObject, Any> {
            key = ""
        } else {
            if let propertyKeyPath = propertyKeyPath {
                key = NSExpression(forKeyPath: propertyKeyPath).keyPath
            }
        }
        observe(target: target, keyPath: propertyKeyPath, keyPathString: key, ignoreConverIndexs: false, changeHandler: changeHandler)
    }
    
    fileprivate func observe<TargetClass: NSObject, PropertyKeyPathClass>(
        target: TargetClass? = nil,
        keyPath propertyKeyPath: KeyPath<TargetClass, PropertyKeyPathClass>? = nil,
        keyPathString: String? = nil,
        ignoreConverIndexs: Bool? = false,
        changeHandler: @escaping VNPSDKO_ChangeHandler<PropertyKeyPathClass>
    ) {
        if let target = target {
            var key = ""
            if let _ = propertyKeyPath as? KeyPath<NSObject, Any> {
                key = ""
            } else {
                if let propertyKeyPath = propertyKeyPath {
                    key = NSExpression(forKeyPath: propertyKeyPath).keyPath
                }
            }
            if let keyPathString = keyPathString {
                key = keyPathString
            }
            let o = VNPSDKObserver()
            o.vnpsdk_observe(target: target, propertyKeyPath: propertyKeyPath, keyPathString: key, ignoreConverIndexs: ignoreConverIndexs, changeHandler: changeHandler)
            vnpsdk_observerMapping["\(target)\(key)"] = o
        }
    }

    open func removeObserver<TargetClass: NSObject, PropertyKeyPathClass>(
        target: TargetClass,
        keyPath propertyKeyPath: KeyPath<TargetClass, PropertyKeyPathClass>
    ) {
        var key = ""
        if let _ = propertyKeyPath as? KeyPath<NSObject, Any> {
            key = ""
        } else {
            key = NSExpression(forKeyPath: propertyKeyPath).keyPath
        }
        let o = vnpsdk_observerMapping["\(target)\(key)"]
        o?.vnpsdk_removeObserver()
        vnpsdk_observerMapping.removeValue(forKey: "\(target)\(key)")
    }
}

class VNPSDKObserver: NSObject {
    fileprivate weak var vnpsdk_target: NSObject?
    fileprivate var vnpsdk_arrObserver: [Any] = []
    fileprivate var vnpsdk_arrObserverKeyPath: [String:NSObject] = [:]
    fileprivate var vnpsdk_supperKeyPath: String = "" //key cha của thằng key muốn observer (thằng này phải != nil thì observer mới hoạt động được)
    fileprivate var vnpsdk_propertyKeyPath: String = "" //key muốn observer
    fileprivate var vnpsdk_observeValueHandlerMapping: [String: VNPSDKO_ObserveValue] = [:]
    fileprivate var vnpsdk_arrObserveProxy: [VNPSDKObserverProxy] = []
    
    fileprivate var ignoreConverIndexs = false
    
    fileprivate func vnpsdk_objectForKeyPathInTarget(_ keyPath: String?) -> NSObject? {
        var object: NSObject?
        if let keyPath = keyPath, keyPath.count > 0 {
            if (keyPath.contains(".")) {
                object = vnpsdk_target?.value(forKeyPath: keyPath) as? NSObject
            } else {
                object = vnpsdk_target?.value(forKey: keyPath) as? NSObject
            }
            return object
        } else {
            return nil
        }
    }
    
    fileprivate func changeHandlerProxy<PropertyClass>(
        _ changeHandler: @escaping VNPSDKO_ChangeHandler<PropertyClass>,
        _ object: PropertyClass?, _ keyPath: String
    ) {
        if let arr = self.vnpsdk_objectForKeyPathInTarget(keyPath) as? [Any] {
            let keyOfArr = String(keyPath.split(separator: ".").last ?? "")
            var p = 0
            arr.forEach { obj in
                if let obj = obj as? NSObject {
                    let vnpsdk_observeProxy = VNPSDKObserverProxy()
                    let finalP = p
                    obj.vnpsdk_allKeyPaths.forEach { objk in
                        vnpsdk_observeProxy.observe(target: obj, keyPath: objk.value, keyPathString: objk.key, ignoreConverIndexs: true) { [weak self] (_ o, _ k, _ i, im) in
                            guard let self = self else { return }
                            let fullK = "\(keyPath).\(k)"
                            let fullArrK = "\(keyOfArr).\(k)"
                            var _i = (i == nil ? [:] : i) ?? [:]
                            if (_i.count == 0) {
                                _i[fullArrK] = finalP
                            }
                            var indexs: [String: Any] = [:]
                            indexs[keyPath] = [_i, finalP]
                            let indexsMapping = self.ignoreConverIndexs ? nil : self.convertIndexs(indexs: indexs)
                            changeHandler(object, fullK, indexs, indexsMapping)
                            changeHandler(object, keyPath, nil, nil)
                            //print("changeHandler 1 keyPath: \(keyPath) fullK: \(fullK)")
                        }
                    }
                    vnpsdk_arrObserveProxy.append(vnpsdk_observeProxy)
                }
                p += 1
            }
        }
        changeHandler(object, keyPath, nil, nil)
        //print("changeHandler 2 \(keyPath)")
    }
    
    private func convertIndexs(indexs: [String: Any]?) -> [String: Int] {
        var keys: [String: Int] = [:]
        if (indexs?.keys.count == 1) {
            let values = indexs?.first?.value as? [Any]
            if let key = indexs?.first?.key,
               values?.count == 2,
               let _indexs = values?.first as? [String: Any],
               let index = values?.last as? Int {
                keys[key] = index
                convertIndexs(indexs: _indexs).forEach { (k, v) in
                    keys["\(key).\(k)"] = v
                }
            }
        }
        return keys
    }
    
    fileprivate func vnpsdk_observe<TargetClass: NSObject, PropertyKeyPathClass>(
        target: TargetClass,
        propertyKeyPath: KeyPath<TargetClass, PropertyKeyPathClass>? = nil,
        keyPathString: String? = nil,
        ignoreConverIndexs: Bool? = false,
        changeHandler: @escaping VNPSDKO_ChangeHandler<PropertyKeyPathClass>
    ) {
        self.ignoreConverIndexs = ignoreConverIndexs ?? false
        self.vnpsdk_target = target
        if let _ = propertyKeyPath as? KeyPath<NSObject, Any> {
            //do nothing
        } else {
            if let propertyKeyPath = propertyKeyPath {
                self.vnpsdk_propertyKeyPath = NSExpression(forKeyPath: propertyKeyPath).keyPath
            }
        }
        
        if let keyPathString = keyPathString {
            self.vnpsdk_propertyKeyPath = keyPathString
        }
        
        if self.vnpsdk_propertyKeyPath.contains("."),
            let supperKeyPath = self.vnpsdk_supperKeyPath.split(separator: ".").first {
            self.vnpsdk_supperKeyPath = String(supperKeyPath)
        } else {
            self.vnpsdk_supperKeyPath = self.vnpsdk_propertyKeyPath
        }
        
        //observer supperKeyPath
        var observeTargetDone = false
        if let _ = propertyKeyPath as? KeyPath<NSObject, Any> {
            //do nothing
        } else {
            if let propertyKeyPath = propertyKeyPath {
                observeTargetDone = true
                vnpsdk_arrObserver.append(target.observe(propertyKeyPath, options: [.new, .old]) { [weak self] obj, change in
                    if let target = self?.vnpsdk_target, let supperKeyPath = self?.vnpsdk_supperKeyPath {
                        if (self?.vnpsdk_objectForKeyPathInTarget(supperKeyPath) != nil) {
                            self?.vnpsdk_addObserver(target: target, fullKeyPath: supperKeyPath, keyPath: supperKeyPath, observeTarget: false)
                            if let object = self?.vnpsdk_objectForKeyPathInTarget(self?.vnpsdk_propertyKeyPath) as? PropertyKeyPathClass {
                                self?.changeHandlerProxy(changeHandler, object, supperKeyPath)
                                //print("changeHandlerProxy 1")
                            } else {
                                self?.changeHandlerProxy(changeHandler, nil, supperKeyPath)
                                //print("changeHandlerProxy 2")
                            }
                        } else {
                            self?.changeHandlerProxy(changeHandler, nil, supperKeyPath)
                            //print("changeHandlerProxy 3")
                        }
                    }
                })
            }
        }
        if let object = vnpsdk_objectForKeyPathInTarget(self.vnpsdk_propertyKeyPath) as? PropertyKeyPathClass {
            //TODO: khi subcribe 1 array thì nó push đoạn này liên tục
            if (self.ignoreConverIndexs) {
                //do nothing
            } else {
                self.changeHandlerProxy(changeHandler, object, self.vnpsdk_propertyKeyPath)
                //print("changeHandlerProxy 4 \(self.vnpsdk_propertyKeyPath)")
            }
        } else {
            self.changeHandlerProxy(changeHandler, nil, self.vnpsdk_propertyKeyPath)
            //print("changeHandlerProxy 5")
        }
        //------
        
        //observer all childkeypath in supperKeyPath
        vnpsdk_addObserver(
            target: self.vnpsdk_target,
            fullKeyPath: self.vnpsdk_supperKeyPath,
            keyPath: self.vnpsdk_supperKeyPath,
            observeTarget: !observeTargetDone
        )
        vnpsdk_observeValueHandlerMapping[self.vnpsdk_supperKeyPath] = { [weak self] (_ keyPath: String, _ object: Any?, _ change: [NSKeyValueChangeKey : Any]?, _ context: UnsafeMutableRawPointer?) in
            guard let self = self else { return }
            let oldObject = change?[.oldKey]
            let newObject = change?[.newKey]
            
            let oldObjectId = "\(oldObject ?? "")"
            let newObjectId = "\(newObject ?? "")"
            
            let object = self.vnpsdk_objectForKeyPathInTarget(keyPath)
            let countKeyPathNotEmpty = (object?.vnpsdk_allKeyPaths.count ?? 0) > 0
            if countKeyPathNotEmpty {
                if let target = self.vnpsdk_target {
                    if (oldObjectId == "<null>" && newObjectId != "<null>") {
                        self.vnpsdk_addObserver(target: target, fullKeyPath: self.vnpsdk_supperKeyPath, keyPath: self.vnpsdk_supperKeyPath, observeTarget: false)
                    }
                }
            }
            
            if let object = self.vnpsdk_objectForKeyPathInTarget(self.vnpsdk_propertyKeyPath) as? PropertyKeyPathClass {
                self.changeHandlerProxy(changeHandler, object, keyPath)
                //print("changeHandlerProxy 6")
            } else {
                self.changeHandlerProxy(changeHandler, nil, keyPath)
                //print("changeHandlerProxy 7")
            }
        }
        //------
    }
    
    fileprivate func vnpsdk_removeObserver() {
        vnpsdk_arrObserverKeyPath.forEach { key in
            self.vnpsdk_target?.removeObserver(self, forKeyPath: key.key)
        }
        vnpsdk_arrObserverKeyPath.removeAll()
    }
    
    fileprivate func vnpsdk_addObserver(
        target: NSObject?,
        fullKeyPath: String,
        keyPath: String,
        observeTarget: Bool
    ) {
        var object: NSObject?
        if (keyPath.count > 0) {
            if (keyPath.contains(".")) {
                object = target?.value(forKeyPath: keyPath) as? NSObject
            } else {
                object = target?.value(forKey: keyPath) as? NSObject
            }
        } else {
            object = target
        }
        var allKeyPaths = (object?.vnpsdk_allKeyPaths ?? [:])
        if ((object as? String) != nil) {
            allKeyPaths = [:]
        }
        for subKeyPath in allKeyPaths {
            var key = ""
            if (fullKeyPath.count > 0) {
                key = "\(fullKeyPath).\(subKeyPath.key)"
            } else {
                key = subKeyPath.key
            }
            if (vnpsdk_arrObserverKeyPath.contains(where: { (_key: String, _object: NSObject) in
                return _key == key
            })) {
                //do nothing
            } else {
                self.vnpsdk_target?.addObserver(self, forKeyPath: key, options: [.initial, .new, .old], context: nil)
                self.vnpsdk_arrObserverKeyPath[key] = object
            }
            if (object?.vnpsdk_allKeyPaths.count ?? 0) > 0 {
                vnpsdk_addObserver(target: object, fullKeyPath: key, keyPath: subKeyPath.key, observeTarget: false)
            }
        }
        if (observeTarget) {
            self.vnpsdk_target?.addObserver(self, forKeyPath: keyPath, options: [.initial, .new, .old], context: nil)
            self.vnpsdk_arrObserverKeyPath[keyPath] = object
        }
    }
    
    override func observeValue(
        forKeyPath keyPath: String?,
        of object: Any?,
        change: [NSKeyValueChangeKey : Any]?,
        context: UnsafeMutableRawPointer?
    ) {
        if let keyPath = keyPath, keyPath.hasPrefix(self.vnpsdk_propertyKeyPath) {
            if let handler = vnpsdk_observeValueHandlerMapping[self.vnpsdk_supperKeyPath] {
                handler(keyPath, object, change, context)
            }
        }
    }
}

