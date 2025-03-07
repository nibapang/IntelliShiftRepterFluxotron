//
//  FluxoPatternHuntGameVC.swift
//  IntelliShiftRepterFluxotron
//
//  Created by SunTory on 2025/3/7.
//

import Foundation

struct PatternQuestion {
    let pattern: String  // The visible pattern
    let options: [String]  // Multiple choice answers
    let correctAnswer: String  // Correct option
}

struct PatternHuntGame {
    var questions: [PatternQuestion] = [
        // 🔹 Easy Level (Basic Patterns)
        PatternQuestion(pattern: "2, 4, 6, 8, ?", options: ["9", "10", "12"], correctAnswer: "10"),
        PatternQuestion(pattern: "🔵, 🔴, 🔵, 🔴, ?", options: ["🔵", "🟢", "🔴"], correctAnswer: "🔵"),
        PatternQuestion(pattern: "🔺, 🟠, 🔺, 🟠, ?", options: ["🔺", "🔵", "🟢"], correctAnswer: "🔺"),
        PatternQuestion(pattern: "1, 3, 5, 7, ?", options: ["8", "9", "10"], correctAnswer: "9"),
        PatternQuestion(pattern: "5, 10, 15, 20, ?", options: ["25", "30", "22"], correctAnswer: "25"),
        PatternQuestion(pattern: "3, 6, 9, 12, ?", options: ["15", "18", "21"], correctAnswer: "15"),
        PatternQuestion(pattern: "1, 4, 9, 16, ?", options: ["20", "25", "30"], correctAnswer: "25"), // Squares
        PatternQuestion(pattern: "1, 2, 4, 8, 16, ?", options: ["24", "30", "32"], correctAnswer: "32"), // Powers of 2
        PatternQuestion(pattern: "2, 4, 8, 16, ?", options: ["24", "32", "30"], correctAnswer: "32"),
        PatternQuestion(pattern: "10, 20, 30, 40, ?", options: ["50", "55", "60"], correctAnswer: "50"),

        // 🔸 Moderate Level (More Complexity)
        PatternQuestion(pattern: "11, 13, 17, 19, ?", options: ["21", "23", "25"], correctAnswer: "23"), // Prime numbers
        PatternQuestion(pattern: "2, 6, 12, 20, ?", options: ["28", "30", "32"], correctAnswer: "30"), // Quadratic increase
        PatternQuestion(pattern: "1, 3, 6, 10, ?", options: ["14", "15", "12"], correctAnswer: "15"),
        PatternQuestion(pattern: "21, 34, 55, 89, ?", options: ["123", "144", "133"], correctAnswer: "144"), // Fibonacci
        PatternQuestion(pattern: "2, 3, 5, 7, 11, ?", options: ["13", "15", "17"], correctAnswer: "13"), // Prime numbers
        PatternQuestion(pattern: "0, 1, 1, 2, 3, 5, ?", options: ["7", "8", "10"], correctAnswer: "8"), // Fibonacci
        PatternQuestion(pattern: "10, 20, 30, 50, 80, ?", options: ["90", "100", "130"], correctAnswer: "130"), // Mixed jump
        PatternQuestion(pattern: "2, 5, 10, 17, 26, ?", options: ["35", "37", "40"], correctAnswer: "37"), // n^2 + 1
        PatternQuestion(pattern: "3, 7, 15, 31, ?", options: ["50", "63", "64"], correctAnswer: "63"), // Exponential growth
        PatternQuestion(pattern: "4, 8, 15, 25, 38, ?", options: ["50", "54", "56"], correctAnswer: "54"), // Mixed pattern

        // 🔺 Intermediate Level (Patterns with a Twist)
        PatternQuestion(pattern: "100, 50, 25, 12.5, ?", options: ["6.75", "6.25", "5.5"], correctAnswer: "6.25"), // Halving
        PatternQuestion(pattern: "1, 2, 6, 24, 120, ?", options: ["360", "720", "600"], correctAnswer: "720"), // Factorial
        PatternQuestion(pattern: "3, 9, 27, 81, ?", options: ["162", "243", "324"], correctAnswer: "243"), // Powers of 3
        PatternQuestion(pattern: "4, 16, 36, 64, ?", options: ["100", "144", "81"], correctAnswer: "100"), // Squares of evens
        PatternQuestion(pattern: "7, 14, 28, 56, ?", options: ["70", "98", "112"], correctAnswer: "112"), // Doubled intervals
        PatternQuestion(pattern: "1000, 100, 10, 1, ?", options: ["0.1", "0.01", "0.5"], correctAnswer: "0.1"), // Powers of 10 descending
        PatternQuestion(pattern: "1, 1, 2, 6, 24, 120, ?", options: ["480", "720", "600"], correctAnswer: "720"), // Factorial sequence
        PatternQuestion(pattern: "81, 64, 49, 36, ?", options: ["25", "16", "9"], correctAnswer: "25"), // Descending squares
        PatternQuestion(pattern: "10, 22, 46, 94, ?", options: ["190", "192", "196"], correctAnswer: "190"), // Doubling + 2
        PatternQuestion(pattern: "1, 8, 27, 64, 125, ?", options: ["200", "216", "225"], correctAnswer: "216"), // Cubes

        // 🔥 Expert Level (Extreme Challenges)
        PatternQuestion(pattern: "3, 5, 8, 13, 21, 34, ?", options: ["47", "55", "60"], correctAnswer: "55"), // Fibonacci extended
        PatternQuestion(pattern: "1, 2, 4, 7, 11, 16, ?", options: ["20", "22", "23"], correctAnswer: "22"), // Incremental increase
        PatternQuestion(pattern: "2, 5, 11, 20, 32, ?", options: ["45", "47", "49"], correctAnswer: "47"), // Increasing intervals
        PatternQuestion(pattern: "3, 6, 11, 18, 27, ?", options: ["37", "38", "40"], correctAnswer: "38"), // Quadratic increase
        PatternQuestion(pattern: "12, 20, 30, 42, 56, ?", options: ["62", "72", "72"], correctAnswer: "72"), // Step increase
        PatternQuestion(pattern: "9, 18, 30, 45, 63, ?", options: ["72", "84", "96"], correctAnswer: "84"), // Quadratic-like
        PatternQuestion(pattern: "5, 11, 20, 32, 47, ?", options: ["56", "65", "70"], correctAnswer: "65"), // Step growth
        PatternQuestion(pattern: "1, 2, 6, 24, 120, ?", options: ["360", "720", "600"], correctAnswer: "720"), // Factorial
        PatternQuestion(pattern: "1024, 512, 256, 128, ?", options: ["64", "48", "32"], correctAnswer: "64"), // Powers of 2 decreasing
        PatternQuestion(pattern: "89, 144, 233, 377, ?", options: ["500", "610", "750"], correctAnswer: "610") // Fibonacci advanced
    ]


    
    var currentQuestionIndex = 0
    var score = 0
    var startTime: Date? = nil
    
    mutating func getCurrentQuestion() -> PatternQuestion {
        if currentQuestionIndex == 0 {
            startTime = Date() // Start time when the game begins
        }
        return questions[currentQuestionIndex]
    }
    
    mutating func checkAnswer(_ selectedAnswer: String) -> Bool {
        let correct = selectedAnswer == questions[currentQuestionIndex].correctAnswer
        if correct { score += 1 }
        currentQuestionIndex += 1
        return correct
    }
    
    func hasMoreQuestions() -> Bool {
        return currentQuestionIndex < questions.count
    }
    
    mutating func resetGame() {
        currentQuestionIndex = 0
        score = 0
        startTime = nil
    }
}



import UIKit

class FluxoPatternHuntGameVC: UIViewController {
    
    //MARK: - Declare IBOutlets
    @IBOutlet weak var patternLabel: UILabel!
    @IBOutlet weak var option1Button: UIButton!
    @IBOutlet weak var option2Button: UIButton!
    @IBOutlet weak var option3Button: UIButton!
    @IBOutlet weak var resultLabel: UILabel!
    @IBOutlet weak var resetButton: UIButton!

    //MARK: - Declare Variables
    var game = PatternHuntGame()
    
    //MARK: - Override Functions
    override func viewDidLoad() {
        super.viewDidLoad()
        resetButton.isHidden = true
        loadQuestion()
    }
    
    //MARK: - Functions
    func loadQuestion() {
        guard game.hasMoreQuestions() else {
            // Calculate time taken
            let timeTaken = Int(Date().timeIntervalSince(game.startTime ?? Date()))
            
            patternLabel.text = "Game Over! 🎉\nScore: \(game.score)/\(game.questions.count)\nTime: \(timeTaken) sec"
            option1Button.isHidden = true
            option2Button.isHidden = true
            option3Button.isHidden = true
            resetButton.isHidden = false // Show Reset Button
            
            return
        }
        
        let currentQuestion = game.getCurrentQuestion()
        patternLabel.text = currentQuestion.pattern
        option1Button.setTitle(currentQuestion.options[0], for: .normal)
        option2Button.setTitle(currentQuestion.options[1], for: .normal)
        option3Button.setTitle(currentQuestion.options[2], for: .normal)
        resultLabel.text = "" // Clear previous result
    }


    @IBAction func resetGame(_ sender: UIButton) {
        game.resetGame()
        
        // Show buttons again
        option1Button.isHidden = false
        option2Button.isHidden = false
        option3Button.isHidden = false
        resetButton.isHidden = true // Hide Reset Button
        
        loadQuestion()
    }


    
    //MARK: - Declare IBAction
    @IBAction func btnBack(_ sender: Any) {
        navigationController?.popViewController(animated: true)
    }
    
    @IBAction func optionSelected(_ sender: UIButton) {
        guard let answer = sender.titleLabel?.text else { return }
        
        let isCorrect = game.checkAnswer(answer)
        resultLabel.text = isCorrect ? "✅ Correct!" : "❌ Wrong!"
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
            self.loadQuestion()
        }
    }
}

//MARK: - Datasource and Delegate Methods
