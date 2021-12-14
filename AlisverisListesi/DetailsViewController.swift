//
//  DetailsViewController.swift
//  AlisverisListesi
//
//  Created by Hüseyin Şimşek on 20.11.2021.
//

import UIKit
import CoreData

class DetailsViewController: UIViewController, UIImagePickerControllerDelegate,UINavigationControllerDelegate {

    @IBOutlet weak var kaydetButton: UIButton!
    
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var isimTextField: UITextField!
    @IBOutlet weak var fiyatTextFİeld: UITextField!
    @IBOutlet weak var bedenTextField: UITextField!
    
    var secilenUrunIsmi = ""
    var secilenUrunUUID: UUID?
        
    override func viewDidLoad() {
        super.viewDidLoad()

        if secilenUrunIsmi != ""{
            // Core Data Seçilen Ürün Bilgilerini Göster !
            kaydetButton.isHidden = true
                if let uuidString = secilenUrunUUID?.uuidString{
                let appDelegate = UIApplication.shared.delegate as! AppDelegate
                let context = appDelegate.persistentContainer.viewContext
                let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Alisveris")
                                                              // id Şuna eşit olanları getir demek
                fetchRequest.predicate = NSPredicate(format: "id = %@", uuidString)
                fetchRequest.returnsObjectsAsFaults = false
                do{
                    let sonuclar  = try context.fetch(fetchRequest)
                    if sonuclar.count > 0{
                        for sonuclar in sonuclar as! [NSManagedObject] {
                            if let isim = sonuclar.value(forKey: "isim") as? String{
                                isimTextField.text = isim
                            }
                            if let fiyat = sonuclar.value(forKey: "fiyat") as? Int{
                                fiyatTextFİeld.text = String(fiyat)
                            }
                            if let beden = sonuclar.value(forKey: "beden") as? String{
                                bedenTextField.text = beden
                        }
                            if let gorselData = sonuclar.value(forKey: "gorsel") as? Data{
                                let image = UIImage(data: gorselData)
                                imageView.image = image
                            }
                        }
                    }
                    
                }catch{
                   
                    print("Hata var")
                }
            }
            
        }
        
        else{
            kaydetButton.isHidden = false
            kaydetButton.isEnabled = false
            isimTextField.text = ""
            fiyatTextFİeld.text = ""
            bedenTextField.text = ""
        }
        let gestrueRecognizer  = UITapGestureRecognizer(target: self, action: #selector(klavyeyiKapat))
            view.addGestureRecognizer(gestrueRecognizer)
        
        imageView.isUserInteractionEnabled = true
        let imageGesturRecognizer = UITapGestureRecognizer(target: self, action: #selector(gorselSec))
        imageView.addGestureRecognizer(imageGesturRecognizer)
    }
    
    @IBAction func kaydetBtnTiklandi(_ sender: Any) {
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        let context = appDelegate.persistentContainer.viewContext
        
        let alisveris = NSEntityDescription.insertNewObject(forEntityName: "Alisveris", into: context)
        alisveris.setValue(isimTextField.text, forKey: "isim")
        alisveris.setValue(bedenTextField.text, forKey: "beden")
        if let fiyat = Int(fiyatTextFİeld.text!){
            alisveris.setValue(fiyat, forKey: "fiyat")
            
        }
        alisveris.setValue(UUID(), forKey: "id")
        let data = imageView.image!.jpegData(compressionQuality: 0.5)
        alisveris.setValue(data, forKey: "gorsel")
        do{
            try context.save()
            print("kayıt edildi")
        } catch{
        
                print("hata var")
        }
        
       
        // EKLENDİKTEN SONRA GERİ DÖNÜYOR ANA EKRANA
        NotificationCenter.default.post(name: NSNotification.Name(rawValue: "veriGirildi"), object: nil)
        self.navigationController?.popViewController(animated: true)
        
    }
    @objc func klavyeyiKapat(){
        view.endEditing(true) // klavyeyi kapat
    }

    @objc func gorselSec(){
        let picker = UIImagePickerController()
        picker.delegate = self
        picker.sourceType = .photoLibrary
        picker.allowsEditing = true
        present(picker, animated: true, completion: nil)
    }
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        kaydetButton.isEnabled = true
        imageView.image = info[.originalImage] as? UIImage
        self.dismiss(animated: true, completion: nil)
    }
}
