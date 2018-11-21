//
//  ViewController.swift
//  MotionCube
//
//  Created by Mbongeni NDLOVU on 2018/10/09.
//  Copyright © 2018 mndlovu. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
    
    let colors: [UIColor] = [
        UIColor(red:0.82, green:0.10, blue:0.10, alpha:1.0),
        UIColor(red:0.82, green:0.10, blue:0.66, alpha:1.0),
        UIColor(red:0.26, green:0.06, blue:0.88, alpha:1.0),
        UIColor(red:0.06, green:0.88, blue:0.88, alpha:1.0),
        UIColor(red:0.05, green:0.95, blue:0.52, alpha:1.0),
        UIColor(red:0.23, green:0.95, blue:0.05, alpha:1.0),
        UIColor(red:0.94, green:1.00, blue:0.00, alpha:1.0),
        UIColor(red:1.00, green:0.84, blue:0.00, alpha:1.0),
        UIColor(red:1.00, green:0.00, blue:0.00, alpha:1.0),
        UIColor(red:0.59, green:0.56, blue:0.54, alpha:1.0)
    ]

    var items: [UIDynamicItem] = []
    let itemSize: CGFloat = 100
    @IBOutlet weak var myView: UIView!
    var animator: UIDynamicAnimator!
    var gravity: UIGravityBehavior!
    var boundries: UICollisionBehavior!
    var bounce: UIDynamicItemBehavior!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }

    
    @IBAction func didTap(_ sender: UITapGestureRecognizer) {
        let point = sender.location(in: myView)
        let frame = CGRect(x: point.x - 50, y: point.y - 50, width: itemSize, height: itemSize)
        let item = UIView(frame: frame);
        
        item.backgroundColor = colors[Int(arc4random_uniform(10))]
        if Int(arc4random_uniform(2)) == 1 {
            item.layer.cornerRadius = itemSize / 2
        }
        myView.addSubview(item)
        addPenGesture(view: item)
        addPinchGesture(view: item)
        addRotationGesture(view: item)
        items.append(item)
        // animation
        animator = UIDynamicAnimator(referenceView: self.view)
        // gravity
        gravity = UIGravityBehavior(items: self.items)
        let direction = CGVector(dx: 0.0, dy: 1.0)
        gravity.gravityDirection = direction
        // collision
        boundries = UICollisionBehavior(items: self.items)
        boundries.translatesReferenceBoundsIntoBoundary = true
        //bounce
        bounce = UIDynamicItemBehavior(items: self.items)
        bounce.elasticity = 0.8
        
        animator.addBehavior(bounce)
        animator.addBehavior(boundries)
        animator.addBehavior(gravity)
    }
    
    func addPenGesture(view: UIView) {
        let pan = UIPanGestureRecognizer(target: self, action: #selector(panGesture(_:)))
        view.addGestureRecognizer(pan)
    }
    
    func addPinchGesture(view: UIView) {
        let pinch = UIPinchGestureRecognizer(target: self, action: #selector(pinchGesture(_:)))
        view.addGestureRecognizer(pinch)
    }
    
    func addRotationGesture(view: UIView) {
        let rotate = UIRotationGestureRecognizer(target: self, action: #selector(rotationGesture(_:)))
        view.addGestureRecognizer(rotate)
    }

    @objc func panGesture(_ sender:UIPanGestureRecognizer) {
        switch sender.state {
        case .began:
            self.gravity.removeItem(sender.view!)
        case .changed:
            sender.view?.center = sender.location(in: sender.view?.superview)
            animator.updateItem(usingCurrentState: sender.view!)
        case .ended:
            print("End pan")
            self.gravity.addItem(sender.view!)
        case .failed, .cancelled:
            print("Fail or Cancel pan")
        case .possible:
            print("Possible")
        }
    }
    
    @objc func pinchGesture(_ sender: UIPinchGestureRecognizer) {
        if let view = sender.view {
            print("scale  =  \(sender.scale)")
            switch sender.state {
            case .began:
                print("Begin pinch")
                self.gravity.removeItem(view)
                self.boundries.removeItem(view)
                self.bounce.removeItem(view)
            case.changed:
                print("Change pinch")
                //For Square
                sender.view?.layer.bounds.size.height *= sender.scale
                sender.view?.layer.bounds.size.width *= sender.scale
                //For Circle
                if (sender.view!.layer.cornerRadius != 0) {
                    sender.view!.layer.cornerRadius *= sender.scale
                }
                sender.scale = 1
            case .ended:
                print("End pinch")
                self.gravity.addItem(view)
                self.boundries.addItem(view)
                self.bounce.addItem(view)
            case .failed, .cancelled:
                print("Failed or Cancelled pinch")
            case .possible:
                print("Possible")
            }
        }
    }
    
    @objc func rotationGesture(_ sender: UIRotationGestureRecognizer) {
        if let view = sender.view {
            print(sender.rotation)
            switch sender.state {
            case .began:
                print("Begin rotation")
                self.gravity.removeItem(view)
            case.changed:
                print(sender.rotation)
                view.transform = view.transform.rotated(by: sender.rotation)
                animator.updateItem(usingCurrentState: sender.view!)
                sender.rotation = 0
            case .ended:
                print("End rotation")
                self.gravity.addItem(view)
            case .failed, .cancelled:
                print("Failed or Cancelled rotation")
            case .possible:
                print("Possible")
            }
        }
    }
}
