//
//  ViewController.swift
//  SwiftUI_UIKit
//
//  Created by ChenHui on 2025/2/11.
//

import UIKit
import SnapKit
import SwiftUI

class ViewController: UIViewController {
    
    lazy var tableView: UITableView = {
        let tableview = UITableView(frame: CGRect.zero, style: .grouped)
        tableview.backgroundColor = .white
        tableview.separatorStyle = .singleLine
        tableview.tableHeaderView = UIView(frame: CGRectMake(0, 0, 0, CGFLOAT_MIN))
        tableview.rowHeight = 44
        tableview.sectionFooterHeight = CGFLOAT_MIN
        tableview.sectionHeaderHeight = CGFLOAT_MIN
        
        tableview.register(UITableViewCell.self,forCellReuseIdentifier: UITableViewCell.description())
        tableview.delegate = self
        tableview.dataSource = self
        return tableview
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        self.view.backgroundColor = .white
        self.title = "SwiftUI UIKit 混合开发"
        
        self.view.addSubview(tableView)
        tableView.snp.makeConstraints { make in
            make.top.equalTo(self.view.snp.topMargin)
            make.left.right.equalToSuperview()
            make.bottom.equalTo(self.view.snp.bottomMargin)
        }
    }
    
}

extension ViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        2
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: UITableViewCell.description(), for: indexPath)
        cell.backgroundColor = .white
        cell.textLabel?.textColor = .black
        cell.accessoryType = .disclosureIndicator
        cell.selectionStyle = .none
        
        if indexPath.row == 0 {
            cell.textLabel?.text = "UIKit调用SwiftUI"
        } else if indexPath.row == 1 {
            cell.textLabel?.text = "SwiftUI调用UIKit"
        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let cell = tableView.cellForRow(at: indexPath)
        var target: UIViewController?
        
        if indexPath.row == 0 {
            target = UIKit2SwiftUIViewController()
        } else if indexPath.row == 1 {
            let swiftUIPageView = SwiftUIPageView()
            target = UIHostingController(rootView: swiftUIPageView)
        }
        
        if let target {
            target.title = cell?.textLabel?.text
            self.navigationController?.pushViewController(target, animated: true)
        }
    }
    
}

