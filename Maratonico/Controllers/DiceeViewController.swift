//
//  DiceeViewController.swift
//  Maratonico
//
//  Created by Jorge Collins Gómez on 03/08/22.
//

import UIKit
import CoreData

class DiceeViewController: UIViewController {
    
    // MARK: - vars and lets
    // Variables para manejar el boardGame
    var questionArray = [Question]()
    var cardIndex = 0
    var selectedBoardGame : BoardGame? {
        // Happen as soon as selectedBoardGame gets set with a value
        didSet {
            loadQuestions()
            cardIndex = Int(selectedBoardGame!.currentIndex!) ?? 0

            navigationItem.title = selectedBoardGame?.title
            
        }
    }
    // Array de unicamente los ids de las tarjetas
    var cardIDsArray: [String] = []
    // Array donde se almancenan las preguntas de la tarjeta actual
    var cardQuestions = [Question]()
    
    // Arreglos de info sobre el dado
    let diceArray = ["DiceOne", "DiceTwo","DiceThree", "DiceFour","DiceFive", "DiceSix"]
    let diceTitleArray = ["Uno", "Dos","Tres", "Cuatro","Cinco", "Seis"]
    
    // MARK: - Outlets
    @IBOutlet weak var diceeImageView: UIImageView!
    
    // MARK: - Override functions
    override var prefersStatusBarHidden: Bool {
        return true
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        setCardIDsValues()
    }
    
    // MARK: - Actions
    @IBAction func rollDiceePressed(_ sender: UIButton) {
        
        let randomNumber = Int.random(in: 0...5)
        let currentCardId = cardIDsArray.randomElement()!
        let currentQNumber = String(randomNumber + 1)
        print(#line, diceTitleArray[randomNumber], currentCardId, currentQNumber)
        
        diceeImageView.image = UIImage(named: diceArray[randomNumber])
        
        let request: NSFetchRequest<Question> = Question.fetchRequest()
        request.predicate = NSPredicate(format: "cardId MATCHES %@ AND qNumber = %@", currentCardId, currentQNumber)

        do {
            cardQuestions = try context.fetch(request)
        } catch { print(#line, "--- Error fetching questions \(error)") }

        if let currentQuestion = cardQuestions.first {
            print(#line, currentQuestion.cardId!, currentQuestion.qNumber, currentQuestion.q!)
        }
    }
    
    
    // MARK: - Load data methods

     // Recupera todas las preguntas y las almacena en -questionArray-
     func loadQuestions(with request: NSFetchRequest<Question> = Question.fetchRequest(), predicate: NSPredicate? = nil) {

         let parentPredicate = NSPredicate(format: "parentBoardGame.title MATCHES %@", selectedBoardGame!.title!)

         request.predicate = predicate != nil ? NSCompoundPredicate(andPredicateWithSubpredicates: [parentPredicate, predicate!]) : parentPredicate
         
         do {
             questionArray = try context.fetch(request)
         } catch {
             print(#line, "--- Error fetching questions \(error)")
         }
     }
    
    func setCardIDsValues() {
        // Inicializar el array donde se almacenaran los cardIDs
        var cardIdArray: [String] = []
        for question in questionArray {
            cardIdArray.append(question.cardId!)
        }
        cardIdArray.sort()
        // Eliminamos los duplicados
        let arrWithoutDuplicates = cardIdArray.reduce([]) {
            (a: [String], b: String) -> [String] in
                if a.contains(b) { return a } else { return a + [b]
            }
        }
        cardIDsArray = arrWithoutDuplicates
    }
    
}
