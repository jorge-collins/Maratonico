//
//  ViewController.swift
//  Maratonico
//
//  Created by Jorge Collins Gómez on 11/07/22.
//

import UIKit
import CoreData

class MaratonicoTableViewController: UITableViewController {

    var questionArray = [Question]()
    var cardIndex = 0

    var selectedBoardGame : BoardGame? {
        // Happen as soon as selectedBoardGame gets set with a value
        didSet {
            loadQuestions()
            print(self.selectedBoardGame!.title ?? "")
        }
    }
    
    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    
    @IBAction func addQuestionPressed(_ sender: UIBarButtonItem) {
        
        var textFieldQuestion = UITextField()
        var textFieldAnswer1 = UITextField()
        var textFieldAnswer2 = UITextField()
        var textFieldAnswer3 = UITextField()
        var textFieldCorrectAnswer = UITextField()

        let alert = UIAlertController(title: "Agregar pregunta", message: "", preferredStyle: .alert)

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
            textFieldCorrectAnswer.placeholder = "Respuesta correcta [1, 2, 3]"
        }
        
        let actionCancel = UIAlertAction(title: "Cancelar", style: .cancel) { action in
            self.dismiss(animated: true)
        }
        
        let actionOk = UIAlertAction(title: "Agregar", style: .default) { action in
            
            self.addQuestion(q: textFieldQuestion.text!, a1: textFieldAnswer1.text!, a2: textFieldAnswer2.text!, a3: textFieldAnswer3.text!, correctAnswer: textFieldCorrectAnswer.text!)
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
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "GameCell", for: indexPath)
        cell.textLabel?.text = questionArray[indexPath.row].q
        
        return cell
    }

    
    //MARK: - Delegate methods

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        let selectedQuestion = questionArray[indexPath.row]
        
        let alert = UIAlertController(title: selectedQuestion.q, message: "\(selectedQuestion.a1!)\n\(selectedQuestion.a2!)\n\(selectedQuestion.a3!)\nRespuesta correcta: \(selectedQuestion.correctAnswer!)\nTablero: \(selectedQuestion.parentBoardGame!.title!)", preferredStyle: .alert)
        let alertAction = UIAlertAction(title: "Ok", style: .default) { action in
            self.dismiss(animated: true)
        }
        alert.addAction(alertAction)

        present(alert, animated: true, completion: nil)

        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    
    
    //MARK: - Data manipulation
    
    // Recupera todas las preguntas y las almacena en -questionArray-
    func loadQuestions() {
        
        let request: NSFetchRequest<Question> = Question.fetchRequest()
        
        let predicate = NSPredicate(format: "parentBoardGame.title MATCHES %@", selectedBoardGame!.title!)
        
        request.predicate = predicate
        
        do {
            questionArray = try context.fetch(request)
        } catch {
            print("--- Error fetching questions \(error)")
        }
        
        print("--- \(questionArray.count) Questions loaded")
    }

    // Agrega una pregunta
    func addQuestion(q:String, a1:String, a2:String, a3:String, correctAnswer:String) {
        
        let newQuestion = Question(context: context)
        newQuestion.q = q
        newQuestion.a1 = a1
        newQuestion.a2 = a2
        newQuestion.a3 = a3
        newQuestion.correctAnswer = correctAnswer
        newQuestion.parentBoardGame = selectedBoardGame
        
        self.questionArray.append(newQuestion)
  
        saveQuestions()
    }
    
    
    func saveQuestions() {
        
        do {
            try context.save()
        } catch {
            print("Error saveQuestions \(error)")
        }
        
        tableView.reloadData()
    }
    
}
