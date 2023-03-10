//
//  HypeListViewController.swift
//  Hype
//
//  Created by Stef Castillo on 1/27/23.
//

import UIKit

class HypeListViewController: UIViewController {
    
    var refresh: UIRefreshControl = UIRefreshControl()
    
    @IBOutlet weak var tableView: UITableView!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupViews()
        loadData()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        updateViews()
    }
    
    @IBAction func addHypeButtonTapped(_ sender: Any) {
        presentHypeAlert(nil)
    }
    
    @objc func loadData() {
        HypeController.shared.fetchHypes { (success) in
            if success {
                self.updateViews()
            }
        }
    }
    
    func setupViews() {
        tableView.delegate = self
        tableView.dataSource = self
        refresh.attributedTitle = NSAttributedString(string: "Pull to see more hypes!")
        refresh.addTarget(self, action: #selector(loadData), for: .valueChanged)
        tableView.addSubview(refresh)
    }
    
    func updateViews() {
        DispatchQueue.main.async {
            self.tableView.reloadData()
            self.refresh.endRefreshing()
        }
    }
    
    func presentHypeAlert(_ hype: Hype?) {
        let alert = UIAlertController(title: "Get hype!", message: "What is hype may never die", preferredStyle: .alert)
        
        alert.addTextField { (textField) in
            textField.placeholder = "What is hype today?"
            textField.autocorrectionType = .yes
            textField.autocapitalizationType = .sentences
            if let hype = hype {
                textField.text = hype.body
            }
        }
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel)
        
        let addHypeAction = UIAlertAction(title: "Send", style: .default) {  (_) in
            guard let text = alert.textFields?.first?.text, !text.isEmpty else { return }
            
            if let hype = hype {
                hype.body = text
                HypeController.shared.update(hype) { success in
                    if success {
                        self.updateViews()
                    }
                }
            } else {
                HypeController.shared.saveHype(with: text, photo: nil) { (success) in
                    if success {
                        self.updateViews()
                    }
                }
            }
        }
        
        alert.addAction(cancelAction)
        alert.addAction(addHypeAction)
        
        self.present(alert, animated: true)
        
    }
}// End of Class

extension HypeListViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return HypeController.shared.hypes.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "hypeCell", for: indexPath)
        
        let hype = HypeController.shared.hypes[indexPath.row]
        
        cell.textLabel?.text = hype.body
        
        //add the timestamp
        cell.detailTextLabel?.text = hype.timestamp.formatDate()
        
        return cell
        
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let selectedHype = HypeController.shared.hypes[indexPath.row]
        presentHypeAlert(selectedHype)
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            let hypeToDelete = HypeController.shared.hypes[indexPath.row]
            
            guard let index = HypeController.shared.hypes.firstIndex(of: hypeToDelete) else { return}
            
            HypeController.shared.delete(hypeToDelete) { success in
                if success {
                    HypeController.shared.hypes.remove(at: index)
                    DispatchQueue.main.async {
                        tableView.deleteRows(at: [indexPath], with: .fade)
                    }
                }
            }
            
            
        }
    }
    
}
