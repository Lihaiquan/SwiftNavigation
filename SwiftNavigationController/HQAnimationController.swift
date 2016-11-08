//
//  HQAnimationController.swift
//  MySwiftProgram
//
//  Created by 李海权 on 2016/11/7.
//  Copyright © 2016年 李海权. All rights reserved.
//

import UIKit

class HQAnimationController: NSObject,UIViewControllerAnimatedTransitioning{
    
    var navigationOperation:UINavigationControllerOperation?
    var navigationController:UINavigationController?
    
    var removeCount:NSInteger = 0
    
    lazy var screenShotArray:NSMutableArray = {return NSMutableArray.init()}()
    
    
    func AnimationControllerWithOperation(_ operation:UINavigationControllerOperation) -> HQAnimationController {
        
        let  ac: HQAnimationController = HQAnimationController.init()
        ac.navigationOperation = operation
        return ac
    }
    
    func AnimationControllerWithOperation(_  operation:UINavigationControllerOperation,navigationController:UINavigationController) -> HQAnimationController {
        
        let  ac: HQAnimationController = HQAnimationController.init()
        ac.navigationOperation = operation
        ac.navigationController = navigationController
        return ac
    }
    
    
    func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval
    {
        return 0.35
    }
    
    func removelastScreenShot() -> Void {
        self.screenShotArray.removeLastObject()
    }
    
    func removeAllScreenShot() -> Void {
        self.screenShotArray.removeAllObjects()
    }
    
    func animateTransition(using transitionContext: UIViewControllerContextTransitioning) ->Void
    {
        //自定义转场动画
        var  baseView:UIView? = self.navigationController?.tabBarController?.view;
        if baseView==nil {
            baseView = self.navigationController?.view?.window
        }
        //创建ImageView
        let screenImageView :UIImageView  = UIImageView.init(frame: CGRect.init(x: 0, y: 0, width: UIScreen.main.bounds.size.width, height: UIScreen.main.bounds.size.height))
        let screenImg :UIImage = self.screenShot()
        screenImageView.image = screenImg
        
        //取出fromVC 和toVC
        let fromViewcontroller :UIViewController = transitionContext .viewController(forKey: UITransitionContextViewControllerKey.from)!
        let toViewController:UIViewController = transitionContext.viewController(forKey: UITransitionContextViewControllerKey.to)!
        let toView:UIView = transitionContext.view(forKey: UITransitionContextViewKey.to)!
        
        var fromViewEndFrame :CGRect = transitionContext.finalFrame(for: fromViewcontroller)
        fromViewEndFrame.origin.x = UIScreen.main.bounds.size.width
        var fromViewStartFrame = fromViewEndFrame
        
        let toViewEndFrame :CGRect = transitionContext.finalFrame(for: toViewController)
        let toViewStartFrame = toViewEndFrame
        
        let containerView = transitionContext.containerView
        
        if self.navigationOperation == UINavigationControllerOperation.push {
            self.screenShotArray.add(screenImg)
            //这句话非常重要，没有这句话。就无法正常Push 或Pop出对应的界面
            containerView.addSubview(toView)
            toView.frame = toViewStartFrame
            
            baseView?.insertSubview(screenImageView, at: 0)
            self.navigationController?.view.transform = CGAffineTransform.init(translationX: UIScreen.main.bounds.size.width, y: 0)
            
            
            UIView.animate(withDuration: self.transitionDuration(using: transitionContext), animations: {()->Void in
                self.navigationController?.view.transform =  CGAffineTransform(translationX: 0, y: 0);
                screenImageView.center = CGPoint.init(x: -UIScreen.main.bounds.size.width/2.0, y: UIScreen.main.bounds.size.height/2.0)
            }, completion: {(finish:Bool)->Void in
                screenImageView.removeFromSuperview()
                transitionContext.completeTransition(true)
            })
            
            
        }else if self.navigationOperation == UINavigationControllerOperation.pop {
            
            fromViewStartFrame.origin.x = 0
            containerView.addSubview(toView)
            
            let lastVCImageView :UIImageView = UIImageView.init(frame: CGRect.init(x: -UIScreen.main.bounds.size.width, y: 0, width: UIScreen.main.bounds.size.width, height: UIScreen.main.bounds.size.height))
            //若removeCount大于0 说明Pop不止一个控制器
            if self.removeCount > 0{
                for index in 0 ... self.removeCount{
                    if index == (self.removeCount - 1) {
                        lastVCImageView.image = self.screenShotArray.lastObject as! UIImage?
                    }else{
                        self.screenShotArray.removeLastObject()
                    }
                }
            }else{
                lastVCImageView.image = self.screenShotArray.lastObject as!UIImage?
            }
            
            screenImageView.layer.shadowColor = UIColor.black.cgColor
            screenImageView.layer.shadowOffset = CGSize.init(width: -0.8, height: 0)
            screenImageView.layer.shadowOpacity = 0.6
            baseView?.addSubview(lastVCImageView)
            baseView?.addSubview(screenImageView);
            
            UIView.animate(withDuration: self.transitionDuration(using: transitionContext), animations: {()->Void in
                screenImageView.center = CGPoint.init(x: UIScreen.main.bounds.size.width * 3/2.0, y: UIScreen.main.bounds.size.height/2.0)
                lastVCImageView.center = CGPoint.init(x: UIScreen.main.bounds.size.width/2.0, y: UIScreen.main.bounds.size.height/2.0)
            }, completion: {(finish:Bool)->Void in
                lastVCImageView.removeFromSuperview()
                screenImageView.removeFromSuperview()
                self.screenShotArray.removeLastObject()
                transitionContext.completeTransition(true)
            })
            
            
        }
        
    }
    
    
    func screenShot()->UIImage{
        //将要被截图的View，即窗口的跟控制器View（必须不含状态栏，默认iOS7中是含状态栏的）
        let beyondVC:UIViewController = (self.navigationController?.view.window?.rootViewController)!
        //背景图片的大小
        let size:CGSize = beyondVC.view.frame.size
        //开启上下文，使用参数之后，截出来的是原图（YES 0.0 质量高）
        UIGraphicsBeginImageContextWithOptions(size, true, 0.0)
        //腰剪裁的矩形
        let rect:CGRect = CGRect.init(x: 0, y: 0, width: UIScreen.main.bounds.size.width, height: UIScreen.main.bounds.size.height)
        beyondVC.view.drawHierarchy(in: rect, afterScreenUpdates: false)
        let  snapshot:UIImage  = UIGraphicsGetImageFromCurrentImageContext()!
        UIGraphicsEndImageContext()
        return snapshot
    }
    
    
}
