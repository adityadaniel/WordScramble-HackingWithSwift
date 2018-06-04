//
//  ViewController.swift
//  WordScramble
//
//  Created by Daniel Aditya Istyana on 6/2/18.
//  Copyright © 2018 Daniel Aditya Istyana. All rights reserved.
//

import UIKit
import GameKit

class ViewController: UITableViewController {
    
    var allWords = [String]()
    var usedWords = [String]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(promptForAnswer))
        navigationItem.leftBarButtonItem = UIBarButtonItem(barButtonSystemItem: .refresh, target: self, action: #selector(restartGame))
        
        if let startWordsPath = Bundle.main.path(forResource: "start", ofType: "txt") {
            if let startWords = try? String(contentsOfFile: startWordsPath) {
                allWords = startWords.components(separatedBy: "\n")
            }
        } else {
            allWords = ["silkworm"]
        }
        
        startGame()
        
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return usedWords.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Word", for: indexPath)
        cell.textLabel?.text = usedWords[indexPath.row]
        return cell
    }
    
    @objc func promptForAnswer() {
        let ac = UIAlertController(title: "Enter answer", message: nil, preferredStyle: .alert)
        ac.addTextField()
        
        let submitAction = UIAlertAction(title: "Submit", style: .default) { [unowned self, ac] (action: UIAlertAction) in
            let answer = ac.textFields![0]
            self.submit(answer: answer.text!)
        }
        
        ac.addAction(submitAction)
        present(ac, animated: true)
    }
    
    func submit(answer: String) {
        let lowerAnswer = answer.lowercased()
        
        let lowerAnswerCount = lowerAnswer.utf16.count
        
        if lowerAnswerCount > 3 {
            if lowerAnswer != title! {
                if isPossible(word: lowerAnswer) {
                    if isReal(word: lowerAnswer) {
                        if isOriginal(word: lowerAnswer) {
                            usedWords.insert(lowerAnswer, at: 0)
                            let indexPath = IndexPath(row: 0, section: 0)
                            tableView.insertRows(at: [indexPath], with: .automatic)
                            return
                        } else {
                            showMessage(title: "Word is used", message: "Please, be original")
                        }
                    } else {
                        showMessage(title: "Word not recognize", message: "You can't make them up")
                    }
                } else {
                    showMessage(title: "Word not possible", message: "You can't speel that word \(title!.lowercased())")
                }
            } else {
                showMessage(title: "Use other word", message: "You can use the words in title")
            }
        } else {
            showMessage(title: "Word cannot less than 3 word", message: "Be creative, please!")
        }
    }
    
    func showMessage(title: String, message: String) {
        
        let ac = UIAlertController(title: title, message: message, preferredStyle: .alert)
        ac.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        present(ac, animated: true, completion: nil)
    }
    
    func isPossible(word: String) -> Bool {
        var tempWords = title!.lowercased()
        for letter in word {
            if let pos = tempWords.range(of: String(letter)) {
                tempWords.remove(at: pos.lowerBound)
            } else {
                return false
            }
        }
        return true
    }
    
    func isReal(word: String) -> Bool {
        let checker = UITextChecker()
        let range = NSMakeRange(0, word.utf16.count)
        let misspelledRange = checker.rangeOfMisspelledWord(in: word, range: range, startingAt: 0, wrap: false, language: "en")
        return misspelledRange.location == NSNotFound
    }
    
    func isOriginal(word: String) -> Bool {
        return !usedWords.contains(word)
    }
    
    @objc func startGame() {
        allWords = GKRandomSource.sharedRandom().arrayByShufflingObjects(in: allWords) as! [String]
        let firstIndex = allWords[0]
        print(allWords)
        title = firstIndex
        usedWords.removeAll(keepingCapacity: true)
        tableView.reloadData()
    }
    
    @objc func restartGame() {
        var currentIndex = allWords.index(of: title!)
        currentIndex = currentIndex! + 1
        title = allWords[currentIndex!]
        usedWords.removeAll(keepingCapacity: true)
        tableView.reloadData()
    }
    
    
    
}

