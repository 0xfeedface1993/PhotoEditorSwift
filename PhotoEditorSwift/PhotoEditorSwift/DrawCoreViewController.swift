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
        case Radio
        case Cub
        case Text
    }
    
    //图层
    enum DrawViewType {
        case Raw
        case Draw
        case Middle
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
    var rectType = DrawRectType.Radio

    var originImage:UIImage = UIImage()
    var paths:[DrawPath] = [DrawPath]()
    var text = ""
    let colors:[String : UIColor] = ["红色":UIColor.redColor(),"黄色":UIColor.yellowColor(),"蓝色":UIColor.blueColor(),"绿色":UIColor.greenColor(),"青色":UIColor.grayColor(),"紫色":UIColor.purpleColor(),"橙色":UIColor.orangeColor(),"黑色":UIColor.blackColor(),"白色":UIColor.whiteColor()]
    var color:UIColor = UIColor()
    
    var backClourse: Clourse?

    init?(image : UIImage, clourse : Clourse) {
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
        view.backgroundColor = UIColor.blackColor()
        
        let width = originImage.size.width > view.frame.size.width ? view.frame.size.width : originImage.size.width
        let height = originImage.size.height * width / originImage.size.width
        
        selectedImage.frame = CGRect(x: 0, y: 64, width: width, height: height)
        selectedImage.image = originImage
        selectedImage.center = view.center
        view.addSubview(selectedImage)
        
        drawView.frame = selectedImage.frame
        drawView.image = UIImage()
        drawView.backgroundColor = UIColor.clearColor()
        drawView.userInteractionEnabled = true
        drawView.layer.masksToBounds = true
        view.addSubview(drawView)
        
        oneTimeView = UIImageView()
        drawView.addSubview(oneTimeView)

        
        let leftBtn = UIButton(frame: CGRect(x: 5, y: 28, width: 100, height: 60))
        leftBtn.backgroundColor = UIColor.whiteColor()
        leftBtn.setTitle("取消", forState: .Normal)
        leftBtn.setTitleColor(UIColor.blueColor(), forState: .Normal)
        leftBtn.titleLabel?.font = UIFont.systemFontOfSize(18)
        leftBtn.layer.borderColor = UIColor.blueColor().CGColor
        leftBtn.layer.borderWidth = 1
        leftBtn.layer.cornerRadius = 4
        leftBtn.addTarget(self, action: #selector(self.goBack(_:)), forControlEvents: .TouchUpInside)
        view.addSubview(leftBtn)
        
        let rightBtn = UIButton(frame: CGRect(x: view.frame.size.width - 105, y: 28, width: 100, height: 60))
        rightBtn.backgroundColor = UIColor.whiteColor()
        rightBtn.setTitle("完成", forState: .Normal)
        rightBtn.setTitleColor(UIColor.blueColor(), forState: .Normal)
        rightBtn.titleLabel?.font = UIFont.systemFontOfSize(18)
        rightBtn.layer.borderColor = UIColor.blueColor().CGColor
        rightBtn.layer.borderWidth = 1
        rightBtn.layer.cornerRadius = 4
        rightBtn.addTarget(self, action: #selector(self.save(_:)), forControlEvents: .TouchUpInside)
        view.addSubview(rightBtn)
        
        let rollbackBtn = UIButton(frame: CGRect(x: leftBtn.frame.origin.x + leftBtn.frame.size.width + 5, y: leftBtn.frame.origin.y, width: view.frame.size.width - (leftBtn.frame.size.width + rightBtn.frame.size.width + 4 * 5), height: leftBtn.frame.size.height))
        rollbackBtn.backgroundColor = UIColor.whiteColor()
        rollbackBtn.setTitle("撤销", forState: .Normal)
        rollbackBtn.setTitleColor(UIColor.blueColor(), forState: .Normal)
        rollbackBtn.titleLabel?.font = UIFont.systemFontOfSize(18)
        rollbackBtn.layer.borderColor = UIColor.blueColor().CGColor
        rollbackBtn.layer.borderWidth = 1
        rollbackBtn.layer.cornerRadius = 4
        rollbackBtn.addTarget(self, action: #selector(self.rollback(_:)), forControlEvents: .TouchUpInside)
        view.addSubview(rollbackBtn)
        
        let upBtn = UIButton(frame: CGRect(x: 5, y: view.frame.size.height - 65, width: 100, height: 60))
        upBtn.backgroundColor = UIColor.whiteColor()
        upBtn.setTitle("椭圆", forState: .Normal)
        upBtn.setTitleColor(UIColor.blueColor(), forState: .Normal)
        upBtn.titleLabel?.font = UIFont.systemFontOfSize(18)
        upBtn.layer.borderColor = UIColor.blueColor().CGColor
        upBtn.layer.borderWidth = 1
        upBtn.layer.cornerRadius = 4
        upBtn.addTarget(self, action: #selector(self.shap(_:)), forControlEvents: .TouchUpInside)
        view.addSubview(upBtn)
        
        let downBtn = UIButton(frame: CGRect(x: view.frame.size.width - 105, y: view.frame.size.height - 65, width: 100, height: 60))
        downBtn.backgroundColor = UIColor.whiteColor()
        downBtn.setTitle(Array(colors.keys)[0], forState: .Normal)
        downBtn.setTitleColor(UIColor.blueColor(), forState: .Normal)
        downBtn.titleLabel?.font = UIFont.systemFontOfSize(18)
        downBtn.layer.borderColor = UIColor.blueColor().CGColor
        downBtn.layer.borderWidth = 1
        downBtn.layer.cornerRadius = 4
        downBtn.addTarget(self, action: #selector(self.colorChange(_:)), forControlEvents: .TouchUpInside)
        view.addSubview(downBtn)
    }
    
    //MARK: 返回
    @objc private func goBack(button : UIButton) {
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    //MARK: 保存
    @objc private func save(button : UIButton) {
        let alert = UIAlertView(title: "请稍等", message: "在载入图片", delegate: nil, cancelButtonTitle: nil)
        alert.show()
        drawRawView()
        if backClourse != nil {
            backClourse!(originImage)
        }
        alert.dismissWithClickedButtonIndex(0, animated: true)
        goBack(button)
    }
    
    //MARK: 撤销
    @objc private func rollback(button : UIButton) {
        if viewTagValue > DrawViewTagStart {
            guard let imageView = drawView.viewWithTag(Int(viewTagValue - 1)) as? UIImageView else {
                return
            }
            imageView.removeFromSuperview()
            paths.removeAtIndex(paths.count - 1)
            viewTagValue -= 1
        }
    }
    
    //MARK: 形状
    @objc private func shap(button : UIButton) {
        let alert = UIAlertController(title: "请选择图形", message: nil, preferredStyle: .ActionSheet)
        let camaraAction = UIAlertAction(title: "椭圆", style: .Default, handler: {
            action in
            self.rectType = .Radio
            button.setTitle("椭圆", forState: .Normal)
        })
        let libraryAction = UIAlertAction(title: "矩形", style: .Default, handler: {
            action in
            self.rectType = .Cub
            button.setTitle("矩形", forState: .Normal)
        })
        let textAction = UIAlertAction(title: "文字", style: .Default, handler: {
            action in
            self.rectType = .Text
            button.setTitle("文字", forState: .Normal)
            self.addText(button)
        })
        
        let cancelAction = UIAlertAction(title: "取消", style: .Cancel, handler: {
            action in
            alert.dismissViewControllerAnimated(true, completion: nil)
        })
        
        alert.addAction(camaraAction)
        alert.addAction(libraryAction)
        alert.addAction(textAction)
        alert.addAction(cancelAction)
        self.presentViewController(alert, animated: true, completion: nil)
    }
    
    //MARK: 颜色改变
    @objc private func colorChange(button : UIButton) {
        let alert = UIAlertController(title: "请选择颜色", message: nil, preferredStyle: .ActionSheet)
        for (key, value) in colors {
            let action = UIAlertAction(title: key, style: .Default, handler: {
                action in
                self.color = value
                button.setTitle(key, forState: .Normal)
            })
            alert.addAction(action)
        }
        self.presentViewController(alert, animated: true, completion: nil)
    }
    
    //MARK: 添加文字
    private func addText(button : UIButton) {
        let alert = UIAlertController(title: "请输入文字", message: nil, preferredStyle: .Alert)
        alert.addTextFieldWithConfigurationHandler({
            textField in
            textField.placeholder = "填写文字"
        })
        
        let okAction = UIAlertAction(title: "OK", style: .Default, handler: {
            action in
            if let textFields = alert.textFields {
                if let text = textFields[0].text where text != "" {
                    self.text = text
                }
            }
            self.rectType = .Text
            alert.dismissViewControllerAnimated(true, completion: nil)
        })
        
        let cancelAction = UIAlertAction(title: "取消", style: .Cancel, handler: {
            action in
            alert.dismissViewControllerAnimated(true, completion: nil)
        })
        
        alert.addAction(okAction)
        alert.addAction(cancelAction)
        self.presentViewController(alert, animated: true, completion: nil)
    }
    
    //MARK: 触摸事件
    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
        let touch = touches.first
        if let imageView = touch?.view as? UIImageView where imageView == drawView {
            startPoint = (touch?.locationInView(imageView))!
        }
    }
    
    override func touchesMoved(touches: Set<UITouch>, withEvent event: UIEvent?) {
        let touch = touches.first
        if let imageView = touch?.view as? UIImageView where imageView == drawView {
            movePoint = (touch?.locationInView(imageView))!
            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), {
                dispatch_async(dispatch_get_main_queue(), {
                    self.drawNewWay(.Draw, rectType: self.rectType, color: self.color)
                })
            })
        }
    }
    
    override func touchesEnded(touches: Set<UITouch>, withEvent event: UIEvent?) {
        let touch = touches.first
        if let imageView = touch?.view as? UIImageView where imageView == drawView {
            endPoint = (touch?.locationInView(imageView))!
            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), {
                dispatch_async(dispatch_get_main_queue(), {
                    self.drawNewWay(.Middle, rectType: self.rectType, color: self.color)
                })
            })
        }
    }
    
    //MARK: 测试新绘图方法
    private func drawNewWay(viewType : DrawViewType, rectType : DrawRectType, color : UIColor) {
        var finishedPoint:CGPoint = CGPointZero
        var tmpView:UIImageView = UIImageView()
        var rect:CGRect = CGRectZero
        
        switch viewType {
        case .Draw:
            finishedPoint = movePoint
            tmpView = oneTimeView
        case .Middle:
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
        
        CGContextSetStrokeColorWithColor(context, color.CGColor);
        CGContextSetLineWidth(context, 2.5);
        
        drawShap(rectType, context: context, rect: CGRect(x: 2.5, y: 2.5, width: rect.size.width - 5, height: rect.size.height - 5), adjustFont: false, color: color)
        
        //渲染
        CGContextDrawPath(context, .Stroke);
        
        tmpView.image = UIGraphicsGetImageFromCurrentImageContext();
        
        //手指绘图结束则纪录该绘图信息
        if .Middle == viewType {
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
    
    private func drawShap(type : DrawRectType, context : CGContextRef, rect : CGRect, adjustFont : Bool, color : UIColor) {
        switch type {
        case .Radio:
            CGContextAddEllipseInRect(context, rect) //椭圆
        case .Cub:
            CGContextAddRect(context, rect) //矩形
        case .Text:
            drawText(rect, adjustFont: adjustFont, color: color)
        }
    }
    
    //MARK: 绘制文字
    private func drawText(rect : CGRect, adjustFont : Bool, color : UIColor) {
        let fontDescriptor = UIFontDescriptor.preferredFontDescriptorWithTextStyle(UIFontTextStyleBody)
        let boldFontDescriptor = fontDescriptor.fontDescriptorWithSymbolicTraits(.TraitBold)
        let font = UIFont(descriptor: boldFontDescriptor, size: adjustFont ? 16.0 * selectedImage.image!.size.width / view.frame.size.width:16)
        let paragraphStyle = NSParagraphStyle.defaultParagraphStyle().mutableCopy() as! NSMutableParagraphStyle
        paragraphStyle.lineBreakMode = .ByCharWrapping
        paragraphStyle.alignment = .Center
        let attributes = [NSForegroundColorAttributeName:color,//设置文字颜色
            NSFontAttributeName:font,//设置文字的字体
            NSKernAttributeName:0,//文字之间的字距
        NSParagraphStyleAttributeName:paragraphStyle//设置文字的样式
        ]
        let newText = text as NSString
        let szieNewText = newText.boundingRectWithSize(rect.size, options: .UsesLineFragmentOrigin, attributes: attributes, context: nil).size
        let newRect = CGRect(x: rect.origin.x, y: rect.origin.y, width: szieNewText.width, height: szieNewText.height)
        newText.drawInRect(newRect, withAttributes: attributes)
    }
    
    //MARK: 绘制背景
    private func drawRawView() {
        var rect:CGRect = CGRectZero
        //开始绘制
        UIGraphicsBeginImageContextWithOptions(originImage.size, false, 0.0);
        //绘图上下文获取失败则跳转
        guard let context = UIGraphicsGetCurrentContext() else {
            UIGraphicsEndImageContext();
            return
        }
        
        originImage.drawInRect(CGRect(x: 0, y: 0, width: originImage.size.width, height: originImage.size.height))
        CGContextSetLineWidth(context, 2.5 * fabs(originImage.size.width / drawView.frame.size.width))
        
        for path in paths {
            CGContextSetStrokeColorWithColor(context, UIColor(red: path.red, green: path.green, blue: path.blue, alpha: path.alpha).CGColor);
            //转换遮罩层上的大小，对应背景层的大小
            rect.origin.x = path.rect.origin.x / drawView.frame.size.width * originImage.size.width;
            rect.origin.y = path.rect.origin.y / drawView.frame.size.height * originImage.size.height;
            rect.size.width = path.rect.size.width / drawView.frame.size.width * originImage.size.width;
            rect.size.height = path.rect.size.height / drawView.frame.size.height * originImage.size.height;
            drawShap(path.type, context: context, rect: rect, adjustFont: true, color: UIColor(red: path.red, green: path.green, blue: path.blue, alpha: path.alpha))
            //渲染
            CGContextDrawPath(context, .Stroke);
        }
        
        originImage = UIGraphicsGetImageFromCurrentImageContext();
        
        UIGraphicsEndImageContext();

    }
}
