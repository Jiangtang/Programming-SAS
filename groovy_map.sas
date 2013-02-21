/*https://github.com/seven1m/openwar/wiki/Map.json*/

proc groovy;
	submit;
		import groovy.json.JsonSlurper
		def map = new JsonSlurper().parseText(new File('c:\\users\\jhu\\map.json').text)
		println map
	endsubmit;
quit;

proc groovy;
	submit;
		import groovy.json.JsonSlurper
		def map = new JsonSlurper().parseText(new File('c:\\users\\jhu\\map.json').text)
		map.each {println it}		
	endsubmit;
quit;

proc groovy;
	submit;
		import groovy.json.JsonSlurper
		import groovy.json.JsonBuilder
		def map = new JsonSlurper().parseText(new File('c:\\users\\jhu\\map.json').text)

		def tree
		tree = { -> return [:].withDefault{ tree() } }

		map = tree()

		println new groovy.json.JsonBuilder( map ).toPrettyString()

	endsubmit;
quit;






proc groovy;
	submit;
		import groovy.json.JsonSlurper
		def result = new JsonSlurper().parseText(new File('a:\\test\\person.json').text)	
		
		exports.putAt('bonusRegions',result['bonusRegions.southeast'])
		exports.putAt('regions' ,result['regions'])	
		
	endsubmit;
quit;

%put &bonusRegions;
%put &regions;


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
		
	endsubmit;
quit;
