//
//  HQNavigationController.swift
//  MySwiftProgram
//
//  Created by 李海权 on 2016/11/7.
//  Copyright © 2016年 李海权. All rights reserved.
//

import UIKit

func ColorFromRGB(rgbValue:NSInteger) ->UIColor{
    return UIColor.init(colorLiteralRed: ((Float)((rgbValue & 0xFF0000) >> 16))/255.0, green:((Float)((rgbValue & 0xFF00) >> 8))/255.0 , blue: ((Float)(rgbValue & 0xFF))/255.0, alpha: 1.0);
}

let kTargetTranslateScale:CGFloat = 0.75
let kDefaultAlpha:CGFloat = 0.6

class HQNavigationController: UINavigationController ,UINavigationControllerDelegate,UIGestureRecognizerDelegate {

    var screenshotImgView:UIImageView?;//swift的问号 相当于  var screenshotImgView:Optional<UIImageView>
    var coverView:UIView?;
    var screenshotImages:NSMutableArray?;
    var nextVCScreenShotImg:UIImage?;
    lazy  var animationController:HQAnimationController = { return HQAnimationController.init()}()
    var panGestureRec:UIScreenEdgePanGestureRecognizer?;
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.delegate = self;
        self.navigationBar.tintColor = ColorFromRGB(rgbValue: 0x6F7179);
        self.view.layer.shadowColor = UIColor.black.cgColor;
        self.view.layer.shadowOffset = CGSize.init(width: -0.8, height: 0);
        self.view.layer.shadowOpacity = 0.6;
        //监听将要取消活跃时的状态
        NotificationCenter.default.addObserver(self, selector:#selector(applicationWillResignActive) , name: NSNotification.Name.UIApplicationWillResignActive, object: nil)
        //初始化手势
       self.panGestureRec = UIScreenEdgePanGestureRecognizer.init(target: self, action: #selector(panGestureRec( ges:)))
       self.panGestureRec?.edges = UIRectEdge.left ;
        panGestureRec?.maximumNumberOfTouches = 1;
        self.view.addGestureRecognizer(panGestureRec!);
        
        //创建截图的ImageView
        self.screenshotImgView = UIImageView.init()
        self.screenshotImgView?.frame = CGRect.init(x: 0, y: 0, width: UIScreen.main.bounds.size.width, height: UIScreen.main.bounds.size.height)
        
        //创建截图上面的黑色半透明遮罩
        self.coverView  = UIView.init()
        self.coverView?.frame = CGRect.init(x: 0, y: 0, width: UIScreen.main.bounds.size.width, height: UIScreen.main.bounds.size.height)
        self.coverView?.backgroundColor = UIColor.black;
        
        //初始化所有截图的数组
        screenshotImages = NSMutableArray.init()
        
    }
    

    
   func navigationController(_ navigationController: UINavigationController, animationControllerFor operation: UINavigationControllerOperation, from fromVC: UIViewController, to toVC: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        self.animationController.navigationOperation = operation;
        self.animationController.navigationController = self;
        return self.animationController;
    }
    
  
    
    func applicationWillResignActive() -> Void {
        self.dragEnd()
    }

    func panGestureRec(ges panGest:UIScreenEdgePanGestureRecognizer) -> Void {
        //边沿平移手势
        //如果当前显示的控制器已经是根视图控制器了，不需要任何切换动画，直接返回
        if self.visibleViewController == self.viewControllers[0] {return}
        //判断手势的各个阶段
        switch panGest.state {
        case UIGestureRecognizerState.began:
            self.dragBegin()
        break
        
        case UIGestureRecognizerState.ended:
           self.dragEnd()
        break
            
        default:
            self.draging(panGest)
            
        break
            
        }
        
    }
    
    //开始拖拽
    func dragBegin()->Void
    {
        self.view.isUserInteractionEnabled = false
        self.view.window?.insertSubview(self.screenshotImgView!, at: 0)
        self.view.window?.insertSubview(self.coverView!, aboveSubview: self.screenshotImgView!)
        self.screenshotImgView?.image = self.screenshotImages?.lastObject as! UIImage?
        
    }
    
    func dragEnd() -> Void {
        self.view.isUserInteractionEnabled = true
        let translateX = self.view.transform.tx
        let width = self.view.frame.size.width
        
        if translateX <= 40 {
            //如果手指移动距离很小，左边弹回
            UIView.animate(withDuration: 0.3, animations: {()->Void in
              //让被移动的View归位
                self.view.transform = CGAffineTransform.identity
                //让imageView大小恢复
               self.screenshotImgView?.transform =  CGAffineTransform(translationX: -UIScreen.main.bounds.size.width, y: 0);
               self.coverView?.alpha = kDefaultAlpha
            }, completion: {(finish:Bool)->Void in
            
                self.coverView?.removeFromSuperview()
                self.screenshotImgView?.removeFromSuperview()
            })

        }else {
           //如果手移动的距离比较大
            
            UIView.animate(withDuration: 0.3, animations: {()->Void in
             self.view.transform = CGAffineTransform(translationX: width, y: 0);
             self.screenshotImgView?.transform =  CGAffineTransform(translationX: 0, y: 0);
             self.coverView?.alpha = 0.0
         }, completion: {(finish:Bool)->Void in
            self.view.transform = CGAffineTransform.identity
            self.screenshotImgView?.removeFromSuperview()
            self.coverView?.removeFromSuperview()
            let _ =  self.popViewController(animated: false)
            self.animationController.removelastScreenShot()
        })
        
        }

    }
    

    func draging(_ pan:UIPanGestureRecognizer) -> Void {
        let offsetX = pan.translation(in: self.view).x
        print(offsetX)
        if offsetX > 0 {
          self.view.transform =   CGAffineTransform(translationX: offsetX, y: 0)
        }
        
        let  currentTranslateScaleX:CGFloat = offsetX/self.view.frame.size.width
        if offsetX < UIScreen.main.bounds.size.width {
            self.screenshotImgView?.transform = CGAffineTransform(translationX: (offsetX - UIScreen.main.bounds.size.width) * 0.6, y: 0);
        }
        
        let alpha = kDefaultAlpha - (currentTranslateScaleX / kTargetTranslateScale)*kDefaultAlpha
        self.coverView?.alpha = alpha
        
    }
    
    
    //使用上下文，并且使用指定的区域剪裁，
    func screenShotA()->Void
    {
      //获取要剪裁的控制器视图，必须不含状态栏
        let beyondVC:UIViewController = (self.view.window?.rootViewController)!
        //背景图的总大小
        let size:CGSize  = beyondVC.view.bounds.size
        //开启上下文，使用参数之后截图是原图（YES ，0.0，质量比较高）
        UIGraphicsBeginImageContextWithOptions(size, true, 0.0)
        //需要剪裁的矩形范围
        
        
        let rect:CGRect = CGRect.init(x: 0, y: 0, width: UIScreen.main.bounds.size.width, height: UIScreen.main.bounds.size.height)
        beyondVC.view.drawHierarchy(in: rect, afterScreenUpdates: false)
        
        beyondVC.view.drawHierarchy(in: rect, afterScreenUpdates: false)
        
        let imageShot = UIGraphicsGetImageFromCurrentImageContext()!
    
          self.screenshotImages!.add(imageShot)
        
        UIGraphicsEndImageContext()
        
    }
    
    //重写Push方法
    override func pushViewController(_ viewController: UIViewController, animated: Bool) {
        //只有在导航控制器里面有子控制器的时候才需要截图
        if self.viewControllers.count >= 1 {
            //调用截图
            self.screenShotA()
        }
        viewController.hidesBottomBarWhenPushed = true
        super.pushViewController(viewController, animated: animated)
    }
    
    //重写pop方法
    override func popViewController(animated: Bool) -> UIViewController? {
       
        let index:NSInteger = self.viewControllers.count
   
        //如果数组里的个数要比xontroller的总数相同或者多，pop时就移除
        if (self.screenshotImages?.count)! >= index-1 {
            self.screenshotImages?.removeLastObject()
        }
        return super.popViewController(animated: animated)
    }
    
    override func popToViewController(_ viewController: UIViewController, animated: Bool) -> [UIViewController]? {
        
        var removeCount:NSInteger  = 0
        for i in 0 ... self.viewControllers.count - 1 {
            if viewController == self.viewControllers[i] {
                break
            }
            self.screenshotImages?.removeLastObject()
            removeCount  += 1
        }
        
        self.animationController.removeCount = removeCount
        
        return super.popToViewController(viewController, animated: animated)
    }
    
    override func popToRootViewController(animated: Bool) -> [UIViewController]? {
        self.screenshotImages?.removeAllObjects()
        self.animationController.removeAllScreenShot()
        
        return super.popToRootViewController(animated: animated)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        if self.isViewLoaded && (self.view.window == nil) {
             self.view = nil
        }
        // Dispose of any resources that can be recreated.
    }
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
