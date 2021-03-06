//
//  PokerRunner.swift
//  
//
//  Created by Subhi Sbahi on 5/28/17.
//
//

import Foundation

class PokerRunner
{
    var myPlayers: [Player] = []
    var currentPlayerIndex = 0
    var currentPlayer: Player = Player(name: "")
    var currentNecessary: Int = 0
    var pot: Int = 0
    var myDeck = Deck()
    var ended = false
    var run: Int = 1 // can go up to 4 betting runs
    var stage: Int = 1 // 1 = preflop, 2 = flop, 3 = turn, 4 = river, 5 = next step
    var changedRun = false
    var wasTie = false
    var recentWinner: Int = -1
    var recentWinners: [Int] = []
    
    init(players: [Player])
    {
        myPlayers = players
        self.newRound()
    }
    
    /*
    Use when want to play again (same players & money, new cards)
    */
    func newRound() // totally new round of betting (new cards)
    {
        for player in myPlayers
        {
            player.newRound()
        }
        
        self.kickZeros()
        
        if(myPlayers.count >= 1)
        {
            self.changeCurrentPlayer(0)
        }
        myDeck = Deck()
        myDeck.distributeCards(players: myPlayers)
        
        run = 1
        stage = 1
        pot = 0
        
        currentNecessary = 0
    }
    
    func nextStage()
    {
        stage += 1
        run = 1
        changeCurrentPlayer(0)
    }
    
    func nextRun()
    {
        run += 1
        changedRun = true
    }
    
    /*
     Changes currentPlayer to the next available player
    */
    func nextPlayer()
    {
        if(allAllInOrFold())
        {
            stage = 5
            run = 1
        }
        else
        {
            changedRun = false
        
            if(currentPlayerIndex == myPlayers.count - 1)
            {
                self.nextRun()
                changeCurrentPlayer(0)
            }
            else
            {
                changeCurrentPlayer(currentPlayerIndex + 1)
            }

            currentNecessary = maxBet() - currentPlayer.bet
        
            if(currentPlayerIndex == self.firstBetterIndex() && allEqualBets() && run > 1)
            {
                self.nextStage()
            }
        }
    }
    
    func allAllInOrFold() -> Bool
    {
        for player in myPlayers
        {
            if(!player.allIn && player.isBetting)
            {
                return false // not all in AND not folded
            }
        }
        return true
    }
    
    // returns index of first better
    func firstBetterIndex() -> Int
    {
        for i in 0..<myPlayers.count
        {
            if(myPlayers[i].isBetting && !myPlayers[i].allIn)
            {
                return i
            }
        }
        return -1
    }
    
    
    func maxBet() -> Int
    {
        var max: Int = myPlayers[0].bet
        for player in myPlayers
        {
            if player.bet > max
            {
                max = player.bet
            }
        }
        return max
    }
    
    func changeCurrentPlayer(_ index: Int)
    {
        if(myPlayers[index].isBetting && !myPlayers[index].allIn)
        {
            currentPlayerIndex = index
            currentPlayer = myPlayers[index]
        }
        else
        {
            if(index == (myPlayers.count - 1))
            {
                if(!self.changedRun)
                {
                    self.nextRun()
                }
                changeCurrentPlayer(0)
            }
            else
            {
                changeCurrentPlayer(index + 1)
            }
        }
    }
    
    func canCheck() -> Bool
    {
        return currentPlayer.bet == maxBet()
    }
    
    func canRaise() -> Bool
    {
        return run < 3 || (currentPlayerIndex == self.firstBetterIndex())
    }
    
    func call()
    {
        self.bet(amount: currentNecessary)
    }
    
    func fold()
    {
        currentPlayer.fold()
    }
    
    func bet(amount: Int)
    {
        if(amount > currentPlayer.money)
        {
            self.allIn()
        }
        else
        {
            if(amount == currentPlayer.money)
            {
                currentPlayer.allIn = true
            }
            currentPlayer.bet(amount: amount)
            pot += amount
        }
    }
    
    func smallBlind()
    {
        self.bet(amount: 25)
    }
    
    func bigBlind()
    {
        self.bet(amount: 50)
    }
    
    func isSmallBlind() -> Bool
    {
        return stage == 1 && run == 1 && currentPlayerIndex == 0
    }
    
    func isBigBlind() -> Bool
    {
        return stage == 1 && run == 1 && currentPlayerIndex == 1
    }
    
    func mustAllIn() -> Bool
    {
        return self.maxBet() >= (currentPlayer.money + currentPlayer.bet)
    }
    
    func allIn()
    {
        self.bet(amount: currentPlayer.money)
        currentPlayer.allIn = true
    }
    
    func determineWinner()
    {
        var bettingHands: [Hand] = []
        var bettingIndices: [Int] = [] // corresponds to index where each hand came from
        for i in 0..<myPlayers.count
        {
            if(myPlayers[i].isBetting)
            {
                bettingHands.append(self.getHand(index: i))
                bettingIndices.append(i)
            }
        }
        
        let myMatch = PokerMatch(hands: bettingHands)
        let winnerIndices: [Int] = myMatch.determineWinner() // indices of winners for the betting indices
        var winners: [Int] = [] // winner indices for myPlayers
        for w in winnerIndices
        {
            winners.append(bettingIndices[w])
        }
        
        if(winners.count == 1)
        {
            self.win(winner: winners[0])
        }
        else
        {
            self.split(winners: winners)
        }
    }
    
    // precondition: index of player in myPlayers
    // postcondition: full (7 card) hand of that player
    func getHand(index: Int) -> Hand
    {
        let card1: [Card] = [myPlayers[index].card1]
        let card2: [Card] = [myPlayers[index].card2]
        let currentCards: [Card] = myDeck.communityCards + card1 + card2
        let currentHand = Hand(eCardList: currentCards)
        return currentHand
    }
    
    func win(winner: Int)
    {
        myPlayers[winner].win(pot: pot)
        recentWinner = winner
        
        for i in 0..<myPlayers.count
        {
            if(i != winner)
            {
                myPlayers[i].lose()
            }
        }
        
        wasTie = false
    }
    
    func split(winners: [Int])
    {
        recentWinners.removeAll()
        let splitAmount = pot / winners.count
        for winner in winners
        {
            myPlayers[winner].win(pot: splitAmount)
            recentWinners.append(winner)
        }
        
        for i in 0..<myPlayers.count
        {
            if(!winners.contains(i))
            {
                myPlayers[i].lose()
            }
        }
        
        wasTie = true
    }
    
    func othersFolded() -> Bool
    {
        var totalFolded: Int = 0
        for current in myPlayers
        {
            if(!current.isBetting)
            {
				totalFolded += 1
            }
        }
        return totalFolded == myPlayers.count - 1;
    }
    
    // assumed only one player betting
    func remainingIndex() -> Int
    {
        for i in 0..<myPlayers.count
        {
            if(myPlayers[i].isBetting)
            {
                return i
            }
        }
        return -1
    }
    
    // tells whether all numbers in arraylist are equal (used to see if all bets are equal)
    func allEqualBets() -> Bool
    {
        var nums: [Int] = []
        for player in myPlayers
        {
            if(!player.allIn && player.isBetting)
            {
                nums.append(player.bet)
            }
        }
        for i in 0..<nums.count
        {
            for j in 1..<nums.count
            {
                if(nums[i] != nums[j])
                {
                    return false
                }
            }
        }
        return true
    }
    
    /*
      Returns sorted players by money high -> low (insertion sort)
    */
    func sortedPlayers() -> [Player]
    {
        var playerCopy: [Player] = []
        for player in myPlayers
        {
            playerCopy.append(player)
        }
        var key: Int = 0
        for index in 1..<playerCopy.count
        {
            let current: Player = playerCopy[index]
            key = index
            
            while(key > 0 && (playerCopy[key - 1].money < current.money))
            {
                key -= 1
            }
            playerCopy.insert(current, at: key)
            playerCopy.remove(at: index + 1)
        }
        return playerCopy
    }
    
    func kickZeros()
    {
        for i in (0..<myPlayers.count).reversed()
        {
            if(myPlayers[i].money <= 0)
            {
                myPlayers.remove(at: i)
            }
        }
    }
    
    
}
