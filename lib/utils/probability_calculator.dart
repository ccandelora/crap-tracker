class ProbabilityCalculator {
  // Static probabilities for dice total (2 dice)
  static final Map<int, double> diceRollProbability = {
    2: 1/36,   // 1 way to get 2 (1+1)
    3: 2/36,   // 2 ways to get 3 (1+2, 2+1)
    4: 3/36,   // 3 ways to get 4 (1+3, 2+2, 3+1)
    5: 4/36,   // 4 ways to get 5 (1+4, 2+3, 3+2, 4+1)
    6: 5/36,   // 5 ways to get 6 (1+5, 2+4, 3+3, 4+2, 5+1)
    7: 6/36,   // 6 ways to get 7 (1+6, 2+5, 3+4, 4+3, 5+2, 6+1)
    8: 5/36,   // 5 ways to get 8 (2+6, 3+5, 4+4, 5+3, 6+2)
    9: 4/36,   // 4 ways to get 9 (3+6, 4+5, 5+4, 6+3)
    10: 3/36,  // 3 ways to get 10 (4+6, 5+5, 6+4)
    11: 2/36,  // 2 ways to get 11 (5+6, 6+5)
    12: 1/36   // 1 way to get 12 (6+6)
  };

  // Get the standard probability for a specific dice total
  static double getBasicProbability(int total) {
    return diceRollProbability[total] ?? 0;
  }

  // Get a probability based on historical rolls
  static double getHistoricalProbability(int total, List<int> historicalRolls) {
    if (historicalRolls.isEmpty) {
      return getBasicProbability(total);
    }
    
    int occurrences = historicalRolls.where((roll) => roll == total).length;
    return occurrences / historicalRolls.length;
  }

  // Combine standard and historical probabilities
  static double getCombinedProbability(int total, List<int> historicalRolls) {
    double basicProb = getBasicProbability(total);
    
    if (historicalRolls.isEmpty) {
      return basicProb;
    }
    
    double historicalProb = getHistoricalProbability(total, historicalRolls);
    
    // Weight historical data more as we get more rolls
    double historicalWeight = 0.5;
    if (historicalRolls.length > 100) {
      historicalWeight = 0.7;
    } else if (historicalRolls.length > 50) {
      historicalWeight = 0.6;
    }
    
    return (basicProb * (1 - historicalWeight)) + (historicalProb * historicalWeight);
  }
  
  // Get probabilities for all possible totals
  static Map<int, double> getAllProbabilities(List<int> historicalRolls) {
    Map<int, double> results = {};
    
    for (int i = 2; i <= 12; i++) {
      results[i] = getCombinedProbability(i, historicalRolls);
    }
    
    return results;
  }
} 