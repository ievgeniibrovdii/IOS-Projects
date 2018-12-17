//
//  NewEateryTableViewController.swift
//  Eateries
//
//  Created by User on 06.07.18.
//  Copyright © 2018 User. All rights reserved.
//

import UIKit
import CloudKit

class NewEateryTableViewController: UITableViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    
    @IBOutlet weak var typeTextField: UITextField!
    @IBOutlet weak var adressTextField: UITextField!
    @IBOutlet weak var nameTextField: UITextField!
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var yesButton: UIButton!
    @IBOutlet weak var noButton: UIButton!
    var isVisited = false
    
    
    @IBAction func toggleIsVisitedPressed(_ sender: UIButton) {
        if sender == yesButton {
            sender.backgroundColor = #colorLiteral(red: 0.3411764801, green: 0.6235294342, blue: 0.1686274558, alpha: 1)
            noButton.backgroundColor = #colorLiteral(red: 0.7233663201, green: 0.7233663201, blue: 0.7233663201, alpha: 1)
            isVisited = true
        } else {
            sender.backgroundColor = #colorLiteral(red: 0.9254902005, green: 0.2352941185, blue: 0.1019607857, alpha: 1)
            yesButton.backgroundColor = #colorLiteral(red: 0.7233663201, green: 0.7233663201, blue: 0.7233663201, alpha: 1)
            isVisited = false
        }
    }
    
    @IBAction func saveButtonPressed(_ sender: UIBarButtonItem) {
        if nameTextField.text == "" || adressTextField.text == "" || typeTextField.text == "" {
            let ac = UIAlertController(title: "Warning", message: "All fields must be filled!", preferredStyle: .alert)
            let alertAction = UIAlertAction(title: "Ok", style: .default, handler: nil)
            ac.addAction(alertAction)
            present(ac, animated: true, completion: nil)
        } else {
            
            if let context = (UIApplication.shared.delegate as? AppDelegate)?.coreDataStack.persistentContainer.viewContext {
                let restaurant = EateriesClass(context: context)
                restaurant.name = nameTextField.text
                restaurant.location = adressTextField.text
                restaurant.type = typeTextField.text
                restaurant.isVisited = isVisited
                if let image = imageView.image {
                    restaurant.image = UIImagePNGRepresentation(image) as NSData?
                }
                
                do {
                    try context.save()
                    print("Save is completed!")
                } catch let error as NSError {
                    print("Not possible to save data \(error), \(error.userInfo)")
                }
                
                //saveToCloud(restaurant)
            }
            
            // для выхода после save
            performSegue(withIdentifier: "unwindSegueFromNewEatery", sender: self)
        }
    }
    
    func saveToCloud(_ restaurant: EateriesClass) {
        
        // чтоб загрузить в iCloud представляем в виде Записи
        
        let restRecord = CKRecord(recordType: "EateriesClass")
        restRecord.setValue(nameTextField.text, forKey: "name")
        restRecord.setValue(typeTextField.text, forKey: "type")
        restRecord.setValue(adressTextField.text, forKey: "location")
        
        // делаем нужный нам размер для фото
        
        guard let originImage = UIImage(data: restaurant.image! as Data) else { return }
        let scale = originImage.size.width > 1080.0 ? 1080.0 / originImage.size.width : 1.0
        let scaledImage = UIImage(data: restaurant.image! as Data, scale: scale)
        let imageFilePath = NSTemporaryDirectory() + restaurant.name!
        let imageFileURl = URL(fileURLWithPath: imageFilePath)
        
        // преобразовуем чтоб сохранить в виде файла (jpeg)
        
        do {
            try UIImageJPEGRepresentation(scaledImage!, 0.7)?.write(to: imageFileURl, options: .atomic)
        } catch {
            print(error.localizedDescription)
        }
        
        // создаем ассет, сохраняем значение в список Записей, сохраняем Запись в publicDataBase
        
        let imageAsset = CKAsset(fileURL: imageFileURl)
        restRecord.setValue(imageAsset, forKey: "image")
        let publicDataBase = CKContainer.default().publicCloudDatabase
        publicDataBase.save(restRecord) { (record, error) in
            guard error == nil else {
                print(error!.localizedDescription)
                return
            }
            
            // удаляем файл чтоб он не занимал места
            
            do {
                try FileManager.default.removeItem(at: imageFileURl)
            } catch {
                print(error.localizedDescription)
            }
        }
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        yesButton.backgroundColor = #colorLiteral(red: 0.3411764801, green: 0.6235294342, blue: 0.1686274558, alpha: 1)
        noButton.backgroundColor = #colorLiteral(red: 0.7233663201, green: 0.7233663201, blue: 0.7233663201, alpha: 1)
        noButton.backgroundColor = #colorLiteral(red: 0.9254902005, green: 0.2352941185, blue: 0.1019607857, alpha: 1)
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        imageView.image = info[UIImagePickerControllerEditedImage] as? UIImage
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        dismiss(animated: true, completion: nil)
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        if indexPath.row == 0 {
            let alertController = UIAlertController(title: NSLocalizedString("Source photo", comment: "Source photo"), message: nil, preferredStyle: .actionSheet)
            let cameraAction = UIAlertAction(title: NSLocalizedString("Camera", comment: "Camera"), style: .default, handler: { (action) in
                
                self.chooseImagePickerAction(source: .camera)
            })
            let photoLibAction = UIAlertAction(title: NSLocalizedString("Photo", comment: "Photo"), style: .default, handler: { (action) in
                
                self.chooseImagePickerAction(source: .photoLibrary)
            })
            let cancelAction = UIAlertAction(title: NSLocalizedString("Cancel", comment: "Cancel"), style: .cancel, handler: nil)
            alertController.addAction(cameraAction)
            alertController.addAction(photoLibAction)
            alertController.addAction(cancelAction)
            self.present(alertController, animated: true, completion: nil)
            
        }
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    func chooseImagePickerAction(source: UIImagePickerControllerSourceType) {
        if UIImagePickerController.isSourceTypeAvailable(source){
            let imagePicker = UIImagePickerController()
            imagePicker.delegate = self
            imagePicker.allowsEditing = true
            imagePicker.sourceType = source
            self.present(imagePicker, animated: true, completion: nil)
        }
    }
    
    /*
     override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
     let cell = tableView.dequeueReusableCell(withIdentifier: "reuseIdentifier", for: indexPath)
     
     // Configure the cell...
     
     return cell
     }
     */
    
    /*
     // Override to support conditional editing of the table view.
     override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
     // Return false if you do not want the specified item to be editable.
     return true
     }
     */
    
    /*
     // Override to support editing the table view.
     override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
     if editingStyle == .delete {
     // Delete the row from the data source
     tableView.deleteRows(at: [indexPath], with: .fade)
     } else if editingStyle == .insert {
     // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
     }
     }
     */
    
    /*
     // Override to support rearranging the table view.
     override func tableView(_ tableView: UITableView, moveRowAt fromIndexPath: IndexPath, to: IndexPath) {
     
     }
     */
    
    /*
     // Override to support conditional rearranging of the table view.
     override func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
     // Return false if you do not want the item to be re-orderable.
     return true
     }
     */
    
    /*
     // MARK: - Navigation
     
     // In a storyboard-based application, you will often want to do a little preparation before navigation
     override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
     // Get the new view controller using segue.destinationViewController.
     // Pass the selected object to the new view controller.
     }
     */
    
}
