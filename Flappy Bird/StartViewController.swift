//
//  StartViewController.swift
//  Flappy Bird
//
//  Created by Naoki Arakawa on 2019/03/04.
//  Copyright © 2019 Naoki Arakawa. All rights reserved.
//

import UIKit

class StartViewController: UIViewController {
    
    @IBOutlet var logoImageView: UIImageView!
    
    var timeString = String()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        let ud = UserDefaults.standard
        if ud.object(forKey: "saveData") == nil {
            
            ud.set("0", forKey: "saveData")
            
        }
        
        self.timeString = ud.object(forKey: "saveData") as! String
        
        UIView.animate(withDuration: 2.0, animations: {
            
            self.logoImageView.frame = CGRect(x: 16, y: 143, width: 343, height: 343)
            
        }, completion: nil)
            
            
        }
    

    @IBAction func postLine(_ sender: Any) {
        
        shareLine()
    }
    

    //ボタンをクリックして、以下のコードを呼べるようにする
    func shareLine(){
        
        let urlscheme: String = "line://msg/text"
        let message = timeString
        // line:/msg/text/(メッセージ)
        let urlstring = urlscheme + "/" + message
        
        // URLエンコード
        guard let  encodedURL = urlstring.addingPercentEncoding(withAllowedCharacters: NSCharacterSet.urlQueryAllowed) else {
            return
        }
        
        // URL作成
        guard let url = URL(string: encodedURL) else {
            return
        }
        
        if UIApplication.shared.canOpenURL(url) {
            if #available(iOS 10.0, *) {
                UIApplication.shared.open(url, options: [:], completionHandler: { (succes) in
                    //  LINEアプリ表示成功
                })
            }else{
                UIApplication.shared.openURL(url)
            }
        }else {
            // LINEアプリが無い場合
            let alertController = UIAlertController(title: "エラー", message: "LINEがインストールされていません", preferredStyle: UIAlertController.Style.alert)
            alertController.addAction(UIAlertAction(title: "OK", style: UIAlertAction.Style.default))
            present(alertController,animated: true,completion: nil)
       
        }
        
     }
    
    //画面のどこかにタッチした時にゲームを開始したい
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        
        let gameVC = self.storyboard?.instantiateViewController(withIdentifier: "gameVC") as! GameViewController
        self.navigationController?.pushViewController(gameVC, animated: true)
        
    }
    
    }


