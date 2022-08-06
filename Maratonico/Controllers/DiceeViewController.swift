//
//  DiceeViewController.swift
//  Maratonico
//
//  Created by Jorge Collins Gómez on 03/08/22.
//

import UIKit
import CoreData

class DiceeViewController: UIViewController {
    
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
    
    @IBOutlet weak var diceeImageView: UIImageView!
    
    override var prefersStatusBarHidden: Bool {
        return true
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    
    @IBAction func rollDiceePressed(_ sender: UIButton) {
        
        let diceArray = ["DiceOne", "DiceTwo","DiceThree", "DiceFour","DiceFive", "DiceSix"]
        diceeImageView.image = UIImage(named: diceArray.randomElement()!)
//        diceImageView2.image = UIImage(named: diceArray[Int.random(in: 0...5)])
    }
    
    
    // MARK: - Load data

     // Recupera todas las preguntas y las almacena en -questionArray-
     func loadQuestions(with request: NSFetchRequest<Question> = Question.fetchRequest(), predicate: NSPredicate? = nil) {

         let parentPredicate = NSPredicate(format: "parentBoardGame.title MATCHES %@", selectedBoardGame!.title!)

         request.predicate = predicate != nil ? NSCompoundPredicate(andPredicateWithSubpredicates: [parentPredicate, predicate!]) : parentPredicate
         
         do {
             questionArray = try context.fetch(request)
         } catch {
             print(#line, "--- Error fetching questions \(error)")
         }
         print(#line, "\(questionArray.count) Questions loaded")
     }
    
    
}
