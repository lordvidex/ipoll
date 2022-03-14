//
//  CreatePollOptionCell.swift
//  iPoll
//
//  Created by Evans Owamoyo on 14.03.2022.
//

import UIKit

protocol CreatePollOptionCellDelegate: NSObject {
    /// delegate method called when the optionsButton is clicked for the `CreatePollOptionCell`
    func didAddNewOptionCell(_ sender: CreatePollOptionCell)
    
    /// delegate method called when text changes in optionsTextField in the `CreatePollOptionCell`
    func didChangePollText(_ sender: CreatePollOptionCell, text: String, for indexPath: IndexPath?)
}

class CreatePollOptionCell: UITableViewCell {
    // MARK: settable variables
    weak var delegate: CreatePollOptionCellDelegate?
    
    var showOptionBtn = false
    
    var initialText: String?
    
    var indexPath: IndexPath?
    
    // MARK: private variables
    
    @IBOutlet weak private var optionBtn: UIButton!
    @IBOutlet weak private var optionTextField: UITextField!
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        updateUI()
    }
    
    private func updateUI() {
        optionBtn.isHidden = !showOptionBtn
        optionTextField.text = initialText
    }

    @IBAction private func onTextChanged(_ sender: UITextField) {
        delegate?.didChangePollText(self, text: sender.text ?? "", for: indexPath)
    }
    
    @IBAction private func onAddPressed(_ sender: UIButton) {
        delegate?.didAddNewOptionCell(self)
    }
}
