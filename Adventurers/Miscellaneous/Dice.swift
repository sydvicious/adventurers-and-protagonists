//
//  Dice.swift
//  Adventurers
//
//  Created by Syd Polk on 3/10/25.
//  Copyright ©2025 Syd Polk. All rights reserved.
//

import Foundation

class Dice {
    static func rawRoll(dieType: Int) -> Int {
        return Int(arc4random_uniform(UInt32(dieType)) + 1)
    }

    static func roll(number: Int, dieType: Int, bonus: Int = 0, best: Int = 0) -> Int {
        var rolls = self.rolls(number: number, dieType: dieType)
        if best > 0 && best < number {
            let slice = rolls[0..<best]
            rolls = Array(slice)
        }

        return rolls.reduce(0 , +) + bonus
    }

    static func rolls(number: Int, dieType: Int, sorted : Bool = false) -> [Int] {
        var rolls : [Int] = []
        
        for _ in 1...number {
            rolls.append(rawRoll(dieType: dieType))
        }

        if (sorted) {
            rolls = rolls.sorted()
        }
        return rolls
    }
    
    static func value(from rolls: [Int], bonus: Int = 0, best: Int = 0) -> Int {
        let staging: [Int]
        if best > 0 && best < rolls.count {
            let sorted = rolls.sorted(by: >)
            let slice = sorted[0..<best]
            staging = Array(slice)
        } else {
            staging = rolls
        }
        return staging.reduce(0 , +) + bonus
    }
        
    static func miminumIndex(from rolls: [Int]) -> Int {
        var minIndex = -1
        var minValue = Int.max
        
        var index = 0
        while (index < rolls.count) {
            if (rolls[index] < minValue) {
                minIndex = index
                minValue = rolls[index]
            }
            index += 1
        }
        return minIndex
    }
    
    static func d6ImageName(_ value: Int) -> String? {
        if value == 1 {
            return "d6w1"
        }
        
        if value == 2 {
            return "d6w2"
        }
        
        if value == 3 {
            return "d6w3"
        }
        
        if value == 4 {
            return "d6w4"
        }
        
        if value == 5 {
            return "d6w5"
        }
        
        if value == 6 {
            return "d6w6"
        }
        
        return nil
    }
}
