//
//  DrawCoreViewController.swift
//  PhotoEditorSwift
//
//  Created by virus1993 on 16/7/16.
//  Copyright © 2016年 0xfeedface. All rights reserved.
//

import UIKit

typealias Clourse = (UIImage) -> Void

class DrawCoreViewController: UIViewController {
    
    //图形类型
    enum DrawRectType {
        case radio
        case cub
        case text
    }
    
    //图层
    enum DrawViewType {
        case raw
        case draw
        case middle
    }
    
    ///绘图路径
    struct DrawPath {
        let rect:CGRect
        let type:DrawRectType
        let red:CGFloat
        let green:CGFloat
        let blue:CGFloat
        let alpha:CGFloat
        init(rect : CGRect, type : DrawRectType,red : CGFloat,green : CGFloat,blue : CGFloat,alpha : CGFloat) {
            self.rect = rect
            self.type = type
            self.red = red
            self.green = green
            self.blue = blue
            self.alpha = alpha
        }
    }
    
    let DrawViewTagStart:UInt = 100
    var viewTagValue:UInt = UInt()
    var selectedImage:UIImageView = UIImageView()
    var drawView:UIImageView = UIImageView()
    var oneTimeView:UIImageView = UIImageView()
    var startPoint:CGPoint = CGPoint()
    var endPoint:CGPoint = CGPoint()
    var movePoint:CGPoint = CGPoint()
    var rectType = DrawRectType.radio

    var originImage:UIImage = UIImage()
    var paths:[DrawPath] = [DrawPath]()
    var text = ""
    let colors:[String : UIColor] = ["红色":UIColor.red,"黄色":UIColor.yellow,"蓝色":UIColor.blue,"绿色":UIColor.green,"青色":UIColor.gray,"紫色":UIColor.purple,"橙色":UIColor.orange,"黑色":UIColor.black,"白色":UIColor.white]
    var color:UIColor = UIColor()
    
    var backClourse: Clourse?

    init?(image : UIImage, clourse : @escaping Clourse) {
        super.init(nibName: nil, bundle: nil)
        backClourse = clourse
        originImage = image
        color = colors[Array(colors.keys)[0]]!
        viewTagValue = DrawViewTagStart
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor.black
        
        let width = originImage.size.width > view.frame.size.width ? view.frame.size.width : originImage.size.width
        let height = originImage.size.height * width / originImage.size.width
        
        selectedImage.frame = CGRect(x: 0, y: 64, width: width, height: height)
        selectedImage.image = originImage
        selectedImage.center = view.center
        view.addSubview(selectedImage)
        
        drawView.frame = selectedImage.frame
        drawView.image = UIImage()
        drawView.backgroundColor = UIColor.clear
        drawView.isUserInteractionEnabled = true
        drawView.layer.masksToBounds = true
        view.addSubview(drawView)
        
        oneTimeView = UIImageView()
        drawView.addSubview(oneTimeView)

        
        let leftBtn = UIButton(frame: CGRect(x: 5, y: 28, width: 100, height: 60))
        leftBtn.backgroundColor = UIColor.white
        leftBtn.setTitle("取消", for: UIControlState())
        leftBtn.setTitleColor(UIColor.blue, for: UIControlState())
        leftBtn.titleLabel?.font = UIFont.systemFont(ofSize: 18)
        leftBtn.layer.borderColor = UIColor.blue.cgColor
        leftBtn.layer.borderWidth = 1
        leftBtn.layer.cornerRadius = 4
        leftBtn.addTarget(self, action: #selector(self.goBack(_:)), for: .touchUpInside)
        view.addSubview(leftBtn)
        
        let rightBtn = UIButton(frame: CGRect(x: view.frame.size.width - 105, y: 28, width: 100, height: 60))
        rightBtn.backgroundColor = UIColor.white
        rightBtn.setTitle("完成", for: UIControlState())
        rightBtn.setTitleColor(UIColor.blue, for: UIControlState())
        rightBtn.titleLabel?.font = UIFont.systemFont(ofSize: 18)
        rightBtn.layer.borderColor = UIColor.blue.cgColor
        rightBtn.layer.borderWidth = 1
        rightBtn.layer.cornerRadius = 4
        rightBtn.addTarget(self, action: #selector(self.save(_:)), for: .touchUpInside)
        view.addSubview(rightBtn)
        
        let rollbackBtn = UIButton(frame: CGRect(x: leftBtn.frame.origin.x + leftBtn.frame.size.width + 5, y: leftBtn.frame.origin.y, width: view.frame.size.width - (leftBtn.frame.size.width + rightBtn.frame.size.width + 4 * 5), height: leftBtn.frame.size.height))
        rollbackBtn.backgroundColor = UIColor.white
        rollbackBtn.setTitle("撤销", for: UIControlState())
        rollbackBtn.setTitleColor(UIColor.blue, for: UIControlState())
        rollbackBtn.titleLabel?.font = UIFont.systemFont(ofSize: 18)
        rollbackBtn.layer.borderColor = UIColor.blue.cgColor
        rollbackBtn.layer.borderWidth = 1
        rollbackBtn.layer.cornerRadius = 4
        rollbackBtn.addTarget(self, action: #selector(self.rollback(_:)), for: .touchUpInside)
        view.addSubview(rollbackBtn)
        
        let upBtn = UIButton(frame: CGRect(x: 5, y: view.frame.size.height - 65, width: 100, height: 60))
        upBtn.backgroundColor = UIColor.white
        upBtn.setTitle("椭圆", for: UIControlState())
        upBtn.setTitleColor(UIColor.blue, for: UIControlState())
        upBtn.titleLabel?.font = UIFont.systemFont(ofSize: 18)
        upBtn.layer.borderColor = UIColor.blue.cgColor
        upBtn.layer.borderWidth = 1
        upBtn.layer.cornerRadius = 4
        upBtn.addTarget(self, action: #selector(self.shap(_:)), for: .touchUpInside)
        view.addSubview(upBtn)
        
        let downBtn = UIButton(frame: CGRect(x: view.frame.size.width - 105, y: view.frame.size.height - 65, width: 100, height: 60))
        downBtn.backgroundColor = UIColor.white
        downBtn.setTitle(Array(colors.keys)[0], for: UIControlState())
        downBtn.setTitleColor(UIColor.blue, for: UIControlState())
        downBtn.titleLabel?.font = UIFont.systemFont(ofSize: 18)
        downBtn.layer.borderColor = UIColor.blue.cgColor
        downBtn.layer.borderWidth = 1
        downBtn.layer.cornerRadius = 4
        downBtn.addTarget(self, action: #selector(self.colorChange(_:)), for: .touchUpInside)
        view.addSubview(downBtn)
    }
    
    //MARK: 返回
    @objc fileprivate func goBack(_ button : UIButton) {
        self.dismiss(animated: true, completion: nil)
    }
    
    //MARK: 保存
    @objc fileprivate func save(_ button : UIButton) {
        let alert = UIAlertView(title: "请稍等", message: "在载入图片", delegate: nil, cancelButtonTitle: nil)
        alert.show()
        drawRawView()
        if backClourse != nil {
            backClourse!(originImage)
        }
        alert.dismiss(withClickedButtonIndex: 0, animated: true)
        goBack(button)
    }
    
    //MARK: 撤销
    @objc fileprivate func rollback(_ button : UIButton) {
        if viewTagValue > DrawViewTagStart {
            guard let imageView = drawView.viewWithTag(Int(viewTagValue - 1)) as? UIImageView else {
                return
            }
            imageView.removeFromSuperview()
            paths.remove(at: paths.count - 1)
            viewTagValue -= 1
        }
    }
    
    //MARK: 形状
    @objc fileprivate func shap(_ button : UIButton) {
        let alert = UIAlertController(title: "请选择图形", message: nil, preferredStyle: .actionSheet)
        let camaraAction = UIAlertAction(title: "椭圆", style: .default, handler: {
            action in
            self.rectType = .radio
            button.setTitle("椭圆", for: UIControlState())
        })
        let libraryAction = UIAlertAction(title: "矩形", style: .default, handler: {
            action in
            self.rectType = .cub
            button.setTitle("矩形", for: UIControlState())
        })
        let textAction = UIAlertAction(title: "文字", style: .default, handler: {
            action in
            self.rectType = .text
            button.setTitle("文字", for: UIControlState())
            self.addText(button)
        })
        
        let cancelAction = UIAlertAction(title: "取消", style: .cancel, handler: {
            action in
            alert.dismiss(animated: true, completion: nil)
        })
        
        alert.addAction(camaraAction)
        alert.addAction(libraryAction)
        alert.addAction(textAction)
        alert.addAction(cancelAction)
        self.present(alert, animated: true, completion: nil)
    }
    
    //MARK: 颜色改变
    @objc fileprivate func colorChange(_ button : UIButton) {
        let alert = UIAlertController(title: "请选择颜色", message: nil, preferredStyle: .actionSheet)
        for (key, value) in colors {
            let action = UIAlertAction(title: key, style: .default, handler: {
                action in
                self.color = value
                button.setTitle(key, for: UIControlState())
            })
            alert.addAction(action)
        }
        self.present(alert, animated: true, completion: nil)
    }
    
    //MARK: 添加文字
    fileprivate func addText(_ button : UIButton) {
        let alert = UIAlertController(title: "请输入文字", message: nil, preferredStyle: .alert)
        alert.addTextField(configurationHandler: {
            textField in
            textField.placeholder = "填写文字"
        })
        
        let okAction = UIAlertAction(title: "OK", style: .default, handler: {
            action in
            if let textFields = alert.textFields {
                if let text = textFields[0].text, text != "" {
                    self.text = text
                }
            }
            self.rectType = .text
            alert.dismiss(animated: true, completion: nil)
        })
        
        let cancelAction = UIAlertAction(title: "取消", style: .cancel, handler: {
            action in
            alert.dismiss(animated: true, completion: nil)
        })
        
        alert.addAction(okAction)
        alert.addAction(cancelAction)
        self.present(alert, animated: true, completion: nil)
    }
    
    //MARK: 触摸事件
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        let touch = touches.first
        if let imageView = touch?.view as? UIImageView, imageView == drawView {
            startPoint = (touch?.location(in: imageView))!
        }
    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        let touch = touches.first
        if let imageView = touch?.view as? UIImageView, imageView == drawView {
            movePoint = (touch?.location(in: imageView))!
            DispatchQueue.global(priority: DispatchQueue.GlobalQueuePriority.default).async(execute: {
                DispatchQueue.main.async(execute: {
                    self.drawNewWay(.draw, rectType: self.rectType, color: self.color)
                })
            })
        }
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        let touch = touches.first
        if let imageView = touch?.view as? UIImageView, imageView == drawView {
            endPoint = (touch?.location(in: imageView))!
            DispatchQueue.global(priority: DispatchQueue.GlobalQueuePriority.default).async(execute: {
                DispatchQueue.main.async(execute: {
                    self.drawNewWay(.middle, rectType: self.rectType, color: self.color)
                })
            })
        }
    }
    
    //MARK: 测试新绘图方法
    fileprivate func drawNewWay(_ viewType : DrawViewType, rectType : DrawRectType, color : UIColor) {
        var finishedPoint:CGPoint = CGPoint.zero
        var tmpView:UIImageView = UIImageView()
        var rect:CGRect = CGRect.zero
        
        switch viewType {
        case .draw:
            finishedPoint = movePoint
            tmpView = oneTimeView
        case .middle:
            finishedPoint = endPoint
            oneTimeView.image = nil
            drawView.insertSubview(tmpView, belowSubview: oneTimeView)
        default:
            break
        }
        
        rect.origin = CGPoint(x: finishedPoint.x > startPoint.x ? startPoint.x:finishedPoint.x, y: finishedPoint.y > startPoint.y ? startPoint.y:finishedPoint.y)
        rect.size = CGSize(width: fabs(finishedPoint.x - startPoint.x), height: fabs(finishedPoint.y - startPoint.y))
        tmpView.frame = rect
        
        //开始绘制
        UIGraphicsBeginImageContextWithOptions(rect.size, false, 0.0);
        //绘图上下文获取失败则跳转
        guard let context = UIGraphicsGetCurrentContext() else {
            UIGraphicsEndImageContext();
            return
        }
        
        context.setStrokeColor(color.cgColor);
        context.setLineWidth(2.5);
        
        drawShap(rectType, context: context, rect: CGRect(x: 2.5, y: 2.5, width: rect.size.width - 5, height: rect.size.height - 5), adjustFont: false, color: color)
        
        //渲染
        context.drawPath(using: .stroke);
        
        tmpView.image = UIGraphicsGetImageFromCurrentImageContext();
        
        //手指绘图结束则纪录该绘图信息
        if .middle == viewType {
            var red:CGFloat = CGFloat()
            var green:CGFloat = CGFloat()
            var blue:CGFloat = CGFloat()
            var alpha:CGFloat = CGFloat()
            
            color.getRed(&red, green: &green, blue: &blue, alpha: &alpha)
            let path = DrawPath(rect: rect, type: rectType, red: red, green: green, blue: blue, alpha: alpha)
            paths.append(path)
            tmpView.tag = Int(viewTagValue);
            viewTagValue += 1
        }
        
        UIGraphicsEndImageContext();

    }
    
    //MARK: 绘制形状
    
    fileprivate func drawShap(_ type : DrawRectType, context : CGContext, rect : CGRect, adjustFont : Bool, color : UIColor) {
        switch type {
        case .radio:
            context.addEllipse(in: rect) //椭圆
        case .cub:
            context.addRect(rect) //矩形
        case .text:
            drawText(rect, adjustFont: adjustFont, color: color)
        }
    }
    
    //MARK: 绘制文字
    fileprivate func drawText(_ rect : CGRect, adjustFont : Bool, color : UIColor) {
        let fontDescriptor = UIFontDescriptor.preferredFontDescriptor(withTextStyle: UIFontTextStyle.body)
        let boldFontDescriptor = fontDescriptor.withSymbolicTraits(.traitBold)
        let font = UIFont(descriptor: boldFontDescriptor!, size: adjustFont ? 16.0 * selectedImage.image!.size.width / view.frame.size.width:16)
        let paragraphStyle = NSParagraphStyle.default.mutableCopy() as! NSMutableParagraphStyle
        paragraphStyle.lineBreakMode = .byCharWrapping
        paragraphStyle.alignment = .center
        let attributes = [NSForegroundColorAttributeName:color,//设置文字颜色
            NSFontAttributeName:font,//设置文字的字体
            NSKernAttributeName:0,//文字之间的字距
        NSParagraphStyleAttributeName:paragraphStyle//设置文字的样式
        ] as [String : Any]
        let newText = text as NSString
        let szieNewText = newText.boundingRect(with: rect.size, options: .usesLineFragmentOrigin, attributes: attributes, context: nil).size
        let newRect = CGRect(x: rect.origin.x, y: rect.origin.y, width: szieNewText.width, height: szieNewText.height)
        newText.draw(in: newRect, withAttributes: attributes)
    }
    
    //MARK: 绘制背景
    fileprivate func drawRawView() {
        var rect:CGRect = CGRect.zero
        //开始绘制
        UIGraphicsBeginImageContextWithOptions(originImage.size, false, 0.0);
        //绘图上下文获取失败则跳转
        guard let context = UIGraphicsGetCurrentContext() else {
            UIGraphicsEndImageContext();
            return
        }
        
        originImage.draw(in: CGRect(x: 0, y: 0, width: originImage.size.width, height: originImage.size.height))
        context.setLineWidth(2.5 * fabs(originImage.size.width / drawView.frame.size.width))
        
        for path in paths {
            context.setStrokeColor(UIColor(red: path.red, green: path.green, blue: path.blue, alpha: path.alpha).cgColor);
            //转换遮罩层上的大小，对应背景层的大小
            rect.origin.x = path.rect.origin.x / drawView.frame.size.width * originImage.size.width;
            rect.origin.y = path.rect.origin.y / drawView.frame.size.height * originImage.size.height;
            rect.size.width = path.rect.size.width / drawView.frame.size.width * originImage.size.width;
            rect.size.height = path.rect.size.height / drawView.frame.size.height * originImage.size.height;
            drawShap(path.type, context: context, rect: rect, adjustFont: true, color: UIColor(red: path.red, green: path.green, blue: path.blue, alpha: path.alpha))
            //渲染
            context.drawPath(using: .stroke);
        }
        
        originImage = UIGraphicsGetImageFromCurrentImageContext()!;
        
        UIGraphicsEndImageContext();

    }
}
