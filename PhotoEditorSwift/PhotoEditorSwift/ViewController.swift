//
//  ViewController.swift
//  PhotoEditorSwift
//
//  Created by 0xfeedface on 16/7/15.
//  Copyright © 2016年 0xfeedface. All rights reserved.
//

import UIKit

class ViewController: UIViewController, UIImagePickerControllerDelegate , UINavigationControllerDelegate {

    @IBOutlet weak var selectBtn: UIButton!
    let imageView = UIImageView()
    private var imageConstraints:[NSLayoutConstraint]?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        self.view.addSubview(imageView)
        
        imageView.translatesAutoresizingMaskIntoConstraints = false
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    //MARK: 选择图片来源
    @IBAction func selectPhoto(_ sender: UIButton) {
        let alert = UIAlertController(title: "选择图片来源", message: nil, preferredStyle: .actionSheet)
        let cameraAction = UIAlertAction(title: "相机", style: .default, handler: {
            action in
            alert.dismiss(animated: true, completion: nil)
            self.cameraGo(.camera)
        })
        let libraryAction = UIAlertAction(title: "相册", style: .default, handler: {
            action in
            alert.dismiss(animated: true, completion: nil)
            self.cameraGo(.photoLibrary)
        })
        
        let cancelAction = UIAlertAction(title: "取消", style: .cancel, handler: {
            action in
            alert.dismiss(animated: true, completion: nil)
        })
        alert.addAction(libraryAction)
        alert.addAction(cameraAction)
        alert.addAction(cancelAction)
        self.present(alert, animated: true, completion: nil)
    }
    
    func cameraGo(_ sourceType : UIImagePickerControllerSourceType) -> Void {
        if UIImagePickerController.isSourceTypeAvailable(sourceType) {
            let imagePicker = UIImagePickerController()
            imagePicker.delegate = self
            imagePicker.allowsEditing = true
            imagePicker.sourceType = sourceType
            self.present(imagePicker, animated: true, completion: nil)
        }   else {
            let alert = UIAlertController(title: "设备不支持", message: nil, preferredStyle: .alert)
            let cancelAction = UIAlertAction(title: "好的", style: .default, handler: {
                action in
                alert.dismiss(animated: true, completion: nil)
            })
            alert.addAction(cancelAction)
            present(alert, animated: true, completion: nil)
        }
    }
    
    //MARK: UIImagePickerViewDelegate
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        let theImage:UIImage!
        if picker.allowsEditing {
            theImage = info[UIImagePickerControllerEditedImage] as! UIImage
        }   else {
            theImage = info[UIImagePickerControllerOriginalImage] as! UIImage
        }
        picker.dismiss(animated: false, completion: nil)
        
        if let drawView = DrawCoreViewController(image: theImage, clourse: loadImage) {
            self.present(drawView, animated: true, completion: nil)
        }
    }
    
    //MARK: Closure
    func loadImage(_ image: UIImage) -> Void {
        imageView.image = image;
        if let constraints = imageConstraints {
            view.removeConstraints(constraints)
        }
        imageConstraints = caculateConstraints(image: image)
        view.addConstraints(imageConstraints!)
    }
    
    //计算约束
    private func caculateConstraints(image: UIImage) -> [NSLayoutConstraint] {
        let (width, height) = factor(imageSize: image.size, viewSize: CGSize(width: view.frame.size.width, height: view.frame.size.height - 163 ))
        
        return NSLayoutConstraint.constraints(withVisualFormat: "V:|->=20-[image(==height)]-20-[btn]", options: .alignAllCenterX, metrics: ["height":height], views: ["image":imageView, "btn":selectBtn]) +
               NSLayoutConstraint.constraints(withVisualFormat: "H:[image(==width)]", options: [], metrics: ["width":width], views: ["image":imageView])
    }
    
    //根据面积大小比较获得图片的大小
    private func factor(imageSize: CGSize, viewSize: CGSize) -> (CGFloat, CGFloat) {
        var tmp:CGFloat = 1.0
        let tmpViewWidth = viewSize.width
        let tmpViewHeight = viewSize.height
        while true {
            let tmpImageWidth = imageSize.width * tmp
            let tmpImageHeight = imageSize.height * tmp
            if tmpImageWidth * tmpImageHeight <= tmpViewWidth * tmpViewHeight {
                return (tmpImageWidth, tmpImageHeight)
            }
            tmp *= 0.9
        }
    }
}

