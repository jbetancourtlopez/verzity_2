//
//  ForgetViewControllerDelegate.swift
//  verzity
//
//  Created by Jossue Betancourt on 19/06/18.
//  Copyright © 2018 Jossue Betancourt. All rights reserved.
//

protocol ForgetViewControllerDelegate: class {
    func okButtonTapped(textFieldValue: String)
    func cancelButtonTapped()
}
