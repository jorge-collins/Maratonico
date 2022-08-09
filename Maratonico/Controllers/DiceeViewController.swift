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

        let textAttributes = [NSAttributedString.Key.foregroundColor:UIColor.white]
        navigationController?.navigationBar.titleTextAttributes = textAttributes
        
        print("questionArray.count: \(questionArray.count)")
    }
    
    override func viewWillAppear(_ animated: Bool) {
        setCardIDsValues()
    }
    
    // MARK: - Actions
    @IBAction func rollDiceePressed(_ sender: UIButton) {
        
        let randomNumber = Int.random(in: 0...5)
        let currentCardId = cardIDsArray.randomElement()!
        let currentQNumber = String(randomNumber + 1)
        
        // Animacion de tiro del dado
        for index in 0...5 {
            Timer.scheduledTimer(withTimeInterval: 0.02 * Double(index), repeats: false) { timer in
                self.diceeImageView.image = UIImage(named: self.diceArray[index])
            }
        }
        // Animacion que tarda mas que la animacion anterior y muestra el verdadero resultado
        Timer.scheduledTimer(withTimeInterval: 0.2, repeats: false) { timer in
            self.diceeImageView.image = UIImage(named: self.diceArray[randomNumber])
        }
        
        let request: NSFetchRequest<Question> = Question.fetchRequest()
        request.predicate = NSPredicate(format: "cardId MATCHES %@ AND qNumber = %@", currentCardId, currentQNumber)
        do {
            cardQuestions = try context.fetch(request)
        } catch { print(#line, "--- Error fetching questions \(error)") }

        if let currentQuestion = cardQuestions.first {
            
            // Eliminar el cardId del arreglo para que no vuelva a salir en el random
            cardIDsArray.remove(at: cardIDsArray.firstIndex(of: currentCardId)!)

            // Mostrar alert con el numero que salio en el dado
            let alert = UIAlertController(title: "Categoría: \"\(currentQuestion.theme!)\"", message: "Pregunta número \(self.diceTitleArray[randomNumber].lowercased())", preferredStyle: .actionSheet)
        
            // Crear action para notificar el resultado del dado y la categoria
            let alertAction = UIAlertAction(title: "Leer pregunta", style: .default) { action in
                self.performSegue(withIdentifier: "goToQuestion", sender: self)
            }
            
            alert.addAction(alertAction)
            present(alert, animated: true)
            
            siriSpeak(with: "Categoría \(currentQuestion.theme!)")
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if segue.identifier == "goToQuestion" {
            
            let destinationVC = segue.destination as! QuestionViewController
            if let currentQuestion = cardQuestions.first {
                destinationVC.currentQuestion = currentQuestion
            }
        }
        
        if segue.identifier == "goToEdit" {
            if let destinationVC = segue.destination as? MaratonicoTableViewController {
                destinationVC.selectedBoardGame = selectedBoardGame
            }
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


// Para eliminar el texto en el boton -back- de los VCs que se muestren a partir de este
extension UIViewController {
    open override func awakeAfter(using coder: NSCoder) -> Any? {
        navigationItem.backButtonDisplayMode = .minimal // This will help us to remove text
        return super.awakeAfter(using: coder)
    }
}
