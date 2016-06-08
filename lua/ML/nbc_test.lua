function print_r ( t )  
    local print_r_cache={}
    local function sub_print_r(t,indent)
        if (print_r_cache[tostring(t)]) then
            print(indent.."*"..tostring(t))
        else
            print_r_cache[tostring(t)]=true
            if (type(t)=="table") then
                for pos,val in pairs(t) do
                    if (type(val)=="table") then
                        print(indent.."["..pos.."] => "..tostring(t).." {")
                        sub_print_r(val,indent..string.rep(" ",string.len(pos)+8))
                        print(indent..string.rep(" ",string.len(pos)+6).."}")
                    elseif (type(val)=="string") then
                        print(indent.."["..pos..'] => "'..val..'"')
                    else
                        print(indent.."["..pos.."] => "..tostring(val))
                    end
                end
            else
                print(indent..tostring(t))
            end
        end
    end
    if (type(t)=="table") then
        print(tostring(t).." {")
        sub_print_r(t,"  ")
        print("}")
    else
        sub_print_r(t,"  ")
    end
    print()
end






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
  
 question = {"sunny", "hot", "high", "weak"}
 
  local c_domain = domains[#domains]
  
  for i,v in pairs(c_domain) do
    print("c_domain "..i,v)
  end
  
    -- By-category example counter.
  local cn = {}
  
  for i,v in pairs(training_set) do
    c = v[#v]
    cn[c] = cn[c] and cn[c]+1 or 1
  end
  
 
  
  for i,v in pairs(cn) do
    print("cn "..i,v)
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
  
  for i,v in pairs(cp) do
    print("cp "..i,v)
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
  
  
print_r(cavp)
  
  
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
  
  
  
  