Info = {
    :name=>"East Carolina",
    :nid=>"16777439",
    :city=>"greenville",
    :region=>"north carolina",    
    :country=>"united states",
    :semesters=>[

  ["Fall","8/20", "12/25"],
  ["Spring","1/10", "5/10"],
  ["Summer I","5/15", "6/24"], 
  ["Summer II","6/26", "8/1"],  
  ["Summer 11WK","5/20", "8/5"]  
    ],
    :paths=>[
	["Fall","Spring","Summer I","Summer II"],
	["Fall","Spring","Summer 11WK"]
    ]
}          
class EastCarolinaParser < CourseParser
    def start
      
    end
end
