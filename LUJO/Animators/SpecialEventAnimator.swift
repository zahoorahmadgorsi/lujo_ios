//
//  Animator.swift
//  LUJO
//
//  Created by zahoor ahmad gorsi on 15/03/2021.
//  Copyright © 2021 Baroque Access. All rights reserved.
// present/dismis  animation https://medium.com/@tungfam/custom-uiviewcontroller-transitions-in-swift-d1677e5aa0bf#

import UIKit

//Animator is a class that will implement the animation. So the instance of this class will be responsible for either
//presentation or dismissal animation.
final class SpecialEventAnimator: NSObject, UIViewControllerAnimatedTransitioning {

    private let type: PresentationType
    private let firstViewController: HomeViewController
    private let secondViewController: ProductDetailsViewController
    private var selectedCellImageViewSnapshot: UIView
    private let cellImageViewRect: CGRect
    private let cellImgHeartRect: CGRect
    
//  Important note: if something “goes wrong”, for example, you can’t prepare all the needed properties (basically the init fails), make sure to return nil. This way the app will use default present/dismiss animation and the user won’t be stuck somewhere in the middle of the transition.
    init?(type: PresentationType, firstViewController: HomeViewController, secondViewController: ProductDetailsViewController, selectedCellImageViewSnapshot: UIView) {

        self.type = type
        self.firstViewController = firstViewController
        self.secondViewController = secondViewController
        self.selectedCellImageViewSnapshot = selectedCellImageViewSnapshot
        

        guard let window = firstViewController.view.window ?? secondViewController.view.window,
            let selectedCell = firstViewController.selectedSpecialEventCell
            else {
                return nil  // now default animation will execute
            }

//        Getting the Frame of the Image View of the Cell relative to the window’s frame. This is a very essential step since       we will need to animate in the Transition Container View, we need to convert the cell from the collection view’s to an      appropriate coordinate system.
        self.cellImageViewRect = selectedCell.primaryImage.convert(selectedCell.primaryImage.bounds, to: window)
        self.cellImgHeartRect = selectedCell.imgHeart.convert(selectedCell.imgHeart.bounds, to: window)
        
    }

//  Required method of UIViewControllerAnimatedTransitioning protocol. We just return the animation duration we want.
    func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
        return HomeSliderAnimator.duration
    }

//  A required method of UIViewControllerAnimatedTransitioning the protocol. All the transition logic and animations will be done here.
    func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
//        containerView (Transition Container View ) is an instance provided by the transition. Imagine this container as a         view that you would use to run your animations on. Basically it’s a view that is pasted in between 1st and 2nd VCs to       show the animation.
        let containerView = transitionContext.containerView

//      In order to present the 2nd screen, we need to add its subview to containerView. If it fails we completeTransition with     false which means the transition won’t happen
        guard let toView = secondViewController.view
            else {
                transitionContext.completeTransition(false)
                return
        }
        containerView.addSubview(toView)

//      selectedCell and window are unwrapped to make sure they aren’t nil. We are assigning the window of the screen that is       currently presented. Meaning if it’s presentation, then it will be a window of FirstVC, if it’s dismissal then it’s the     window of SecondVC.
//        cellImageSnapshot — snapshot of the image of selected cell
//        controllerImageSnapshot — snapshot of the image of the 2nd VC.
        guard let selectedCell = firstViewController.selectedSpecialEventCell,
            let window = firstViewController.view.window ?? secondViewController.view.window,
            let cellImageSnapshot = selectedCell.primaryImage.snapshotView(afterScreenUpdates: true),
            let controllerImageSnapshot = secondViewController.mainImageView.snapshotView(afterScreenUpdates: true)
            ,let cellImgHeartSnapshot = selectedCell.imgHeart.snapshotView(afterScreenUpdates: true)
            ,let closeButtonSnapshot = secondViewController.imgBack.snapshotView(afterScreenUpdates: true)
            else {
                transitionContext.completeTransition(true)
                return
            }

        let isPresenting = type.isPresenting
        let backgroundView: UIView
        let fadeView = UIView(frame: containerView.bounds)
        fadeView.backgroundColor = secondViewController.view.backgroundColor
        
        if isPresenting {
            selectedCellImageViewSnapshot = cellImageSnapshot
           backgroundView = UIView(frame: containerView.bounds)
           backgroundView.addSubview(fadeView)
           fadeView.alpha = 0
       } else {
            backgroundView = firstViewController.parent?.view.snapshotView(afterScreenUpdates: true) ?? fadeView
            backgroundView.addSubview(fadeView)
       }

        
        toView.alpha = 0
        [backgroundView, selectedCellImageViewSnapshot, controllerImageSnapshot, cellImgHeartSnapshot, closeButtonSnapshot].forEach { containerView.addSubview($0) }
        let controllerImageViewRect = secondViewController.mainImageView.convert(secondViewController.mainImageView.bounds, to: window)
        let controllerImgHeartRect = secondViewController.imgHeart.convert(secondViewController.imgHeart.bounds, to: window)
        let closeButtonRect = secondViewController.imgBack.convert(secondViewController.imgBack.bounds, to: window)
        // B4 - 35
        [selectedCellImageViewSnapshot, controllerImageSnapshot].forEach {
            $0.frame = isPresenting ? cellImageViewRect : controllerImageViewRect
            $0.layer.cornerRadius = isPresenting ? HomeSliderAnimator.cornerRadius : 0
            $0.layer.masksToBounds = true
        }

        controllerImageSnapshot.alpha = isPresenting ? 0 : 1
        selectedCellImageViewSnapshot.alpha = isPresenting ? 1 : 0
        cellImgHeartSnapshot.frame = isPresenting ? cellImgHeartRect : controllerImgHeartRect
        closeButtonSnapshot.frame = closeButtonRect
        closeButtonSnapshot.alpha = isPresenting ? 0 : 1
        
        UIView.animateKeyframes(withDuration: HomeSliderAnimator.duration, delay: 0, options: .calculationModeCubic, animations: {
            UIView.addKeyframe(withRelativeStartTime: 0, relativeDuration: 1) {
                self.selectedCellImageViewSnapshot.frame = isPresenting ? controllerImageViewRect : self.cellImageViewRect
                controllerImageSnapshot.frame = isPresenting ? controllerImageViewRect : self.cellImageViewRect
                fadeView.alpha = isPresenting ? 1 : 0
                cellImgHeartSnapshot.frame = isPresenting ? controllerImgHeartRect : self.cellImgHeartRect
                [controllerImageSnapshot, self.selectedCellImageViewSnapshot].forEach {
                    $0.layer.cornerRadius = isPresenting ? 0 : HomeSliderAnimator.cornerRadius
                }
            }
            UIView.addKeyframe(withRelativeStartTime: 0, relativeDuration: 0.6) {
                self.selectedCellImageViewSnapshot.alpha = isPresenting ? 0 : 1
                controllerImageSnapshot.alpha = isPresenting ? 1 : 0
            }
            UIView.addKeyframe(withRelativeStartTime: isPresenting ? 0.7 : 0, relativeDuration: 0.3) {
                closeButtonSnapshot.alpha = isPresenting ? 1 : 0
            }
        }, completion: { _ in
            //As we usually do: remove all snapshot that we used to animate the transition.
            self.selectedCellImageViewSnapshot.removeFromSuperview()
            controllerImageSnapshot.removeFromSuperview()
            backgroundView.removeFromSuperview()
            cellImgHeartSnapshot.removeFromSuperview()
            closeButtonSnapshot.removeFromSuperview()
            
            toView.alpha = 1
            transitionContext.completeTransition(true)
        })
    }
}
