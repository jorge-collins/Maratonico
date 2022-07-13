//
//  ViewController.swift
//  Maratonico
//
//  Created by Jorge Collins Gómez on 11/07/22.
//

import UIKit
import CoreData

class MaratonicoTableViewController: UITableViewController {

    let gameArray = ["Clasico", "Literario"]
    var questionArray = [Question]()
    var cardIndex = 0
    
    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Obtener la ubicacion de un archivo dentro de la App
//        print(FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!)

        setInitialValues()
    }

    //MARK: - Data source methods

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return gameArray.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "GameCell", for: indexPath)
        cell.textLabel?.text = gameArray[indexPath.row]
        
        return cell
    }

    
    //MARK: - Delegate methods

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        let alert = UIAlertController(title: "¿Como deseas iniciar?", message: "Puedes elegir iniciar desde la primera tarjeta de preguntas o desde donde te quedaste la ultima vez.", preferredStyle: .alert)
        let alertAction1 = UIAlertAction(title: "Desde el inicio", style: .default) { action in
            
            self.cardIndex = 1
            print(self.cardIndex)
        }
        let alertAction2 = UIAlertAction(title: "Donde me quedé", style: .default) { action in
            
            print("Recuperamos el index desde Core Data y lo asignamos a cardIndex")
        }
        alert.addAction(alertAction1)
        alert.addAction(alertAction2)

        present(alert, animated: true, completion: nil)
        
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    
    //MARK: - Data manipulation
    
    
    func addBoardGame() {
        
        // Leer desde el archiivo en csv
        
        // Insertar en los arreglos
        // Board
        // Cards
        // Questions
        
        // Agregar los valores de acuerdo a lo requerido por la App
        
        // Grabar en CoreData
        
        print("addBoardGame")
    }

    
    // Recupera todas las preguntas y las almacena en -questionArray-
    func loadQuestions() {
        
        let request: NSFetchRequest<Question> = Question.fetchRequest()
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
        newQuestion.correctAnswer = correctAnswer
        
        self.questionArray.append(newQuestion)
        
        do {
            try context.save()
        } catch {
            print("---Error saving question: \(q) | \(error)")
        }
    }
    
    
    
    func setInitialValues() {

//        deleteAllEntities()
        
        loadQuestions()
//
//        addQuestion(q: "Edificio mexicano mas alto", a1: "Torre de Pemex", a2: "La Latino", a3: "Bellas artes", correctAnswer: "2")
//
//        print("--- \(questionArray.count) Questions after adding 1 more")

//        addBoardGame()
    }
    
    
    func deleteAllEntities() {
        let entities = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.managedObjectModel.entities

        for entity in entities {
            delete(entityName: entity.name!)
        }
    }

//    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext

    func delete(entityName: String) {
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: entityName)
        let deleteRequest = NSBatchDeleteRequest(fetchRequest: fetchRequest)
        do {
            try context.execute(deleteRequest)
//            try persistentContainer.viewContext.execute(deleteRequest)
        } catch let error as NSError {
            debugPrint(error)
        }
    }
}



