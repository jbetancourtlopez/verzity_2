//
//  Dates.swift
//  verzity
//
//  Created by Jossue Betancourt on 03/07/18.
//  Copyright © 2018 Jossue Betancourt. All rights reserved.
//

import Foundation
import UIKit

/*
 param: "2018-07-15"
 return: "Viernes"
 */
func get_day_of_week(today: String) -> String {
    //let isoDate = "2018-07-15T10:44:00+0000"
    
    let dateFormatter = DateFormatter()
    dateFormatter.dateFormat = "yyyy-MM-dd"
    
    let date = dateFormatter.date(from: today)
    
    
    let calendar = Calendar.current
    let components = calendar.dateComponents([.year, .month, .weekday], from: date!)
    
    let year =  components.year
    let month = components.month
    let day = components.weekday

    
    var array_days = ["Domingo", "Lunes", "Martes", "Miércoles", "Jueves", "Viernes", "Sábado", "Domingo"]
    
    
    return array_days[day! - 1]
}

/*
 param: "2018-07-15"
 return: "15/07/2018"
 */
func get_date(date_string: String) -> String {
    //let isoDate = "2018-07-15T10:44:00+0000"
    
   let formatter = DateFormatter()
    formatter.dateFormat = "yyyy-MM-dd"
    let myString = date_string // string purpose I add here
    let yourDate = formatter.date(from: myString)
    formatter.dateFormat = "dd-MMM-yyyy"
    let myStringafd = formatter.string(from: yourDate!)
    
    
    return  "\(myStringafd)"
}


func get_date_complete(date_complete_string: String) -> String {
    
    //2018-07-02T19:11:55.8529371-05:00
    
    var date_complete_array = date_complete_string.components(separatedBy: "T")
    let date_string = date_complete_array[0]
    
    var hourRegistro = date_complete_array[1]
    var hourRegistro_array = hourRegistro.components(separatedBy: ".")
    hourRegistro = hourRegistro_array[0]
    
    
    let formatter = DateFormatter()
    formatter.dateFormat = "yyyy-MM-dd"
    let myString = date_string // string purpose I add here
    let yourDate = formatter.date(from: myString)
    formatter.dateFormat = "dd/MM/yyyy"
    let myStringafd = formatter.string(from: yourDate!)
    
    
    let dateAsString = hourRegistro
    let dateFormatter = DateFormatter()
    dateFormatter.dateFormat = "HH:mm:ss"
    let date = dateFormatter.date(from: dateAsString)
    
    dateFormatter.dateFormat = "h:mm:ss a"
    let date12 = dateFormatter.string(from: date!)
    
    return  "\(myStringafd) \(date12)"
}


func get_date_complete_date(date_complete_string: String) -> String {
    
    //2018-07-02T19:11:55.8529371-05:00
    
    var date_complete_array = date_complete_string.components(separatedBy: "T")
    let date_string = date_complete_array[0]
    
    var hourRegistro = date_complete_array[1]
    var hourRegistro_array = hourRegistro.components(separatedBy: ".")
    hourRegistro = hourRegistro_array[0]
    
    
    let formatter = DateFormatter()
    formatter.dateFormat = "yyyy-MM-dd"
    let myString = date_string // string purpose I add here
    let yourDate = formatter.date(from: myString)
    formatter.dateFormat = "dd/MM/yyyy"
    let myStringafd = formatter.string(from: yourDate!)
    
    
    return  "\(myStringafd)"
}


func date_to_string(date: Date) -> String{
    let formatter = DateFormatter()
    // initially set the format based on your datepicker date
    formatter.dateFormat = "yyyy-MM-dd"
    
    let myString = formatter.string(from: date)
    // convert your string to date
    let yourDate = formatter.date(from: myString)
    //then again set the date format whhich type of output you need
    formatter.dateFormat = "dd-MMM-yyyy"
    // again convert your date to string
    let myStringafd = formatter.string(from: yourDate!)
    
    return myString
}

func format_date_dmy(date_string: String) -> String{
    
    let parts = date_string.components(separatedBy: "-")
    
    let year    = parts[0]
    var month = parts[1]
    let day = parts[2]
    
    let part_moth = month.components(separatedBy: "0")
    if part_moth[0] == "" {
        month = part_moth[1]
    }
    
    var months: [String] = ["Enero", "Febrero", "Marzo", "Abril", "Mayo", "Junio", "Julio", "Agosto", "Septiembre", "Octubre", "Noviembre", "Diciembre"]
    
    let number_moth = Int(month)! - 1
    let month_name = months[number_moth]
    
    return day + " " + month_name + " " + year;
    
}
