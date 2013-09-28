Info = {
    :name=>"JMU",
    :nid=>"16777295",
    :city=>"harrisonburg",
    :region=>"virginia",    
    :country=>"united states",
    :semesters=>[
	  ["Fall","8/25", "12/20"],
	  ["Spring","1/5", "5/5"],
	  ["Summer 10WK","5/12", "7/18"] ,
	  ["Summer 8WK","5/12", "7/4"], 
	  ["Summer 6WK","6/9", "7/18"] ,
	  ["Summer 4WK1","5/12", "6/6"] ,
	  ["Summer 4WK2","6/9", "7/4"] ,
	  ["Summer 12WK","5/12", "8/1"] ,
	  ["Summer 8WK Grad","6/9", "8/1"], 
	  ["Summer 6WK1 Grad","5/12", "6/20"], 
	  ["Summer 6WK2 Grad","6/23", "8/1"]  
    ],
    :paths => [
	      ["Fall","Spring","Summer 10WK"],
	      ["Fall","Spring","Summer 8WK"],      
	      ["Fall","Spring","Summer 6WK"],      
	      ["Fall","Spring","Summer 4WK1","Summer 4WK2"],      
	      ["Fall","Spring","Summer 12WK"],      
	      ["Fall","Spring","Summer 8WK Grad"],      
	      ["Fall","Spring","Summer 6WK1 Grad","Summer 6WK2 Grad"],      
	      ["Fall","Spring","Summer 4WK1 Grad","Summer 4WK2 Grad"]
    ]
}          
class JmuParser < CourseParser
    def start
      
    end
end
