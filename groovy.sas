
/*http://blog.willmakeaplan.com/?p=18*/
/*http://blog.willmakeaplan.com/?p=13*/

/*

options nosource;

proc groovy;
	submit;
		import groovy.json.*

		def input=new File('a:\\test\\test.json').text
		def output = new JsonSlurper().parseText(input)

		println output	
		println ""
		output.each {println it}	

		println ""

		println output.address.streetAddress
		println "Street Address: $output.address.streetAddress"
		println output.address["streetAddress"]		


		exports = [fName1:output['firstName']]	
		exports.put('fName2', output['firstName'])
		
	
	endsubmit;
quit;

%put fName1: &fName1;
%put fName2: &fName2;

































options nosource;

proc groovy;
	submit;
		import groovy.json.*

		def input=new File('a:\\test\\person.json').text
		def output = new JsonSlurper().parseText(input)

		println output	
		println ""
		output.each {println it}	

		println ""

		println output.address.streetAddress
		println "Street Address: $output.address.streetAddress"
		println output.address["streetAddress"]		

		exports.putAt('fName1',output['firstName'])
		exports = [fName2:output['firstName']]	
		exports.put('fName3', output['firstName'])
	
	endsubmit;
quit;


%put fName1: &fName1;
%put fName2: &fName2;
%put fName3: &fName3;
*/

proc groovy;
	submit;
		import groovy.json.JsonSlurper
		def result = new JsonSlurper().parseText(new File('a:\\test\\person.json').text)

		println result	
		println ""
		result.each {println it}	
	
	endsubmit;
quit;

proc groovy;
	submit;
		import groovy.json.JsonSlurper
		def result = new JsonSlurper().parseText(new File('a:\\test\\person.json').text)	
		
		exports.putAt('firstName',result['firstName'])
		exports.putAt('lastName' ,result['lastName'])	
		
	endsubmit;
quit;

%put &firstName;
%put &lastName;


proc groovy;
	submit;
		import groovy.json.JsonSlurper
		def result = new JsonSlurper().parseText(new File('a:\\test\\person.json').text)	

		println result.address.streetAddress

		println ""

		println "Street Address: $result.address.streetAddress"

		println ""

		println result.address["streetAddress"]		
		
	endsubmit;
quit;

proc groovy;
	submit;
		import groovy.json.JsonSlurper
		def result = new JsonSlurper().parseText(new File('a:\\test\\person.json').text)	

		println result.address.size()	
		println result.address[0]	
		
	endsubmit;
quit;











/*xml*/

proc groovy;
	submit;

		def customers = new XmlSlurper().parse(new File('C:\\Users\\jhu\\Documents\\GitHub\\Programming-SAS\\customers.xml'))
		for (customer in customers.corporate.customer)
		{
		println "${customer.@name} works for ${customer.@company}"
		}
	endsubmit;
quit;



/*hello world*/

proc groovy;
	submit;
		println System.getProperty("user.dir");

		String curDir = System.getProperty("user.dir");
		println "$curDir"

	endsubmit;
quit;


proc groovy;
	submit;
		def name='World'; 
		println "Hello $name!"
	endsubmit;
quit;


proc groovy;
	submit;
		class Greet {
		  def name
		  Greet(who) { name = who[0].toUpperCase() +
		                      who[1..-1] }
		  def salute() { println "Hello $name!" }
		}

		g = new Greet('world')  // create object
		g.salute()               // output "Hello World!"
	endsubmit;
quit;

/*test*/

proc groovy;
	submit;

def classes = [String, List, File]
for (clazz in classes)
{
println clazz.'package'.name
}
	endsubmit;
quit;

proc groovy;
	submit;
println( [String, List, File].'package'.name )
	endsubmit;
quit;

