//
//  ViewController.swift
//  Maratonico
//
//  Created by Jorge Collins Gómez on 11/07/22.
//

import UIKit
import CoreData

class MaratonicoTableViewController: SwipeTableViewController {

    var questionArray = [Question]()
    var cardIndex = 0

    var selectedBoardGame : BoardGame? {
        // Happen as soon as selectedBoardGame gets set with a value
        didSet {
            loadQuestions()
            cardIndex = Int(selectedBoardGame!.currentIndex!) ?? 0
        }
    }
    
    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    
    @IBAction func addQuestionPressed(_ sender: UIBarButtonItem) {
        
        var textFieldCardId = UITextField()
        var textFieldQuestionNumber = UITextField()
        var textFieldTheme = UITextField()
        var textFieldQuestion = UITextField()
        var textFieldAnswer1 = UITextField()
        var textFieldAnswer2 = UITextField()
        var textFieldAnswer3 = UITextField()
        var textFieldCorrectAnswer = UITextField()

        let alert = UIAlertController(title: "Agregar pregunta", message: "", preferredStyle: .alert)

        alert.addTextField { field in
            textFieldCardId = field
            textFieldCardId.placeholder = "No. de la tarjeta"
        }
        alert.addTextField { field in
            textFieldQuestionNumber = field
            textFieldQuestionNumber.placeholder = "No. de pregunta"
        }
        alert.addTextField { field in
            textFieldTheme = field
            textFieldTheme.placeholder = "Tema"
        }
        alert.addTextField { field in
            textFieldQuestion = field
            textFieldQuestion.placeholder = "Escribe la pregunta"
        }
        alert.addTextField { field in
            textFieldAnswer1 = field
            textFieldAnswer1.placeholder = "Respuesta 1"
        }
        alert.addTextField { field in
            textFieldAnswer2 = field
            textFieldAnswer2.placeholder = "Respuesta 2"
        }
        alert.addTextField { field in
            textFieldAnswer3 = field
            textFieldAnswer3.placeholder = "Respuesta 3"
        }
        alert.addTextField { field in
            textFieldCorrectAnswer = field
            textFieldCorrectAnswer.placeholder = "Respuesta correcta [1, 2 o 3]"
        }
        
        let actionCancel = UIAlertAction(title: "Cancelar", style: .cancel) { action in
            self.dismiss(animated: true)
        }
        
        let actionOk = UIAlertAction(title: "Agregar", style: .default) { action in
            
            self.addQuestion(
                a1: textFieldAnswer1.text!,
                a2: textFieldAnswer2.text!,
                a3: textFieldAnswer3.text!,
                cardId: textFieldCardId.text!,
                correctAnswer: textFieldCorrectAnswer.text!,
                q: textFieldQuestion.text!,
                qNumber: Float(textFieldQuestionNumber.text!)!,
                theme: textFieldTheme.text!
            )
        }
        
        alert.addAction(actionCancel)
        alert.addAction(actionOk)
        
        present(alert, animated: true)
    }
    

    //MARK: - Data source methods

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return questionArray.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = super.tableView(tableView, cellForRowAt: indexPath)
        cell.textLabel?.text = questionArray[indexPath.row].q
        
        return cell
    }

    
    //MARK: - Delegate methods

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        let selectedQuestion = questionArray[indexPath.row]
        
        let alert = UIAlertController(
            title: selectedQuestion.q,
            message: "CardId:  \(selectedQuestion.cardId!), #: \(selectedQuestion.qNumber) \n\(selectedQuestion.a1!) | \(selectedQuestion.a2!) | \(selectedQuestion.a3!) \nRespuesta correcta: \(selectedQuestion.correctAnswer!) \nTablero: \(selectedQuestion.parentBoardGame!.title!)",
            preferredStyle: .alert)
        let alertAction = UIAlertAction(title: "Ok", style: .default) { action in
            self.dismiss(animated: true)
        }
        alert.addAction(alertAction)

        present(alert, animated: true, completion: nil)

        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    
    //MARK: - Data manipulation

    // Agrega una pregunta
    func addQuestion(a1:String, a2:String, a3:String, cardId:String, correctAnswer:String, q:String, qNumber:Float, theme:String) {
        
        let newQuestion = Question(context: context)
        newQuestion.a1 = a1
        newQuestion.a2 = a2
        newQuestion.a3 = a3
        newQuestion.cardId = cardId
        newQuestion.correctAnswer = correctAnswer
        newQuestion.q = q
        newQuestion.qNumber = qNumber
        newQuestion.parentBoardGame = selectedBoardGame
        
        self.questionArray.append(newQuestion)
  
        saveQuestions()
    }
    
    // Guarda en CoreData el context con las preguntas que contiene
    func saveQuestions() {
        
        do {
            try context.save()
        } catch {
            print("Error saveQuestions \(error)")
        }
        
        tableView.reloadData()
    }
    
    // Recupera todas las preguntas y las almacena en -questionArray-
    func loadQuestions(with request: NSFetchRequest<Question> = Question.fetchRequest(), predicate: NSPredicate? = nil) {

        let parentPredicate = NSPredicate(format: "parentBoardGame.title MATCHES %@", selectedBoardGame!.title!)

        request.predicate = predicate != nil ? NSCompoundPredicate(andPredicateWithSubpredicates: [parentPredicate, predicate!]) : parentPredicate
        
        do {
            questionArray = try context.fetch(request)
        } catch {
            print("--- Error fetching questions \(error)")
        }
        
        tableView.reloadData()
        // print("--- \(questionArray.count) Questions loaded")
    }
    
    
    override func updateModel(at indexPath: IndexPath) {
        
        context.delete(questionArray[indexPath.row])
        questionArray.remove(at: indexPath.row)
        
        do {
            try self.context.save()
        } catch {
            print("Error saveQuestions \(error)")
        }
    }
}

//MARK: - Search bar methods

extension MaratonicoTableViewController : UISearchBarDelegate {
    
    func search(with searchBar: UISearchBar) {
        let request: NSFetchRequest<Question> = Question.fetchRequest()
        // En [cd] -c- indica "no case sensitive" y -d- "no diacritic sensitive" (acentos)
        let predicate = NSPredicate(format: "q CONTAINS[cd] %@", searchBar.text!)
        request.sortDescriptors = [NSSortDescriptor(key: "q", ascending: true)]
        
        loadQuestions(with: request, predicate: predicate)
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        
        // Si no esta vacia la barra de busqueda
        if searchBar.text?.count != 0 {
            // Buscar con lo indicado en la barra de busqueda
            search(with: searchBar)
            // Ocultar el teclado usado para la barra de busqueda
            DispatchQueue.main.async {
                searchBar.resignFirstResponder()
            }
        }
    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        
        if searchBar.text?.count == 0 {
            loadQuestions()
            DispatchQueue.main.async {
                searchBar.resignFirstResponder()
            }
        } else {
            search(with: searchBar)
        }
    }
}
