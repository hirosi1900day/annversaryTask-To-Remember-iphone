//
//  InputViewController.swift
//  Anniversary-forgetting-prevention
//
//  Created by 徳富博 on 2021/04/26.
//

import UIKit
import RealmSwift
import UserNotifications

class InputViewController: UIViewController {

    var anniversaryArray: Anniversary!
    private var presentSwitch = false
    let realm = try! Realm()
    
    @IBOutlet weak var Titile: UITextField!
    @IBOutlet weak var Content: UITextView!
    @IBOutlet weak var Date: UIDatePicker!
    @IBOutlet weak var PresentSwitchOutlet: UISwitch!
    @IBAction func PresentSwitchButton(_ sender: UISwitch) {
        if sender.isOn {
            presentSwitch = true
        } else {
            presentSwitch = false
        }
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // 背景をタップしたらdismissKeyboardメソッドを呼ぶように設定する
        let tapGesture: UITapGestureRecognizer = UITapGestureRecognizer(target:self, action:#selector(dismissKeyboard))
        self.view.addGestureRecognizer(tapGesture)

        Titile.text = anniversaryArray?.title ?? ""
        Content.text = anniversaryArray?.contents ?? ""
        Date.date = anniversaryArray?.date ?? Foundation.Date()
        presentSwitch = anniversaryArray?.present ?? false
        if anniversaryArray?.present == false {
            PresentSwitchOutlet.isOn = false
        } else {
            PresentSwitchOutlet.isOn = true
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        try! realm.write {
            
            self.anniversaryArray.title = Titile.text ?? ""
            self.anniversaryArray.contents = Content.text ?? ""
            self.anniversaryArray.date = Date.date
            self.anniversaryArray.present = presentSwitch
            if anniversaryArray.title != "" && anniversaryArray.contents != ""{
                self.realm.add(self.anniversaryArray, update: .modified)
                setNotification(anniversaryArray: anniversaryArray)
            }
        }
        
        super.viewWillDisappear(animated)
    }
    
    private func setNotification(anniversaryArray: Anniversary) {
        //通知当日に通知するコンテント
        let content = UNMutableNotificationContent()
        if anniversaryArray.title == "" {
            content.title = "(タイトルなし)"
        } else {
            content.title = anniversaryArray.title
        }
        if anniversaryArray.contents == "" {
            content.body = "(内容なし)"
        } else {
            content.body = anniversaryArray.contents
        }
        content.sound = UNNotificationSound.default
        let calendar = Calendar.current
        let dateComponents = calendar.dateComponents([.year, .month, .day, .hour, .minute], from: anniversaryArray.date)
        
        let beforeDateDate = DateComponents(day: -7)
        let beforeDate = calendar.date(byAdding: beforeDateDate, to: anniversaryArray.date)
        let beforeDateComponents = calendar.dateComponents(in: TimeZone.current, from: beforeDate ?? Foundation.Date())
        
        let center = UNUserNotificationCenter.current()
        
        //7日前にローカル通知を表示する
        if presentSwitch {
            let contentBefore = UNMutableNotificationContent()
            if anniversaryArray.title == "" {
                contentBefore.title = "プレゼントは購入しましたか？"
            } else {
                contentBefore.title = anniversaryArray.title + "のプレゼントは購入しましたか？"
            }
            if anniversaryArray.contents == "" {
                contentBefore.body = "(内容なし)"
            } else {
                contentBefore.body = anniversaryArray.contents
            }
            contentBefore.sound = UNNotificationSound.default
            
            let trigger2 = UNCalendarNotificationTrigger(dateMatching: beforeDateComponents, repeats: false)
            
            let request2 = UNNotificationRequest(identifier: String(anniversaryArray.id) + "before", content: contentBefore, trigger: trigger2)
            
            center.add(request2) { (error) in
                print(error ?? "ローカル通知登録 OK")
            }
        }
        
        
        let trigger = UNCalendarNotificationTrigger(dateMatching: dateComponents, repeats: false)
    
        
        let request = UNNotificationRequest(identifier: String(anniversaryArray.id), content: content, trigger: trigger)
        
       
        
        
        center.add(request) { (error) in
            print(error ?? "ローカル通知登録 OK")
        }
        
        center.getPendingNotificationRequests { (requests: [UNNotificationRequest]) in
            for request in requests {
                print("/---------------")
                print(request)
                print("---------------/")
            }
        }
    }
    
    @objc func dismissKeyboard(){
        // キーボードを閉じる
        view.endEditing(true)
    }
}
