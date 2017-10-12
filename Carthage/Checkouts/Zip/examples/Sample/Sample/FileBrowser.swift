//
//  FileBrowser.swift
//  Sample
//
//  Created by Roy Marmelstein on 17/01/2016.
//  Copyright © 2016 Roy Marmelstein. All rights reserved.
//

import UIKit
import Zip

class FileBrowser: UIViewController, UITableViewDataSource, UITableViewDelegate {

    // IBOutlets
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var selectionCounter: UIBarButtonItem!
    @IBOutlet weak var zipButton: UIBarButtonItem!
    @IBOutlet weak var unzipButton: UIBarButtonItem!

    let fileManager = FileManager.default

    var path: URL? {
        didSet {
            updateFiles()
        }
    }

    var files = [String]()

    var selectedFiles = [String]()

    // MARK: Lifecycle

    override func viewDidLoad() {
        if path == nil {
            let documentsUrl = fileManager.urls(for: .documentDirectory, in: .userDomainMask)[0] as URL
            path = documentsUrl
        }
        updateSelection()
    }

    // MARK: File manager

    func updateFiles() {
        if let filePath = path {
            var tempFiles = [String]()
            do {
                title = filePath.lastPathComponent
                tempFiles = try fileManager.contentsOfDirectory(atPath: filePath.path)
            } catch {
                if filePath.path == "/System" {
                    tempFiles = ["Library"]
                }
                if filePath.path == "/Library" {
                    tempFiles = ["Preferences"]
                }
                if filePath.path == "/var" {
                    tempFiles = ["mobile"]
                }
                if filePath.path == "/usr" {
                    tempFiles = ["lib", "libexec", "bin"]
                }
            }
            files = tempFiles.sorted { $0 < $1 }
            tableView.reloadData()
        }
    }

    // MARK: UITableView Data Source and Delegate

    func numberOfSections(in _: UITableView) -> Int {
        return 1
    }

    func tableView(_: UITableView, numberOfRowsInSection _: Int) -> Int {
        return files.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cellIdentifier = "FileCell"
        var cell = UITableViewCell(style: .subtitle, reuseIdentifier: cellIdentifier)
        if let reuseCell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier) {
            cell = reuseCell
        }
        guard let path = path else {
            return cell
        }
        cell.selectionStyle = .none
        let filePath = files[(indexPath as NSIndexPath).row]
        let newPath = path.appendingPathComponent(filePath).path
        var isDirectory: ObjCBool = false
        fileManager.fileExists(atPath: newPath, isDirectory: &isDirectory)
        cell.textLabel?.text = files[(indexPath as NSIndexPath).row]
        if isDirectory.boolValue {
            cell.imageView?.image = UIImage(named: "Folder")
        } else {
            cell.imageView?.image = UIImage(named: "File")
        }
        cell.backgroundColor = (selectedFiles.contains(filePath)) ? UIColor(white: 0.9, alpha: 1.0) : UIColor.white
        return cell
    }

    func tableView(_: UITableView, didSelectRowAt indexPath: IndexPath) {
        let filePath = files[(indexPath as NSIndexPath).row]
        if let index = selectedFiles.index(of: filePath), selectedFiles.contains(filePath) {
            selectedFiles.remove(at: index)
        } else {
            selectedFiles.append(filePath)
        }
        updateSelection()
    }

    func updateSelection() {
        tableView.reloadData()
        selectionCounter.title = "\(selectedFiles.count) Selected"

        zipButton.isEnabled = (selectedFiles.count > 0)
        if selectedFiles.count == 1 {
            let filePath = selectedFiles.first
            let pathExtension = path!.appendingPathComponent(filePath!).pathExtension
            if pathExtension == "zip" {
                unzipButton.isEnabled = true
            } else {
                unzipButton.isEnabled = false
            }
        } else {
            unzipButton.isEnabled = false
        }
    }

    // MARK: Actions

    @IBAction func unzipSelection(_: AnyObject) {
        let filePath = selectedFiles.first
        let pathURL = path!.appendingPathComponent(filePath!)
        do {
            _ = try Zip.quickUnzipFile(pathURL)
            selectedFiles.removeAll()
            updateSelection()
            updateFiles()
        } catch {
            print("ERROR")
        }
    }

    @IBAction func zipSelection(_: AnyObject) {
        var urlPaths = [URL]()
        for filePath in selectedFiles {
            urlPaths.append(path!.appendingPathComponent(filePath))
        }
        do {
            _ = try Zip.quickZipFiles(urlPaths, fileName: "Archive")
            selectedFiles.removeAll()
            updateSelection()
            updateFiles()
        } catch {
            print("ERROR")
        }
    }
}
