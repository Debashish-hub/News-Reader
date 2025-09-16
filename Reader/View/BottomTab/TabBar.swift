//
//  BMTabBarMenu.swift
//  Reader
//
//  Created by Debashish on 16/09/25.
//


import Foundation
import UIKit
import SwiftUI

open class BMTabBarMenu: UIView {
    var menuView = UIStackView()
    var selectedIndex: Int?
    var mainView: UIView?
    public var dependency: [BMTabBarMenuProps]? = []

    public override init(frame: CGRect) {
        super.init(frame: frame)
    }
    public required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    public func sendViewBackward() {
        self.mainView?.sendSubviewToBack(self)
    }
    public func bringViewToFront() {
        self.mainView?.bringSubviewToFront(self)
    }
    public func addTabView(in view: UIView) {
        mainView = view
        self.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(self)
        NSLayoutConstraint.activate([
            self.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            self.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            self.heightAnchor.constraint(equalToConstant: CGFloat(75)),
            self.trailingAnchor.constraint(equalTo: view.trailingAnchor)
        ])
        //  Add shadow here
        self.layer.shadowColor = UIColor.black.cgColor
        self.layer.shadowOpacity = 0.1   // light shadow
        self.layer.shadowOffset = CGSize(width: 0, height: -2) // shadow on top
        self.layer.shadowRadius = 6
        self.layer.masksToBounds = false
        setupBasicStackView()
    }

    func removeFromView() {
        self.removeFromSuperview()
    }

    func setupBasicStackView() {
        self.menuView.translatesAutoresizingMaskIntoConstraints = false
        self.addSubview(menuView)
        NSLayoutConstraint.activate([
            self.menuView.leadingAnchor.constraint(equalTo: self.leadingAnchor),
            self.menuView.topAnchor.constraint(equalTo: self.topAnchor),
            self.menuView.bottomAnchor.constraint(equalTo: self.bottomAnchor),
            self.menuView.trailingAnchor.constraint(equalTo: self.trailingAnchor)
        ])
        self.menuView.axis = .horizontal
        self.menuView.distribution = .fillEqually
        self.backgroundColor = .systemBackground//UIColor.white
        self.layer.shadowOffset = CGSize(width: 1, height: 1)
    }

    public func setUpTabView(selectedIndex: Int? = nil) {
        self.selectedIndex = selectedIndex ?? 0
        
        self.dependency = [
            BMTabBarMenuProps(selectedImg: UIImage(systemName: "house.fill")!,
                              unselectedImg: UIImage(systemName: "house")!),
            BMTabBarMenuProps(selectedImg: UIImage(systemName: "star.fill")!,
                              unselectedImg: UIImage(systemName: "star")!)
        ]
        
        guard let dependency = self.dependency else { return }
        
        self.menuView.arrangedSubviews.forEach { $0.removeFromSuperview() }
        
        for (index, itm) in dependency.enumerated() {
            let row = UIView()
            row.isUserInteractionEnabled = true
            row.translatesAutoresizingMaskIntoConstraints = false
            
            // Square background view
            let bgView = UIView()
            bgView.translatesAutoresizingMaskIntoConstraints = false
            bgView.backgroundColor = .clear
            bgView.layer.cornerRadius = 8
            row.addSubview(bgView)
            
            NSLayoutConstraint.activate([
                bgView.centerXAnchor.constraint(equalTo: row.centerXAnchor),
                bgView.centerYAnchor.constraint(equalTo: row.centerYAnchor),
                bgView.heightAnchor.constraint(equalToConstant: 48),
                bgView.widthAnchor.constraint(equalToConstant: 48)
            ])
            
            // Image view
            let imgView = UIImageView()
            imgView.translatesAutoresizingMaskIntoConstraints = false
            imgView.contentMode = .scaleAspectFit
            imgView.image = (index == self.selectedIndex) ? itm.selectedImg : itm.unselectedImg
            imgView.tag = 100 + index
            bgView.addSubview(imgView)
            
            NSLayoutConstraint.activate([
                imgView.centerXAnchor.constraint(equalTo: bgView.centerXAnchor),
                imgView.centerYAnchor.constraint(equalTo: bgView.centerYAnchor, constant: -4),
                imgView.heightAnchor.constraint(equalToConstant: 24),
                imgView.widthAnchor.constraint(equalToConstant: 24)
            ])
            
            // Underline view
            let underlineView = UIView()
            underlineView.translatesAutoresizingMaskIntoConstraints = false
            underlineView.backgroundColor = (index == self.selectedIndex) ? UIColor.systemBlue : .clear
            underlineView.tag = 200 + index
            bgView.addSubview(underlineView)
            
            NSLayoutConstraint.activate([
                underlineView.heightAnchor.constraint(equalToConstant: 3),
                underlineView.leadingAnchor.constraint(equalTo: bgView.leadingAnchor, constant: 8),
                underlineView.trailingAnchor.constraint(equalTo: bgView.trailingAnchor, constant: -8),
                underlineView.bottomAnchor.constraint(equalTo: bgView.bottomAnchor, constant: -2)
            ])
            
            row.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(handleTap(_:))))
            
            self.menuView.addArrangedSubview(row)
            NSLayoutConstraint.activate([
                row.topAnchor.constraint(equalTo: self.menuView.topAnchor),
                row.bottomAnchor.constraint(equalTo: self.menuView.bottomAnchor)
            ])
        }
        updateSelection(index: self.selectedIndex ?? 0)
    }
    @objc
    func handleTap(_ sender: UITapGestureRecognizer) {
        guard let tappedView = sender.view,
              let index = self.menuView.arrangedSubviews.firstIndex(of: tappedView),
              let dependency = self.dependency else { return }
        
        self.updateSelection(index: index)
        print("Tapped on item at index: \(index)")
        if index == 0 {
            // Navigate to Articles
            if let topVC = UIApplication.topViewController(), !(topVC is ArticlesVC) {
                let articlesVC = ArticlesVC()
                let navController = UINavigationController(rootViewController: articlesVC)
                navController.modalPresentationStyle = .fullScreen
                topVC.present(navController, animated: false)
            }
        } else if index == 1 {
            // Navigate to Bookmarks
            if let topVC = UIApplication.topViewController(), !(topVC is BookmarkVC) {
                let bookmarkVC = BookmarkVC()
                let navController = UINavigationController(rootViewController: bookmarkVC)
                navController.modalPresentationStyle = .fullScreen
                topVC.present(navController, animated: false)
            }
        }
    }

    private func updateSelection(index: Int) {
        guard let dependency = self.dependency else { return }
        self.selectedIndex = index
        
        for (i, itm) in dependency.enumerated() {
            if i < self.menuView.arrangedSubviews.count,
               let row = self.menuView.arrangedSubviews[i].subviews.first,
               let imgView = row.viewWithTag(100 + i) as? UIImageView,
               let underlineView = row.viewWithTag(200 + i) {
                
                imgView.image = (i == index) ? itm.selectedImg : itm.unselectedImg
                row.backgroundColor = (i == index) ? UIColor.systemGray6 : .clear
                underlineView.backgroundColor = (i == index) ? UIColor.systemBlue : .clear
            }
        }
    }
}


/// BMTabBarMenuProps used for defining properties of each tab in the tab bar menu
public struct BMTabBarMenuProps {
    let selectedImg: UIImage
    let unselectedImg: UIImage
}

