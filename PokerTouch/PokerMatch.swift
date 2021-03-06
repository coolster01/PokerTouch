//
//  PokerMatch.swift
//  
//
//  Created by Subhi Sbahi on 5/27/17.
//
//

import Foundation

class PokerMatch {
    
    var myHands: [Hand] = []
    
    init(hands: [Hand])
    {
        myHands = hands
    }
    
    // returns index of winner (almost always will return 1 int, unless there is a tie)
    func determineWinner() -> [Int]
    {
        var handScores: [Int] = []
        for hand in myHands
        {
            handScores.append(hand.score)
        }
        
        let myMaxIndices: [Int] = maxIndices(scores: handScores)
        
        if(myMaxIndices.count == 1) // no equal scores (clear winner)
        {
            return myMaxIndices // will return just that one value
        }
        else // equal scores
        {
            var tiedHands: [Hand] = []
            for i in myMaxIndices
            {
                tiedHands.append(myHands[i])
            }
            
            var valuesInvolved: [[Int]] = []
            for hand in tiedHands
            {
                valuesInvolved.append(hand.valuesInvolved) // add arrays of
            }
            
            var i: Int = 0
            
            var currentMaxIndices: [Int] = []
            for i in 0..<valuesInvolved[0].count // goes up to size of values involved array (same for each array)
            {
                var currentIndexVals: [Int] = [] // will contain valuesInvolved at current index (i) for each hand
                // i.e. if i = 0 [5, 3, 2, 1, 1] [6, 3, 2, 1, 1] [8, 3, 2, 2, 2] -> [5, 6, 8]
                
                for hand in valuesInvolved
                {
                    currentIndexVals.append(hand[i])
                }
                
                currentMaxIndices = maxIndices(scores: currentIndexVals) // would return [2] in above case 
                //(no ties based on first value involved)
                
                if(currentMaxIndices.count == 1)
                {
                    return currentMaxIndices // will return just that one value
                }
                // else continue
                
            }
            return currentMaxIndices // actual tie game (pot split)
        }
    }
    
    // returns indices of max score (may be more than one)
    func maxIndices(scores: [Int]) -> [Int]
    {
        var maxIndices: [Int] = [0]
        for i in 1..<scores.count
        {
            if(scores[i] > scores[maxIndices[0]])
            {
                maxIndices.removeAll()
                maxIndices.append(i)
            }
            else if (scores[i] == scores[maxIndices[0]])
            {
                maxIndices.append(i)
            }
        }
        return maxIndices
    }
    
}
