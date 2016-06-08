/*
http://lonelydeveloper.org/workspace/projects/misc/nbc.lua
*/


proc lua infile="nbc" restart;
    submit;

    nbc = require('nbc')

    training_set = {
  { "sunny", "hot", "high", "weak", 0 },
  { "sunny", "hot", "high", "strong", 0 },
  { "cloudy", "hot", "high", "weak", 1 },
  { "rainy", "temperate", "high", "weak", 1 },
  { "rainy", "cold", "normal", "weak", 1 },
  { "rainy", "cold", "normal", "strong", 0 },
  { "cloudy", "cold", "normal", "strong", 1 },
  { "sunny", "temperate", "high", "weak", 0 },
  { "sunny", "cold", "normal", "weak", 1 },
  { "rainy", "temperate", "normal", "weak", 1 },
  { "sunny", "temperate", "normal", "strong", 1 },
  { "cloudy", "temperate", "high", "strong", 1 },
  { "cloudy", "hot", "normal", "weak", 1 },
  { "rainy", "temperate", "high", "strong", 0 }
}

domains = {
  { "sunny", "cloudy", "rainy" },
  { "hot", "temperate", "cold" },
  { "high", "normal" },
  { "weak", "strong" },
  { 0, 1 }
}



    print( nbc.NaiveBayesClassifier(training_set, domains, {"sunny", "hot", "high", "weak"}) )

    print('--')

    print( nbc.NaiveBayesClassifier(training_set, domains, {"rainy", "temperate", "high", "weak"}) )

    endsubmit;
run;


