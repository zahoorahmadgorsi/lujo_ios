//
//  Animator.swift
//  LUJO
//
//  Created by hafsa lodhi on 15/03/2021.
//  Copyright © 2021 Baroque Access. All rights reserved.
//

import UIKit

//Animator is a class that will implement the animation. So the instance of this class will be responsible for either presentation or dismissal animation.
final class Animator: NSObject, UIViewControllerAnimatedTransitioning {

    // B2 - 9
    //These are the properties that will be needed for animation
    static let duration: TimeInterval = 0.5
    static let cornerRadius: CGFloat = 2.0

    private let type: PresentationType
    private let firstViewController: HomeViewController
    private let secondViewController: EventDetailsViewController
    private var selectedCellImageViewSnapshot: UIView
    private let cellImageViewRect: CGRect
    // B6 - 45
    private let cellImgHeartRect: CGRect
    
    // B2 - 10
    //Custom initializer that assigns all the properties we declared in bullet 9.
//    Important note: if something “goes wrong”, for example, you can’t prepare all the needed properties (basically the init fails), make sure to return nil. This way the app will use default present/dismiss animation and the user won’t be stuck somewhere in the middle of the transition.
    init?(type: PresentationType, firstViewController: HomeViewController, secondViewController: EventDetailsViewController, selectedCellImageViewSnapshot: UIView) {

        self.type = type
        self.firstViewController = firstViewController
        self.secondViewController = secondViewController
        self.selectedCellImageViewSnapshot = selectedCellImageViewSnapshot
        
        guard let window = firstViewController.view.window ?? secondViewController.view.window,
              let selectedCell = firstViewController.selectedCell
            else {
                return nil  // now default animation will execute
            }

        // B2 - 11
//        Getting the Frame of the Image View of the Cell relative to the window’s frame. This is a very essential step since we will need to animate in the Transition Container View, we need to convert the cell from the collection view’s to an appropriate coordinate system.
        
        self.cellImageViewRect = selectedCell.primaryImage.convert(selectedCell.primaryImage.bounds, to: window)
        // B6 - 46
        self.cellImgHeartRect = selectedCell.imgHeart.convert(selectedCell.imgHeart.bounds, to: window)
        
    }

    // B2 - 12
//    Required method of UIViewControllerAnimatedTransitioning protocol. We just return the animation duration we want.
//    Note that we use a stored property because it will be reused later. So that we don’t have different values flying around which prevents hunting the bugs 🐛 :)
    func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
        return Self.duration
    }

    // B2 - 13
//    A required method of UIViewControllerAnimatedTransitioning the protocol. All the transition logic and animations will be done here.
    func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
        // B2 - 18
//        containerView (Transition Container View ) is an instance provided by the transition. Imagine this container as a view that you would use to run your animations on. Basically it’s a view that is pasted in between 1st and 2nd VCs to show the animation.
        let containerView = transitionContext.containerView

        // B2 - 19
//        In order to present the 2nd screen, we need to add its subview to containerView. If it fails we completeTransition with false which means the transition won’t happen
        guard let toView = secondViewController.view
            else {
                transitionContext.completeTransition(false)
                return
        }
        containerView.addSubview(toView)

        // B3 - 21
//        selectedCell and window are unwrapped to make sure they aren’t nil. We are assigning the window of the screen that is currently presented. Meaning if it’s presentation, then it will be a window of FirstVC, if it’s dismissal then it’s the window of SecondVC.
//        cellImageSnapshot — snapshot of the image of selected cell
//        controllerImageSnapshot — snapshot of the image of the 2nd VC.
        guard let selectedCell = firstViewController.selectedCell,
            let window = firstViewController.view.window ?? secondViewController.view.window,
            let cellImageSnapshot = selectedCell.primaryImage.snapshotView(afterScreenUpdates: true),
            let controllerImageSnapshot = secondViewController.mainImageView.snapshotView(afterScreenUpdates: true)
            // B6 - 47
            ,let cellImgHeartSnapshot = selectedCell.imgHeart.snapshotView(afterScreenUpdates: true)
            // B7 - 53
            ,let closeButtonSnapshot = secondViewController.imgBack.snapshotView(afterScreenUpdates: true)
            else {
                transitionContext.completeTransition(true)
                return
        }

        let isPresenting = type.isPresenting
        // B5 - 40
        let backgroundView: UIView
        let fadeView = UIView(frame: containerView.bounds)
        fadeView.backgroundColor = secondViewController.view.backgroundColor
        
        // B4 - 33
        if isPresenting {
            selectedCellImageViewSnapshot = cellImageSnapshot
            // B5 - 41
           backgroundView = UIView(frame: containerView.bounds)
           backgroundView.addSubview(fadeView)
           fadeView.alpha = 0
       } else {
        backgroundView = firstViewController.parent?.view.snapshotView(afterScreenUpdates: true) ?? fadeView
           backgroundView.addSubview(fadeView)
       }

        // B3 - 23
        toView.alpha = 0
        // B7 - 54
        [backgroundView, selectedCellImageViewSnapshot, controllerImageSnapshot, cellImgHeartSnapshot, closeButtonSnapshot].forEach { containerView.addSubview($0) }
        
        // B3 - 25
        let controllerImageViewRect = secondViewController.mainImageView.convert(secondViewController.mainImageView.bounds, to: window)
        // B6 - 49
        let controllerImgHeartRect = secondViewController.imgHeart.convert(secondViewController.imgHeart.bounds, to: window)
        // B7 - 55
        let closeButtonRect = secondViewController.imgBack.convert(secondViewController.imgBack.bounds, to: window)
        // B4 - 35
       [selectedCellImageViewSnapshot, controllerImageSnapshot].forEach {
            $0.frame = isPresenting ? cellImageViewRect : controllerImageViewRect
            // B8 - 59
            $0.layer.cornerRadius = isPresenting ? Animator.cornerRadius : 0
            $0.layer.masksToBounds = true
       }

        // B4 - 36
        controllerImageSnapshot.alpha = isPresenting ? 0 : 1

        // B4 - 37
        selectedCellImageViewSnapshot.alpha = isPresenting ? 1 : 0
        // B6 - 50
        cellImgHeartSnapshot.frame = isPresenting ? cellImgHeartRect : controllerImgHeartRect
        // B7 - 56
        closeButtonSnapshot.frame = closeButtonRect
        closeButtonSnapshot.alpha = isPresenting ? 0 : 1
        
        // B3 - 27
        UIView.animateKeyframes(withDuration: Self.duration, delay: 0, options: .calculationModeCubic, animations: {
            UIView.addKeyframe(withRelativeStartTime: 0, relativeDuration: 1) {
               // B4 - 38
                self.selectedCellImageViewSnapshot.frame = isPresenting ? controllerImageViewRect : self.cellImageViewRect
                controllerImageSnapshot.frame = isPresenting ? controllerImageViewRect : self.cellImageViewRect
                // B5 - 43
                fadeView.alpha = isPresenting ? 1 : 0
                // B6 - 51
                cellImgHeartSnapshot.frame = isPresenting ? controllerImgHeartRect : self.cellImgHeartRect
                // B8 - 60
                [controllerImageSnapshot, self.selectedCellImageViewSnapshot].forEach {
                    $0.layer.cornerRadius = isPresenting ? 0 : Animator.cornerRadius
                }

            }
            // B4 - 39
            UIView.addKeyframe(withRelativeStartTime: 0, relativeDuration: 0.6) {
                self.selectedCellImageViewSnapshot.alpha = isPresenting ? 0 : 1
                controllerImageSnapshot.alpha = isPresenting ? 1 : 0
            }
            // B7 - 57
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

// B2 - 14
//Simple enum that defines if the screen is dismissed or presented. Will be used to pass to Animator to define which animation to use.
enum PresentationType {

    case present
    case dismiss

    var isPresenting: Bool {
        return self == .present
    }
}
