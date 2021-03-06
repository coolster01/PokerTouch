//
//  Player.swift
//  
//
//  Created by Subhi Sbahi on 5/27/17.
//
//

import Foundation


class Player {
    
    var myName: String = ""
    var money: Int = 0
    var bet: Int = 0
    var roundBet: Int = 0
    var isBetting: Bool = true
    var card1 = Card(2, "clubs")
    var card2 = Card(2, "clubs")
    var allIn = false
    
    init(name: String)
    {
        myName = name
        money = 1000
        bet = 0
        roundBet = 0
        isBetting = true
        allIn = false
    }
    
    func assignCards(_ card1e: Card, _ card2e: Card)
    {
        card1 = card1e
        card2 = card2e
    }
    
    func bet(amount: Int)
    {
        bet += amount
        roundBet += amount
        money -= amount
    }
    
    func fold()
    {
        isBetting = false
    }
    
    func newRound()
    {
        bet = 0
        roundBet = 0
        isBetting = true
        allIn = false
    }
    
    func win(pot: Int)
    {
        money += pot
        bet = 0
        roundBet = 0
    }
    
    func lose()
    {
        bet = 0
        roundBet = 0
    }
    
    func toString() -> String
    {
        return myName + " has " + String(money)
    }
    
    
}
