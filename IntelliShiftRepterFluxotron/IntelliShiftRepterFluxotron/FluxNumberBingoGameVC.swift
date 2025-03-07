//
//  FluxNumberBingoGameVC.swift
//  IntelliShiftRepterFluxotron
//
//  Created by SunTory on 2025/3/7.
//

import UIKit

class FluxNumberBingoGameVC: UIViewController {
    
    @IBOutlet weak var playerCollectionView: UICollectionView!
    @IBOutlet weak var computerCollectionView: UICollectionView!
    @IBOutlet weak var gameStatusLabel: UILabel!
    @IBOutlet weak var resetButton: UIButton!
    @IBOutlet weak var autofillButton: UIButton!
    
    var playerNumbers: [[Int]] = Array(repeating: Array(repeating: 0, count: 5), count: 5)
    var computerNumbers: [[Int]] = []
    var playerSelected: [[Bool]] = Array(repeating: Array(repeating: false, count: 5), count: 5)
    var computerSelected: [[Bool]] = Array(repeating: Array(repeating: false, count: 5), count: 5)
    var availableNumbers: [Int] = Array(1...25)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupCollectionViews()
        resetGame()
        autofill()
    }
    
    func setupCollectionViews() {
        playerCollectionView.delegate = self
        playerCollectionView.dataSource = self
        computerCollectionView.delegate = self
        computerCollectionView.dataSource = self
        
        playerCollectionView.register(UINib(nibName: "FluxoBingoCell", bundle: nil), forCellWithReuseIdentifier: "FluxoBingoCell")
        computerCollectionView.register(UINib(nibName: "FluxoBingoCell", bundle: nil), forCellWithReuseIdentifier: "FluxoBingoCell")
    }
    
    func resetGame() {
        playerNumbers = Array(repeating: Array(repeating: 0, count: 5), count: 5)
        computerNumbers = (1...25).shuffled().chunked(into: 5)
        playerSelected = Array(repeating: Array(repeating: false, count: 5), count: 5)
        computerSelected = Array(repeating: Array(repeating: false, count: 5), count: 5)
        availableNumbers = Array(1...25)
        gameStatusLabel.text = "Game On! Fill Player Grid"
        autofillButton.isEnabled = true
        playerCollectionView.reloadData()
        computerCollectionView.reloadData()
    }
    
    func checkBingo(selected: [[Bool]], collectionView: UICollectionView) -> Int {
        var lineCount = 0
        
        // Check rows
        for row in 0..<5 {
            if selected[row].allSatisfy({ $0 }) {
                lineCount += 1
                for col in 0..<5 {
                    let indexPath = IndexPath(item: row * 5 + col, section: 0)
                    if let cell = collectionView.cellForItem(at: indexPath) as? FluxoBingoCell {
                        cell.cellBackgroundView.backgroundColor = .red
                    }
                }
            }
        }
        
        for col in 0..<5 {
            if (0..<5).allSatisfy({ selected[$0][col] }) {
                lineCount += 1
                for row in 0..<5 {
                    let indexPath = IndexPath(item: row * 5 + col, section: 0)
                    if let cell = collectionView.cellForItem(at: indexPath) as? FluxoBingoCell {
                        cell.cellBackgroundView.backgroundColor = .red
                    }
                }
            }
        }
        
        if (0..<5).allSatisfy({ selected[$0][$0] }) {
            lineCount += 1
            for i in 0..<5 {
                let indexPath = IndexPath(item: i * 5 + i, section: 0)
                if let cell = collectionView.cellForItem(at: indexPath) as? FluxoBingoCell {
                    cell.cellBackgroundView.backgroundColor = .red
                }
            }
        }
        
        if (0..<5).allSatisfy({ selected[$0][4 - $0] }) {
            lineCount += 1
            for i in 0..<5 {
                let indexPath = IndexPath(item: i * 5 + (4 - i), section: 0)
                if let cell = collectionView.cellForItem(at: indexPath) as? FluxoBingoCell {
                    cell.cellBackgroundView.backgroundColor = .red
                }
            }
        }
        return lineCount
    }


    func computerTurn(selectedNumber: Int) {
        gameStatusLabel.text = "Computer's Turn"
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) { [weak self] in
            guard let self = self else { return }
            
            for row in 0..<5 {
                for col in 0..<5 {
                    if self.computerNumbers[row][col] == selectedNumber {
                        self.computerSelected[row][col] = true
                        self.computerCollectionView.reloadItems(at: [IndexPath(item: row * 5 + col, section: 0)])
                    }
                }
            }
            
            let flatComputerGrid = self.computerNumbers.enumerated().flatMap { row, rowValues in
                rowValues.enumerated().compactMap { col, value in
                    self.computerSelected[row][col] ? nil : (row, col, value)
                }
            }
            
            guard let randomCell = flatComputerGrid.randomElement() else { return }
            let (row, col, value) = randomCell
            self.computerSelected[row][col] = true
            self.computerCollectionView.reloadItems(at: [IndexPath(item: row * 5 + col, section: 0)])
            
            for playerRow in 0..<5 {
                for playerCol in 0..<5 {
                    if self.playerNumbers[playerRow][playerCol] == value && !self.playerSelected[playerRow][playerCol] {
                        self.playerSelected[playerRow][playerCol] = true
                        self.playerCollectionView.reloadItems(at: [IndexPath(item: playerRow * 5 + playerCol, section: 0)])
                    }
                }
            }
            
            let computerLines = self.checkBingo(selected: self.computerSelected, collectionView: self.computerCollectionView)
            if computerLines >= 5 {
                self.showWinAlert(winner: "Computer", lines: computerLines)
                return
            }
            
            let playerLines = self.checkBingo(selected: self.playerSelected, collectionView: self.playerCollectionView)
            if playerLines >= 5 {
                self.showWinAlert(winner: "Player", lines: playerLines)
                return
            }
            
            self.gameStatusLabel.text = "Player's Turn"
        }
    }


    func showWinAlert(winner: String, lines: Int) {
        let alertController = UIAlertController(title: "Game Over", message: "\(winner) Wins with \(lines) lines!", preferredStyle: .alert)
        let okAction = UIAlertAction(title: "OK", style: .default) { _ in
            self.resetGame()
            self.autofill()
        }
        alertController.addAction(okAction)
        present(alertController, animated: true, completion: nil)
    }


    func autofill() {
        availableNumbers.shuffle()
        for row in 0..<5 {
            for col in 0..<5 {
                playerNumbers[row][col] = availableNumbers.removeFirst()
            }
        }
        autofillButton.isEnabled = false
        gameStatusLabel.text = "Game On! Player's Turn"
        playerCollectionView.reloadData()
    }

    
    @IBAction func autofillTapped(_ sender: UIButton) {
        availableNumbers.shuffle()
        for row in 0..<5 {
            for col in 0..<5 {
                playerNumbers[row][col] = availableNumbers.removeFirst()
            }
        }
        autofillButton.isEnabled = false
        gameStatusLabel.text = "Game On! Player's Turn"
        playerCollectionView.reloadData()
    }
    
    @IBAction func resetGameTapped(_ sender: UIButton) {
        resetGame()
    }
    
    @IBAction func btnBack(_ sender: Any) {
        navigationController?.popViewController(animated: true)
    }
}

extension FluxNumberBingoGameVC: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 25
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "FluxoBingoCell", for: indexPath) as? FluxoBingoCell else {
            return UICollectionViewCell()
        }
        
        let row = indexPath.item / 5
        let col = indexPath.item % 5
        
        if collectionView == playerCollectionView {
            cell.configure(number: playerNumbers[row][col], isSelected: playerSelected[row][col])
        } else {
            let isSelected = computerSelected[row][col]
            cell.configure(number: isSelected ? computerNumbers[row][col] : nil, isSelected: isSelected)
        }
        
        return cell
    }

    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        guard collectionView == playerCollectionView else { return }
        
        let row = indexPath.item / 5
        let col = indexPath.item % 5
        
        if playerSelected[row][col] || playerNumbers[row][col] == 0 { return } // Prevent re-selection or selecting empty slots
        
        let selectedNumber = playerNumbers[row][col]
        playerSelected[row][col] = true
        playerCollectionView.reloadItems(at: [indexPath])
        
        let playerLines = checkBingo(selected: playerSelected, collectionView: playerCollectionView)
        if playerLines >= 5 {
            showWinAlert(winner: "Player", lines: playerLines)
            return
        }
        
        computerTurn(selectedNumber: selectedNumber)
    }



    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let width = collectionView.frame.width / 5 - 2
        return CGSize(width: width, height: width)
    }
}

extension Array {
    func chunked(into size: Int) -> [[Element]] {
        stride(from: 0, to: count, by: size).map {
            Array(self[$0..<Swift.min($0 + size, count)])
        }
    }
}

