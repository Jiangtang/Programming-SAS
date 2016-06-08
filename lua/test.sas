proc lua  restart infile="m";
    submit;
	local m =  require('m')


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
local c_domain = domains[#domains]
print("c_domain")
m.print3(c_domain)

  local cn = {}
  
  for i,v in pairs(training_set) do
    c = v[#v]
	--m.print3(c)
    cn[c] = cn[c] and cn[c]+1 or 1
  end

print("cn")
m.print3(cn)

  -- Category probability.
  local cp = {}
  
  print(#training_set , #c_domain)
  -- Calculate the actual probability.
  for c,n in pairs(cn) do
    cp[c] = (n + 1) / (#training_set + #c_domain)
    print('P( x(c) = ' .. c .. " ) = " .. cp[c])
  end

  print("cp")
m.print3(cp)

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

    print("cavp")
m.print3(cavp)

    endsubmit;
run;

