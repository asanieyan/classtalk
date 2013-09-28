Info = {
    :name=>"Syracuse",
    :nid=>"16777272",
    :city=>"syracuse",
    :region=>"new york",    
    :country=>"united states",
    :semesters=>[

	  ["Fall","8/25", "12/25"],
	  ["Spring","1/5", "5/10"],  
	  ["Maymester","5/11", "5/23"],
	  ["Summer I","5/19", "6/27"] ,
	  ["Summer Comb","5/19", "8/8"] ,
	  ["Summer II","6/30", "8/3"] 

    ],
    :paths => [
      ["Fall","Spring","Maymester"],
      ["Fall","Spring","Summer I","Summer II"],
      ["Fall","Spring","Summer Comb"]
]
}          
class SyracuseParser < CourseParser
    def start
      
    end
end
