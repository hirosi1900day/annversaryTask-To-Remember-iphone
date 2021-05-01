//
//  AnniversaryIndexViewController.swift
//  Anniversary-forgetting-prevention
//
//  Created by 徳富博 on 2021/04/26.
//

import UIKit
import RealmSwift

class AnniversaryIndexViewController: UIViewController{
    
    let realm = try! Realm()
    var AnniversaryArray = try! Realm().objects(Anniversary.self).sorted(byKeyPath: "date", ascending: true)
    
    @IBOutlet weak var AnniversaryIndexTableView: UITableView!
    @IBAction func InputButton(_ sender: Any) {
        let InputViewController = self.storyboard?.instantiateViewController(withIdentifier: "Input") as! InputViewController
        let anniversary = Anniversary()
        let allRealmObject = realm.objects(Anniversary.self)
        if allRealmObject.count != 0 {
            anniversary.id = allRealmObject.max(ofProperty: "id")! + 1
        }
        InputViewController.anniversaryArray = anniversary
        navigationController?.pushViewController(InputViewController, animated: true)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        AnniversaryIndexTableView.delegate = self
        AnniversaryIndexTableView.dataSource = self
    }
    
    override func viewWillAppear(_ animated: Bool) {
        AnniversaryIndexTableView.reloadData()
    }
    
}

//MARK: delegate,dataSource
extension AnniversaryIndexViewController: UITableViewDelegate,UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return AnniversaryArray.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let anniversary = AnniversaryArray[indexPath.row]
        let cell = tableView.dequeueReusableCell(withIdentifier: "AnniversaryIndexCell", for: indexPath) as! AnniversaryTableViewCell
        cell.CellTitle.text = anniversary.title
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd HH:mm"
        
        let dateString:String = formatter.string(from: anniversary.date)
        cell.CellDate.text = dateString
        if anniversary.present == true {
            cell.backgroundColor = UIColor.green
        }
        
        return cell
    }
    
    
    // 各セルを選択した時に実行されるメソッド
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let InputViewController = self.storyboard?.instantiateViewController(withIdentifier: "Input") as! InputViewController
        
        InputViewController.anniversaryArray = AnniversaryArray[indexPath.row]
        
        navigationController?.pushViewController(InputViewController, animated: true)
    }
    
    // セルが削除が可能なことを伝えるメソッド
    func tableView(_ tableView: UITableView, editingStyleForRowAt indexPath: IndexPath)-> UITableViewCell.EditingStyle {
        return .delete
    }
    // Delete ボタンが押された時に呼ばれるメソッド
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            
            // 削除するタスクを取得する
            let anniversaryArray = self.AnniversaryArray[indexPath.row]
            
            // ローカル通知をキャンセルする
            let center = UNUserNotificationCenter.current()
            center.removePendingNotificationRequests(withIdentifiers: [String(anniversaryArray.id)])
            center.removePendingNotificationRequests(withIdentifiers: [String(anniversaryArray.id) + "before"])
            // データベースから削除する
            try! realm.write {
                self.realm.delete(self.AnniversaryArray[indexPath.row])
                tableView.deleteRows(at: [indexPath], with: .fade)
            }
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 80
    }
    
    
}

class AnniversaryTableViewCell: UITableViewCell {
    
    @IBOutlet weak var CellTitle: UILabel!
    @IBOutlet weak var CellDate: UILabel!
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
}
