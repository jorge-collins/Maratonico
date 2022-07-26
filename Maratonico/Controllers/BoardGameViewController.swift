//
//  BoardGameViewController.swift
//  Maratonico
//
//  Created by Jorge Collins Gómez on 20/07/22.
//

import UIKit
import CoreData
import SwipeCellKit

class BoardGameViewController: UITableViewController {
    
    var boardGames = [BoardGame]()
    
    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    

    override func viewDidLoad() {
        super.viewDidLoad()

        // Uncomment the following line to preserve selection between presentations
        self.clearsSelectionOnViewWillAppear = false
        
        tableView.rowHeight = 60.0
        
        print(FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!)

        loadBoardGames()
    }

    // MARK: - Table view data source

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return boardGames.count
    }
    
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "BoardGameCell", for: indexPath) as! SwipeTableViewCell
        
        cell.textLabel?.text = boardGames[indexPath.row].title
        
        cell.delegate = self
        
        return cell
    }

    
    //MARK: - Data manipulation methods
    
    func saveBoardGames() {
        
        do {
            try context.save()
        } catch {
            print("Error saveBoardGames \(error)")
        }
        
        // Cargamos desde CoreData para que se ordene cada que se actualiza
        loadBoardGames()
    }
    
    
    func loadBoardGames() {
            
        let request: NSFetchRequest<BoardGame> = BoardGame.fetchRequest()
        
        // Agregando el selector los ordena sin importar si estan en mayusculas o minusculas
        let sortDescriptor = NSSortDescriptor(key: "title", ascending: true, selector: #selector(NSString.localizedStandardCompare(_:)))
        
        request.sortDescriptors = [sortDescriptor]
        
        do {
            boardGames = try context.fetch(request)
        } catch {
            print("Error loadBoardGames \(error)")
        }
        
        tableView.reloadData()
    }
    
    //MARK: - Delete all boards and questions
    
    @IBAction func deleteAllButtonPressed(_ sender: UIBarButtonItem) {
        
        let alert = UIAlertController(title: "Confirmar", message: "Se borraran todos los tableros y preguntas", preferredStyle: .alert)
        let actionCancel = UIAlertAction(title: "Cancelar", style: .cancel) { action in
            self.dismiss(animated: true)
        }
        let actionConfirm = UIAlertAction(title: "Ok", style: .default) { action in
            self.deleteAllEntities()
            self.loadBoardGames()
        }
        alert.addAction(actionCancel)
        alert.addAction(actionConfirm)
        present(alert, animated: true)
    }
    
    //MARK: - Add new board game
    
    @IBAction func addButtonPressed(_ sender: UIBarButtonItem) {
        
        var textField = UITextField()
        let alert = UIAlertController(title: "Agregar tablero", message: "", preferredStyle: .alert)
        let actionCancel = UIAlertAction(title: "Cancelar", style: .cancel) { action in
            self.dismiss(animated: true)
        }
        let action = UIAlertAction(title: "Agregar", style: .default) { action in
        
            let newBoardGame = BoardGame(context: self.context)
            newBoardGame.title = textField.text!
            newBoardGame.currentIndex = "0"
            
            self.boardGames.append(newBoardGame)
            self.saveBoardGames()
        }
        
        alert.addAction(action)
        alert.addAction(actionCancel)
        
        alert.addTextField { field in
            textField = field
            textField.placeholder = "Agregar un nuevo tablero"
        }
        
        present(alert, animated: true)
    }
    
    
    //MARK: - Delegate methods
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        performSegue(withIdentifier: "goToQuestions", sender: self)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        let destinationVC = segue.destination as! MaratonicoTableViewController
        
        if let indexPath = tableView.indexPathForSelectedRow {
            destinationVC.selectedBoardGame = boardGames[indexPath.row]
        }
    }
    
    
    //MARK: - Delete all data methods
    
    func deleteAllEntities() {
        let entities = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.managedObjectModel.entities

        for entity in entities {
            delete(entityName: entity.name!)
        }
    }

    func delete(entityName: String) {
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: entityName)
        let deleteRequest = NSBatchDeleteRequest(fetchRequest: fetchRequest)
        do {
            try context.execute(deleteRequest)
        } catch let error as NSError {
            debugPrint(error)
        }
    }

}

//MARK: - Swipe cell methods

extension BoardGameViewController: SwipeTableViewCellDelegate {
    
    func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath, for orientation: SwipeActionsOrientation) -> [SwipeAction]? {
        
        guard orientation == .right else { return nil }

        let deleteAction = SwipeAction(style: .destructive, title: "Eliminar") { action, indexPath in
            // handle action by updating model with deletion
            print("--- item borrado")
            
            self.context.delete(self.boardGames[indexPath.row])
            self.boardGames.remove(at: indexPath.row)

            do {
                try self.context.save()
            } catch {
                print("Error saveBoardGames \(error)")
            }
        }

        // customize the action appearance
        deleteAction.image = UIImage(named: "delete-icon")

        return [deleteAction]
    }
    
    
    func tableView(_ tableView: UITableView, editActionsOptionsForRowAt indexPath: IndexPath, for orientation: SwipeActionsOrientation) -> SwipeOptions {

        var options = SwipeOptions()
        options.expansionStyle = .destructive
        return options
    }
    
}
