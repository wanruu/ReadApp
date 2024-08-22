//
//  BookTableVC.swift
//  Read
//
//  Created by wanruuu on 16/8/2024.
//

import SwiftUI
import AVFoundation


// MARK: 记录indexPath的处理
// 1. book.lastIndex -> initialize table scroll position, speaking position (done)
// 2. when scroll end -> update book.lastIndex, update table scroll position (done)
// 3. when speaking next -> update book.lastIndex, update table scroll position (done)


class BookTableViewController: UITableViewController {
    var book: BookForTable = BookForTable()

    /* Speech */
    var speechIndexPath: IndexPath = IndexPath(row: 0, section: 0)
    var speechSynthesizer = AVSpeechSynthesizer()
    private var readingStatus: ReadingStatus = .off
    private var isUserCancelSpeaking: Bool = false
    /* Speech End */

    override func viewDidLoad() {
        super.viewDidLoad()
        
        // TableView setting
        tableView.separatorStyle = .none
        tableView.rowHeight = UITableView.automaticDimension
        tableView.backgroundColor = UIColor.readingBackground  // Scroll to top & bottom color
        tableView.register(BookTableViewCell.self, forCellReuseIdentifier: "cell")

        // Scroll position setting
        DispatchQueue.main.async {
            self.tableView.scrollToRow(at: self.book.indexPath, at: .top, animated: false)
        }
        
        // Speech setting
        speechSynthesizer.delegate = self
        speechIndexPath = book.indexPath

        // Add listener
        NotificationCenter.default.addObserver(self, selector: #selector(handleUserDefaultsChange), name: UserDefaults.didChangeNotification, object: nil)
    }

    deinit {
        NotificationCenter.default.removeObserver(self, name: UserDefaults.didChangeNotification, object: nil)
    }

    @objc private func handleUserDefaultsChange() {
        tableView.reloadData()
    }
}


// MARK: - Define how to render table view.
extension BookTableViewController {
    override func numberOfSections(in tableView: UITableView) -> Int {
        return book.chapters.count
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return book.chapters[section].paragraphs.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as! BookTableViewCell
        
        var text = book.chapters[indexPath.section].paragraphs[indexPath.row]
        text = indexPath.row == 0 ? text : "        " + text
        
        var font = UIFont.systemFont(ofSize: 30, weight: .bold)
        if indexPath.row != 0 {
            var fontSize = CGFloat(UserDefaults.standard.float(forKey: "fontSize"))
            fontSize = fontSize == 0 ? 21 : fontSize
            font = UIFont.systemFont(ofSize: fontSize)
        }

        let fgColor = (readingStatus.isReading && speechIndexPath == indexPath) ? UIColor.tintColor : UIColor.readingForeground
        
        cell.configure(with: text, font: font, fgColor: fgColor)
        return cell
    }
}


// MARK: - Describe the scroll delegate of table view.
extension BookTableViewController {
    override func scrollViewDidScrollToTop(_ scrollView: UIScrollView) {
        handleScrollChange()
    }

    override func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        if !decelerate {
            handleScrollChange()
        }
    }

    override func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        handleScrollChange()
    }
    
    private func handleScrollChange() {
        guard let firstCell = tableView.visibleCells.first, let indexPath = tableView.indexPath(for: firstCell) else { return }
        if book.indexPath != indexPath {
            book.updateIndexPath?(indexPath)
            speechIndexPath = indexPath
            book.indexPath = indexPath
        }
    }
}


// MARK: - Control speech.
extension BookTableViewController: AVSpeechSynthesizerDelegate {
    func handleStatusChange(_ status: ReadingStatus) {
        guard readingStatus != status else { return }
        tableView.isScrollEnabled = !status.isReading
        if readingStatus == .paused && status == .on {
            // Continue
            speechSynthesizer.continueSpeaking()
            UIApplication.shared.isIdleTimerDisabled = true
        } else if status == .on {
            // Turn on
            tableView.scrollToRow(at: speechIndexPath, at: .top, animated: true)
            readNextParagraph()
            UIApplication.shared.isIdleTimerDisabled = true
        } else if status == .off {
            // Stop
            isUserCancelSpeaking = true
            speechSynthesizer.stopSpeaking(at: .immediate)
            UIApplication.shared.isIdleTimerDisabled = false
        } else if status == .paused {
            // Pause
            speechSynthesizer.pauseSpeaking(at: .immediate)
            UIApplication.shared.isIdleTimerDisabled = false
        }
        readingStatus = status
    }

    func readNextParagraph() {
        isUserCancelSpeaking = false
        let (i, j) = (speechIndexPath.section, speechIndexPath.row)
        guard i < book.chapters.count && j < book.chapters[i].paragraphs.count else { return }

        let textToRead = book.chapters[i].paragraphs[j]
        let utterance = AVSpeechUtterance(string: textToRead)
        utterance.voice = AVSpeechSynthesisVoice(language: "zh-CN")
        speechSynthesizer.speak(utterance)
        
        tableView.reloadData()  // Update highlight
    }
    
    func speechSynthesizer(_ synthesizer: AVSpeechSynthesizer, didFinish utterance: AVSpeechUtterance) {
        if !isUserCancelSpeaking {
            // Switch to next paragraph
            let (i, j) = (speechIndexPath.section, speechIndexPath.row)
            if j == book.chapters[i].paragraphs.count - 1 {  // If it's the last paragraph of current chapter
                if i == book.chapters.count - 1 {  // if it's the last chapter
                    return
                }
                speechIndexPath.row = 0
                speechIndexPath.section += 1
            } else {
                speechIndexPath.row += 1
            }
            tableView.scrollToRow(at: speechIndexPath, at: .top, animated: true)
            // Continue to read
            readNextParagraph()
            book.updateIndexPath?(speechIndexPath)
        } else {
            tableView.reloadData()
        }
    }
}
