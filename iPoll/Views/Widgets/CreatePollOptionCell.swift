//
//  CreatePollOptionCell.swift
//  iPoll
//
//  Created by Evans Owamoyo on 14.03.2022.
//

import UIKit

protocol CreatePollOptionCellDelegate: AnyObject {

    /// delegate method called when the addButton is clicked for the `CreatePollOptionCell`
    func didAddNewOptionCell(_ cell: CreatePollOptionCell)

    /// delegate method called when text changes in optionsTextField in the `CreatePollOptionCell`
    func didChangePollText(_ cell: CreatePollOptionCell, sender: UITextField, text: String, for indexPath: IndexPath?)

    /// delegate method called when delete button is clicked in `CreatePollOptionCell`
    func didDeleteOptionCell(_ cell: CreatePollOptionCell, at indexPath: IndexPath?)
}

class CreatePollOptionCell: UITableViewCell {
    // MARK: settable variables
    weak var delegate: CreatePollOptionCellDelegate?

    var showAddBtn = false {
        didSet {
            addBtn.isHidden = !showAddBtn
        }
    }

    var showDeleteBtn = false {
        didSet {
            deleteBtn.isHidden = !showDeleteBtn
        }
    }

    var initialText: String? {
        didSet {
            optionTextField.text = initialText
        }
    }

    var indexPath: IndexPath?

    // MARK: private variables

    @IBOutlet weak private var addBtn: UIButton!
    @IBOutlet weak private var optionTextField: IPTextField!
    @IBOutlet weak var deleteBtn: UIButton!

    override func awakeFromNib() {
        super.awakeFromNib()
        updateUI()
    }

    private func updateUI() {
        optionTextField.borderColor = Constants.Colors.darkBlue
        addBtn.layer.cornerRadius = 4

    }

    @IBAction private func onTextChanged(_ sender: UITextField) {
        delegate?.didChangePollText(self, sender: sender, text: sender.text ?? "", for: indexPath)
    }

    @IBAction private func onAddPressed(_ sender: UIButton) {
        delegate?.didAddNewOptionCell(self)
    }

    @IBAction func onDeletePressed(_ sender: UIButton) {
        delegate?.didDeleteOptionCell(self, at: indexPath)
    }
}
