-- ---------------------------------------------------------------------------------------------------------------------
-- Lua implementation of the Naive Bayes Classifier as described in the book Cichosz P.: Systemy uczące się. Wydawnictwa
-- Naukowo-Techniczne, Warszawa, 2007.
--
-- Copyright 2009 Janusz Kowalski
-- ---------------------------------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------
-- Module declaration
-----------------------------------------------------------------------------
local nbc = {}             -- Public namespace

function nbc.NaiveBayesClassifier( training_set, domains, question )

  ----------------------------------------------------------------------------------------------------------------------
  -- training_set - a set of labeled examples; {v1, v2, ...}, {v1, v2, ...}, ..., c }
  -- domains - { { v1_domain... }, { v2_domain... }, ... }
  -- question - {v1, v2, ..., vn }
  ----------------------------------------------------------------------------------------------------------------------
  
  local c_domain = domains[#domains]

  -- By-category example counter.
  local cn = {}
  
  for i,v in pairs(training_set) do
    c = v[#v]
    cn[c] = cn[c] and cn[c]+1 or 1
  end
  
  -- Set metatable for counters outside the range.
  local __cn = {
    __index = function(table, key)
      local v = rawget(table, key)
      if v ~= nil then return v else return 0 end
    end
  }

  -- Category probability.
  local cp = {}
  
  -- Calculate the actual probability.
  for c,n in pairs(cn) do
    cp[c] = (n + 1) / (#training_set + #c_domain)
    -- print('P( x(c) = ' .. c .. " ) = " .. cp[c])
  end
  
  -- Category, Argument, Value, Probability
  local cavp = {}
  
  -- Calculate counts for given attribute value for a given class.
  for ei,ac in ipairs(training_set) do
    local c = ac[#ac]
  
    for a,v in ipairs(ac) do
      -- Skip the last one.
      if a == #ac then break end
    
      -- Create table if necessary.
      cavp[c] = cavp[c] or {}
      
      -- Create table if necessary.
      cavp[c][a] = cavp[c][a] or {}
      
      -- Update count.
      cavp[c][a][v] = cavp[c][a][v] and cavp[c][a][v] + 1 or 1
    end
  end
  
  -- Calculate the actual probabilities.
  for c,avp in pairs(cavp) do
    for a,vp in pairs(avp) do
      for v,p in pairs(vp) do
        cavp[c][a][v] = (p + 1) / (cn[c] + #domains[a])
      end
    end
  end
  
  -- Use calculated probabilities to find the most probable category.
  local p_best = 0
  
  for i,c in pairs(c_domain) do
    local p = cp[c] or 1 / (#training_set + #c_domain)
    for a,v in pairs(question) do
      local pp = cavp[c][a][v] or 1 / (cn[c] + #domains[a])
      p = p * pp
    end
    
    print(c, p)
  end
  
end

return nbc