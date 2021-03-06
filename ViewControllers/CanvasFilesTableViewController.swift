//
//  CanvasFilesTableViewController.swift
//  DragNDropArtist
//
//  Created by Amaan on 2018-08-19.
//  Copyright © 2018 amaancan. All rights reserved.
//

import UIKit

class CanvasFilesTableViewController: UITableViewController {
    
    // model
    var canvasFiles = ["One", "Two", "Three"]
    
    @IBAction func addCanvasFile(_ sender: UIBarButtonItem) {
        canvasFiles += ["Untitled".madeUnique(withRespectTo: canvasFiles)]
        tableView.reloadData()
    }
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        // setting this property triggers viewWillLayoutSubviews, so avoid infinite loop
        if splitViewController?.preferredDisplayMode != .primaryOverlay {
            splitViewController?.preferredDisplayMode = .primaryOverlay
        }
    }
    
}


// MARK: - Table view data source
extension CanvasFilesTableViewController {
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1 // could have others like 'recently deleted'
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return canvasFiles.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "documentCell", for: indexPath)
        
        cell.textLabel?.text = canvasFiles[indexPath.row] // Configure cell
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle ==  .delete {
            canvasFiles.remove(at: indexPath.row)
            tableView.deleteRows(at: [indexPath], with: .fade)
        }
    }
}
