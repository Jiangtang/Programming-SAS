/*Roberto Ierusalimschy Programming in Lua*/
proc lua;
    submit;
        --8 basic types
        --nil, boolean, number, string, userdata,function, thread, and table

        print(type(nil)) --> nil
        print(type(a)) --> nil
        print(type(true)) --> boolean
        print(type(10.4*3)) --> number
        print(type("Hello world")) --> string
        print(type(type(X))) --> string   
 
                             -->userdata 

        print(type(print)) --> function
        print(type(type)) --> function        
        print(type(print)) --> function

                             -->thread

        local shoppinglist = {'milk', 'flour', 'eggs', 'sugar'}
        print(type(shoppinglist)) --> table
    endsubmit;
quit;

