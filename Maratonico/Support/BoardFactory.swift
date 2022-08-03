//
//  BoardFactory.swift
//  Maratonico
//
//  Created by Jorge Collins Gómez on 02/08/22.
//

import Foundation

var columnCount: Int = 0

func loadCSV(from csvName: String) -> Int {
    
    guard let filePath = Bundle.main.path(forResource: csvName, ofType: "csv") else {
        print("No existe el archivo")
        return 0
    }
    
    // convert content to a very long string
    var data = ""
    do { data = try String(contentsOfFile: filePath) } catch { return 0 }
    // splits the long string into an array of rows
    var rows = data.components(separatedBy: "\n")
    // count the number of headers
    columnCount = (rows.first?.components(separatedBy: ",").count)!
    
    // Remove headers
    rows.removeFirst()

    for row in rows {
        // Procesamos el renglon para convertirlo en un array de strings
        let rowArray = proccessRow(with: row)
        // Si esta vacio, salte
        guard rowArray != [] else { continue }

        // Guardamos el renglon en CoreData
//        print("addQuestion(a1:String, a2:String, a3:String, cardId:String, correctAnswer:String, q:String, qNumber:Float, theme:String)")

        print(#line, rowArray)
//        // TODO: Recuperamos el renglon procesado

    }
    
    return 1
}


/*
 Recibe un renglon en string y regresa un array de strings, o vacio si el input es invalido
 */
func proccessRow(with row: String) -> [String] {
    // Inicializamos el resultado
    var result: [String] = []
    // Variables para cada iteracion
    var cardId: String = ""
    var qNumber: String = ""
    var theme: String = ""
    var q: String = ""
    var answers: [String] = []

    // Si el renglon esta en blanco, salte
    guard row.first != "," else { return [] }
    // Separamos por comas
    let comaRow = getComaValues(with: row)
    // Si el total de columnas es menor, salte
    guard comaRow.count >= columnCount else { return [] }
    
    if comaRow.count == columnCount {
        // Renglon comun
        cardId = comaRow[0]
        qNumber = comaRow[1]
        theme = comaRow[2]
        q = comaRow[3]
        answers = setAnswers(with: [comaRow[4], comaRow[5], comaRow[6]])

        result = [cardId, qNumber, theme, q, answers[0], answers[1], answers[2], answers[3]]
        
    } else {
        // TODO: Procesamos las variantes
//        print(comaRow.count)
//        print(#function, #line, comaRow)

    }

    // Regresa [ cardId, qNumber, theme, q, a1, a2, a3, correctAnswer ]
//    print(#line, result)
    return result
}


/*
 MARK: - Recibe un array de 3 strings y regresa un array de 4: [r1, r2, r3, respuestaCorrecta]
*/
func setAnswers(with options: [String]) -> [String] {

    var answers = options
    var cAnswer: Int = 0
    var result: [String] = []

    answers.removeAll { str in
        str == ""
    }

    for answer in answers {
        
        var tmp = answer

        if tmp.contains("*") {
            cAnswer = answers.firstIndex(of: answer)!
        }
        
        tmp = tmp.trimmingCharacters(in: [" ", ",", "\r", "*"])
        
        result.append(tmp)
    }

    result.append(String(cAnswer + 1))
    
    return result
}


/*
 MARK: - Recibe un string en CSV y regresa un array de strings, eliminando los elementos ("")- de strings con un trim de [" ", "\r"]
 */
func getComaValues(with str: String) -> [String] {
    // Inicializamos en blanco el array de retorno
    var result: [String] = []
    // Separamos por comas los elementos y eliminamos los vacios ("")
    var tmpArray = str.components(separatedBy: ",")
    tmpArray.removeAll { val in
        val == ""
    }
    
    // Para cada elemento string en el arreglo
    for var currentStr in tmpArray {
        // Le aplicamos un trim de espacios en blanco en ambos extremos
        currentStr = currentStr.trimmingCharacters(in: [" ", "\r"])
        // Agregamos el string recortado al array de retorno
        result.append(currentStr)
    }
    
    return result
}
