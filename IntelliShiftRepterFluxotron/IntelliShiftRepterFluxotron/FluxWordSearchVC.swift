//
//  FluxWordSearchVC.swift
//  IntelliShiftRepterFluxotron
//
//  Created by SunTory on 2025/3/7.
//

import UIKit

class FluxWordSearchVC: UIViewController {
    
    //MARK: - Declare IBOutlets
    @IBOutlet weak var gridCollectionView: UICollectionView!
    @IBOutlet weak var wordListCollectionView: UICollectionView!
    
    //MARK: - Declare Variables
    let gridSize = 10
    var grid: [[Character]] = []
    let allWords = [
        "apple", "banana", "cherry", "grape", "orange", "peach", "plum", "melon", "kiwi", "lemon",
        "tiger", "lion", "zebra", "panda", "monkey", "rabbit", "giraffe", "elephant", "cheetah", "gorilla",
        "bridge", "castle", "garden", "school", "station", "library", "museum", "theater", "airport", "hospital",
        "ocean", "river", "island", "desert", "volcano", "valley", "mountain", "tundra", "rainforest", "savanna",
        "guitar", "piano", "violin", "trumpet", "drum", "flute", "clarinet", "saxophone", "cello", "harmonica"
    ]

    var wordList: [String] = []
    var selectedCells: [(indexPath: IndexPath, letter: Character)] = []
    var foundWords: Set<String> = []
    var selectionLayers: [CAShapeLayer] = []

    //MARK: - Override Functions
    override func viewDidLoad() {
        super.viewDidLoad()
        setUpCollectionView()
        addSwipeGesture()
        startNewGame()
    }
    
    //MARK: - Functions
    
    func startNewGame() {
         wordList = Array(allWords.shuffled().prefix(5)) // Select 5 random words from the list
         generateGrid()
     }
    
    func setUpCollectionView() {
        gridCollectionView.dataSource = self
        gridCollectionView.delegate = self
        gridCollectionView.register(UINib(nibName: "FluxWordCell", bundle: nil), forCellWithReuseIdentifier: "FluxWordCell")
        
        wordListCollectionView.dataSource = self
        wordListCollectionView.delegate = self
        wordListCollectionView.register(UINib(nibName: "FluxWordListCell", bundle: nil), forCellWithReuseIdentifier: "FluxWordListCell")
    }
    
    func generateGrid() {
        let letters = "ABCDEFGHIJKLMNOPQRSTUVWXYZ"
        grid = Array(repeating: Array(repeating: " ", count: gridSize), count: gridSize)
        
        // Place words in grid
        for word in wordList {
            placeWord(word)
        }
        
        for row in 0..<gridSize {
            for col in 0..<gridSize {
                if grid[row][col] == " " {
                    grid[row][col] = letters.randomElement()!
                }
            }
        }
        
        gridCollectionView.reloadData()
        wordListCollectionView.reloadData()
    }
    
    func placeWord(_ word: String) {
        let directions: [(dx: Int, dy: Int)] = [
            (1, 0),  // Horizontal (→)
            (0, 1),  // Vertical (↓)
            (1, 1),  // Diagonal (\)
            (-1, 1)  // Diagonal (/)
        ]
        
        var placed = false
        while !placed {
            let row = Int.random(in: 0..<gridSize)
            let col = Int.random(in: 0..<gridSize)
            let direction = directions.randomElement()!
            
            var canPlace = true
            var positions: [(row: Int, col: Int)] = []
            
            for i in 0..<word.count {
                let newRow = row + i * direction.dy
                let newCol = col + i * direction.dx
                
                if newRow < 0 || newRow >= gridSize || newCol < 0 || newCol >= gridSize || (grid[newRow][newCol] != " " && grid[newRow][newCol] != Array(word)[i]) {
                    canPlace = false
                    break
                }
                positions.append((newRow, newCol))
            }
            
            if canPlace {
                for (i, pos) in positions.enumerated() {
                    grid[pos.row][pos.col] = Array(word)[i]
                }
                placed = true
            }
        }
    }
    
    func drawSelection() {
        let selectedWord = String(selectedCells.map { $0.letter })
        
        if wordList.contains(selectedWord) {
            foundWords.insert(selectedWord)
            wordListCollectionView.reloadData()
            drawConnectingLine()
            lockSelection()
            
            if foundWords.count == wordList.count {
                showCompletionAlert()
            }
        } else {
            clearSelection() // Remove incorrect line
        }
    }

    func drawConnectingLine() {
        let path = UIBezierPath()

        guard let firstCell = selectedCells.first else { return }

        if let firstCellFrame = gridCollectionView.cellForItem(at: firstCell.indexPath)?.frame {
            let firstPoint = gridCollectionView.convert(CGPoint(x: firstCellFrame.midX, y: firstCellFrame.midY), to: gridCollectionView)
            path.move(to: firstPoint)
        }

        for cellData in selectedCells {
            if let cellFrame = gridCollectionView.cellForItem(at: cellData.indexPath)?.frame {
                let point = gridCollectionView.convert(CGPoint(x: cellFrame.midX, y: cellFrame.midY), to: gridCollectionView)
                path.addLine(to: point)
            }
        }

        let newLayer = CAShapeLayer()
        newLayer.strokeColor = UIColor.blue.cgColor
        newLayer.lineWidth = 5
        newLayer.fillColor = UIColor.clear.cgColor
        newLayer.path = path.cgPath

        selectionLayers.append(newLayer)
        gridCollectionView.layer.addSublayer(newLayer)
    }

    
    func lockSelection() {
        for cellData in selectedCells {
            if let cell = gridCollectionView.cellForItem(at: cellData.indexPath) as? FluxWordCell {
                cell.backgroundColor = .green // Keep selected words highlighted
                cell.bgImage.image = UIImage(named: "ic_blue_square")
            }
        }
        selectedCells.removeAll() // Clear the selection list but keep highlighting
    }
    
    func clearSelection() {
        selectedCells.removeAll() // Just clear selection, don't remove correct lines
    }
    
    func resetGame() {
        foundWords.removeAll()
        selectionLayers.forEach { $0.removeFromSuperlayer() }
        selectionLayers.removeAll()
        startNewGame()
        clearSelection()
        setUpCollectionView()
        
        for cell in gridCollectionView.visibleCells {
            if let FluxWordCell = cell as? FluxWordCell {
                FluxWordCell.bgImage.image = UIImage(named: "ic_green_square")
            }
        }
    }
    
    func showCompletionAlert() {
        let alert = UIAlertController(title: "Congratulations!", message: "You found all the words! Restart the game?", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Restart", style: .default, handler: { _ in
            self.resetGame()
        }))
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        present(alert, animated: true, completion: nil)
    }

    func addSwipeGesture() {
        let panGesture = UIPanGestureRecognizer(target: self, action: #selector(handleSwipe(_:)))
        gridCollectionView.addGestureRecognizer(panGesture)
    }
    
    @objc func handleSwipe(_ gesture: UIPanGestureRecognizer) {
        let location = gesture.location(in: gridCollectionView)

        if let indexPath = gridCollectionView.indexPathForItem(at: location) {
            let row = indexPath.item / gridSize
            let col = indexPath.item % gridSize
            let letter = grid[row][col]

            if gesture.state == .began {
                selectedCells.removeAll()
                selectionLayers.forEach { $0.removeFromSuperlayer() }
                selectionLayers.removeAll()
                
                selectedCells.append((indexPath, letter))
                updateSelectionLine()
            }
            else if gesture.state == .changed {
                if let firstSelection = selectedCells.first {
                    let firstRow = firstSelection.indexPath.item / gridSize
                    let firstCol = firstSelection.indexPath.item % gridSize

                    let rowDiff = row - firstRow
                    let colDiff = col - firstCol

                    // Check if movement is strictly Horizontal, Vertical, or Diagonal
                    let isDiagonal = abs(rowDiff) == abs(colDiff)
                    let isHorizontal = rowDiff == 0
                    let isVertical = colDiff == 0
                    
                    let isValidMove = isDiagonal || isHorizontal || isVertical
                    
                    if isValidMove {
                        // Ensure only valid moves are added
                        if !selectedCells.contains(where: { $0.indexPath == indexPath }) {
                            selectedCells.append((indexPath, letter))
                            updateSelectionLine()
                        }
                    }
                }
            }
            else if gesture.state == .ended {
                finalizeSelectionAndPrint()
            }
        }
    }

    func finalizeSelectionAndPrint() {
        // Ensure we have at least 2 selected points for a valid word
        guard selectedCells.count > 1 else {
            selectedCells.removeAll()
            return
        }
        
        selectedCells = getValidLineCells(selectedCells)
        
        let selectedWord = String(selectedCells.map { $0.letter })
        
        print("Final Selected Word: \(selectedWord)") // Prints only the correctly selected word

        if wordList.contains(selectedWord) {
            foundWords.insert(selectedWord) // Save found word
            wordListCollectionView.reloadData()
            drawConnectingLine() // Draw final line
            lockSelection() // Lock correct selection

            if foundWords.count == wordList.count {
                showCompletionAlert()
            }
        } else {
            clearSelection()
        }
    }

    func getValidLineCells(_ cells: [(indexPath: IndexPath, letter: Character)]) -> [(indexPath: IndexPath, letter: Character)] {
        guard let firstCell = cells.first, let lastCell = cells.last else { return [] }

        let firstRow = firstCell.indexPath.item / gridSize
        let firstCol = firstCell.indexPath.item % gridSize
        let lastRow = lastCell.indexPath.item / gridSize
        let lastCol = lastCell.indexPath.item % gridSize

        let rowStep = (lastRow - firstRow) == 0 ? 0 : (lastRow - firstRow) / abs(lastRow - firstRow)
        let colStep = (lastCol - firstCol) == 0 ? 0 : (lastCol - firstCol) / abs(lastCol - firstCol)

        var validCells: [(indexPath: IndexPath, letter: Character)] = []
        var currentRow = firstRow
        var currentCol = firstCol

        while currentRow != lastRow + rowStep || currentCol != lastCol + colStep {
            let index = (currentRow * gridSize) + currentCol
            let letter = grid[currentRow][currentCol]
            validCells.append((IndexPath(item: index, section: 0), letter))
            currentRow += rowStep
            currentCol += colStep
        }

        return validCells
    }
    
    func updateSelectionLine() {
        selectionLayers.forEach { $0.removeFromSuperlayer() }
        selectionLayers.removeAll()
        
        guard let firstCell = selectedCells.first, let lastCell = selectedCells.last else { return }

        if let firstCellFrame = gridCollectionView.cellForItem(at: firstCell.indexPath)?.frame,
           let lastCellFrame = gridCollectionView.cellForItem(at: lastCell.indexPath)?.frame {
            
            let firstPoint = gridCollectionView.convert(CGPoint(x: firstCellFrame.midX, y: firstCellFrame.midY), to: gridCollectionView)
            let lastPoint = gridCollectionView.convert(CGPoint(x: lastCellFrame.midX, y: lastCellFrame.midY), to: gridCollectionView)

            let path = UIBezierPath()
            path.move(to: firstPoint)
            path.addLine(to: lastPoint)

            let newLayer = CAShapeLayer()
            newLayer.strokeColor = UIColor.blue.cgColor
            newLayer.lineWidth = 5
            newLayer.fillColor = UIColor.clear.cgColor
            newLayer.path = path.cgPath

            selectionLayers.append(newLayer)
            gridCollectionView.layer.addSublayer(newLayer)
        }
    }
    
    func checkAndDrawSelection() {
        let selectedWord = String(selectedCells.map { $0.letter })

        if wordList.contains(selectedWord) {
            foundWords.insert(selectedWord) // Save found word
            wordListCollectionView.reloadData()
            drawConnectingLine() // Draw final line
            lockSelection() // Lock correct selection

            if foundWords.count == wordList.count {
                showCompletionAlert()
            }
        } else {
            clearSelection()
        }
    }
    
    //MARK: - Declare IBAction
    @IBAction func btnBack(_ sender: Any) {
        navigationController?.popViewController(animated: true)
    }
}

//MARK: - Datasource and Delegate Methods
extension FluxWordSearchVC: UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if collectionView == wordListCollectionView {
            return wordList.count
        }
        return gridSize * gridSize
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if collectionView == wordListCollectionView {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "FluxWordListCell", for: indexPath) as! FluxWordListCell
            let word = wordList[indexPath.item]
            
            cell.letterLabel.text = word
            cell.letterLabel.textColor = foundWords.contains(word) ? .gray : .black
            return cell
        } else {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "FluxWordCell", for: indexPath) as! FluxWordCell
            let row = indexPath.item / gridSize
            let col = indexPath.item % gridSize
            cell.bgImage.image = UIImage(named: "ic_green_square")
            cell.letterLabel.text = String(grid[row][col])
            return cell
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        if collectionView == self.gridCollectionView {
            return CGSize(width: collectionView.frame.size.width / 10 - 3, height: collectionView.frame.size.height / 10 - 3)
        } else {
            return CGSize(width: 60 * 2.7607973422, height: 60)
        }
    }
}
