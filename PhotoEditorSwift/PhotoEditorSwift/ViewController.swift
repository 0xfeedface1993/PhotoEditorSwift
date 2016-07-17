//
//  ViewController.swift
//  PhotoEditorSwift
//
//  Created by 0xfeedface on 16/7/15.
//  Copyright © 2016年 0xfeedface. All rights reserved.
//

import UIKit

class ViewController: UIViewController, UIImagePickerControllerDelegate , UINavigationControllerDelegate {

    let imageView = UIImageView()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        self.view.addSubview(imageView)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    //MARK: 选择图片来源
    @IBAction func selectPhoto(sender: UIButton) {
        let alert = UIAlertController(title: "选择图片来源", message: nil, preferredStyle: .ActionSheet)
        let cameraAction = UIAlertAction(title: "相机", style: .Default, handler: {
            action in
            alert.dismissViewControllerAnimated(true, completion: nil)
            self.cameraGo(.Camera)
        })
        let libraryAction = UIAlertAction(title: "相册", style: .Default, handler: {
            action in
            alert.dismissViewControllerAnimated(true, completion: nil)
            self.cameraGo(.PhotoLibrary)
        })
        
        let cancelAction = UIAlertAction(title: "取消", style: .Cancel, handler: {
            action in
            alert.dismissViewControllerAnimated(true, completion: nil)
        })
        alert.addAction(libraryAction)
        alert.addAction(cameraAction)
        alert.addAction(cancelAction)
        self.presentViewController(alert, animated: true, completion: nil)
    }
    
    func cameraGo(sourceType : UIImagePickerControllerSourceType) -> Void {
        if UIImagePickerController.isSourceTypeAvailable(sourceType) {
            let imagePicker = UIImagePickerController()
            imagePicker.delegate = self
            imagePicker.allowsEditing = true
            imagePicker.sourceType = sourceType
            self.presentViewController(imagePicker, animated: true, completion: nil)
        }   else {
            let alert = UIAlertController(title: "设备不支持", message: nil, preferredStyle: .Alert)
            let cancelAction = UIAlertAction(title: "好的", style: .Default, handler: {
                action in
                alert.dismissViewControllerAnimated(true, completion: nil)
            })
            alert.addAction(cancelAction)
            presentViewController(alert, animated: true, completion: nil)
        }
    }
    
    //MARK: UIImagePickerViewDelegate
    func imagePickerController(picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : AnyObject]) {
        let theImage:UIImage!
        if picker.allowsEditing {
            theImage = info[UIImagePickerControllerEditedImage] as! UIImage
        }   else {
            theImage = info[UIImagePickerControllerOriginalImage] as! UIImage
        }
        picker.dismissViewControllerAnimated(false, completion: nil)
        
        if let drawView = DrawCoreViewController(image: theImage, clourse: loadImage) {
            self.presentViewController(drawView, animated: true, completion: nil)
        }
    }
    
    //MARK: Closure
    func loadImage(image: UIImage) -> Void {
        imageView.frame = CGRectMake(0, 0, image.size.width > view.frame.size.width ? view.frame.size.width:image.size.width, (image.size.width > view.frame.size.width ? view.frame.size.width:image.size.width) * image.size.height / image.size.width);
        imageView.image = image;
        imageView.center = view.center;
    }
}

