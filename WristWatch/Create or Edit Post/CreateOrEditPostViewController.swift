//
//  CreateOrEditPostViewController.swift
//  WristWatch
//
//  Created by Marcio Duarte on 2021-04-01.
//

import UIKit

protocol CreateOrEditPostViewControllerDelegate: class {
    func postsUpdated()
}

class CreateOrEditPostViewController: UITableViewController {
    
    @IBOutlet weak var cancelButton: UIBarButtonItem!
    @IBOutlet weak var titleLabel: UITextField!
    @IBOutlet weak var contentTextField: UITextView!
    @IBOutlet weak var saveButton: UIBarButtonItem!
    
    weak var delegate: CreateOrEditPostViewControllerDelegate?
    var article: Article?
    
    override func viewDidLoad() {
        titleLabel.text = article?.title
        contentTextField.text = article?.content
        
        contentTextField.delegate = self
        
        if article?.content == nil {
            contentTextField.text = "Content"
            contentTextField.textColor = UIColor.placeholderText
        }
        
        navigationItem.title = article != nil ? "Edit Post" : "New Post"
    }
    
    @IBAction func saveTapped(_ sender: Any) {
        let newArticle = Article()
        newArticle.id = article?.id ?? UUID().uuidString
        newArticle.title = titleLabel.text
        newArticle.content = contentTextField.text
        
        do {
            try localRepository.createOrUpdate(article: newArticle)
            delegate?.postsUpdated()
            dismissVC()
        } catch {
            let alertVC = AlertUtils.buildAlertController(title: "Error",
                                            message: "Could not save or update the post: \(error.localizedDescription)")
            present(alertVC, animated: true)
        }
    }
    
    @IBAction func cancelTapped(_ sender: Any) {
        dismissVC()
    }
    
    private func dismissVC(completion: (() -> Void)? = nil) {
        self.navigationController?.dismiss(animated: true, completion: completion)
    }
}

extension CreateOrEditPostViewController: UITextViewDelegate {
    func textViewDidBeginEditing(_ textView: UITextView) {
        if textView.textColor == UIColor.placeholderText {
            textView.text = nil
            textView.textColor = UIColor.label
        }
    }
    
    func textViewDidEndEditing(_ textView: UITextView) {
        if textView.text.isEmpty {
            textView.text = "Content"
            textView.textColor = UIColor.placeholderText
        }
    }
}
