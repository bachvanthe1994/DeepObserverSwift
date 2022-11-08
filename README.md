# DeepObserverSwift
observer, deep observer, react native state

```swift
//
//  SecondViewController.swift
//  TestSwift
//
//  Created by thebv on 25/10/2022.
//

import UIKit

extension Dictionary {
    
    var jsonString: String? {
        var result: String? = nil
        
        do {
            let jsonData = try JSONSerialization.data(withJSONObject: self, options: [])
            result = String(data: jsonData, encoding: .utf8)
        } catch let error {
            print(error.localizedDescription)
        }
        
        return result
    }
    
}


@objcMembers class UserClass: NSObject {
    dynamic var avatar: String?
    dynamic var phoneNumber: String?
    dynamic var email: String?
    dynamic var users: [UserClass]?
}

@objcMembers class MyClass: NSObject {
    dynamic var name: String?
    dynamic var age: NSNumber = 0
    dynamic var weight: NSNumber = 0
    dynamic var height: NSNumber = 0
    dynamic var width: NSNumber = 0
    dynamic var user: UserClass?
    dynamic var users: [UserClass]?
}


class SecondViewController: UIViewController {

    var observerProxy = VNPSDKObserverProxy()
    
    @objc dynamic var mys: [MyClass]? = []
    @objc dynamic var my: MyClass?
    
    deinit {
        print("deinit: \(#filePath)")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        observerProxy.observe(target: self, keyPath: \.mys) { [weak self] object, keyPath, indexs, indexsMapping  in
            guard let _ = self else { return }
            print("mys: key: \(keyPath), indexs: \(indexsMapping ?? [:]), object: ")
            if keyPath == #keyPath(mys.users.avatar),
               indexsMapping?[#keyPath(mys)] == 0,
               indexsMapping?[#keyPath(mys.users)] == 2 {
                print("mys: key: \(keyPath), indexs: \(indexsMapping ?? [:]), object: \(String(describing: object??[0].users?[2].avatar))")
            }
        }
        
        observerProxy.observe(target: self, keyPath: \.my) { [weak self] object, keyPath, indexs, indexsMapping  in
            guard let _ = self else { return }
            print("my: key: \(keyPath), indexs: \(indexsMapping ?? [:]), object: ")
            if keyPath == #keyPath(my.users.avatar),
               indexsMapping?[#keyPath(my)] == 0,
               indexsMapping?[#keyPath(my.users)] == 2 {
                print("my: key: \(keyPath), indexs: \(indexsMapping ?? [:]), object: \(String(describing: object??.users?[2].avatar))")
            }
        }
        
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) { [weak self] in
            guard let self = self else { return }
            print("-----------------1")
            self.mys = [MyClass(), MyClass(), MyClass(), MyClass()]
            print("-----------------2")
            self.mys?.first?.name = "B"
            print("-----------------3")
            self.mys?.first?.name = "CCCCCC"
            print("-----------------4")
            self.mys?.first?.user = UserClass()
            print("-----------------5")
            self.mys?.first?.users = [UserClass(), UserClass(), UserClass()]
            print("-----------------6")
            self.mys?.first?.users?.last?.users = [UserClass(), UserClass(), UserClass(), UserClass()]
            print("-----------------7")
            self.mys?.first?.users?.last?.users?.last?.avatar = "https://abc.xyz"
            print("-----------------8")
            self.mys?[2] = MyClass()
            print("-----------------9")
            self.mys?.remove(at: 0)
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 2) { [weak self] in
            guard let self = self else { return }
            print("-----------------10")
            self.my = MyClass()
            print("-----------------11")
            self.my?.name = "B"
            print("-----------------12")
            self.my?.name = "CCCCCC"
            print("-----------------13")
            self.my?.user = UserClass()
            print("-----------------14")
            self.my?.users = [UserClass(), UserClass(), UserClass()]
            print("-----------------15")
            self.my?.users?.last?.users = [UserClass(), UserClass(), UserClass(), UserClass()]
            print("-----------------16")
            self.my?.users?.last?.users?.last?.avatar = "https://abc.xyz"
            print("-----------------17")
            self.my = MyClass()
        }
        
    }

}

```

```log
mys: key: mys, indexs: [:], object: 
my: key: my, indexs: [:], object: 
-----------------1
mys: key: mys, indexs: [:], object: 
-----------------2
mys: key: mys.name, indexs: ["mys": 0], object: 
mys: key: mys, indexs: [:], object: 
-----------------3
mys: key: mys.name, indexs: ["mys": 0], object: 
mys: key: mys, indexs: [:], object: 
-----------------4
mys: key: mys.user.avatar, indexs: ["mys": 0], object: 
mys: key: mys, indexs: [:], object: 
mys: key: mys.user.phoneNumber, indexs: ["mys": 0], object: 
mys: key: mys, indexs: [:], object: 
mys: key: mys.user.users, indexs: ["mys": 0], object: 
mys: key: mys, indexs: [:], object: 
mys: key: mys.user.email, indexs: ["mys": 0], object: 
mys: key: mys, indexs: [:], object: 
mys: key: mys.user, indexs: ["mys": 0], object: 
mys: key: mys, indexs: [:], object: 
-----------------5
mys: key: mys.users, indexs: ["mys": 0], object: 
mys: key: mys, indexs: [:], object: 
-----------------6
mys: key: mys.users.users, indexs: ["mys": 0, "mys.users": 2], object: 
mys: key: mys, indexs: [:], object: 
mys: key: mys.users, indexs: ["mys": 0], object: 
mys: key: mys, indexs: [:], object: 
-----------------7
mys: key: mys.users.users.avatar, indexs: ["mys": 0, "mys.users.users": 3, "mys.users": 2], object: 
mys: key: mys, indexs: [:], object: 
mys: key: mys.users, indexs: ["mys": 0], object: 
mys: key: mys, indexs: [:], object: 
mys: key: mys.users.users, indexs: ["mys": 0, "mys.users": 2], object: 
mys: key: mys, indexs: [:], object: 
mys: key: mys.users, indexs: ["mys": 0], object: 
mys: key: mys, indexs: [:], object: 
-----------------8
mys: key: mys, indexs: [:], object: 
-----------------9
mys: key: mys, indexs: [:], object: 
-----------------10
my: key: my.user, indexs: [:], object: 
my: key: my.age, indexs: [:], object: 
my: key: my.height, indexs: [:], object: 
my: key: my.name, indexs: [:], object: 
my: key: my.users, indexs: [:], object: 
my: key: my.weight, indexs: [:], object: 
my: key: my.width, indexs: [:], object: 
my: key: my, indexs: [:], object: 
-----------------11
my: key: my.name, indexs: [:], object: 
-----------------12
my: key: my.name, indexs: [:], object: 
-----------------13
my: key: my.user.phoneNumber, indexs: [:], object: 
my: key: my.user.email, indexs: [:], object: 
my: key: my.user.users, indexs: [:], object: 
my: key: my.user.avatar, indexs: [:], object: 
my: key: my.user, indexs: [:], object: 
-----------------14
my: key: my.users, indexs: [:], object: 
-----------------15
my: key: my.users.users, indexs: ["my.users": 2], object: 
my: key: my.users, indexs: [:], object: 
-----------------16
my: key: my.users.users.avatar, indexs: ["my.users.users": 3, "my.users": 2], object: 
my: key: my.users, indexs: [:], object: 
my: key: my.users.users, indexs: ["my.users": 2], object: 
my: key: my.users, indexs: [:], object: 
-----------------17
my: key: my.user.avatar, indexs: [:], object: 
my: key: my.user.users, indexs: [:], object: 
my: key: my.user.email, indexs: [:], object: 
my: key: my.user.phoneNumber, indexs: [:], object: 
my: key: my.width, indexs: [:], object: 
my: key: my.weight, indexs: [:], object: 
my: key: my.users, indexs: [:], object: 
my: key: my.name, indexs: [:], object: 
my: key: my.height, indexs: [:], object: 
my: key: my.age, indexs: [:], object: 
my: key: my.user, indexs: [:], object: 
my: key: my, indexs: [:], object: 

```

