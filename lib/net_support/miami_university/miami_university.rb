Info = {
    :name=>"Miami University",
    :nid=>"16777294",
    :city=>"oxford",
    :region=>"ohio",    
    :country=>"united states",
    :semesters=>[

        ["Fall","8/23","12/25"],
        ["Spring","1/1","5/12"],
        ["Summer I","5/14","6/28"],
        ["Summer II","6/11","7/18"],
        ["Summer III","6/25","8/9"],
        ["Summer IV","7/15","8/22"]

    ],
    :paths => [
        ["Fall","Spring","Summer I"],
    	 ["Fall","Spring","Summer II"],
    	 ["Fall","Spring","Summer III"],
    	 ["Fall","Spring","Summer IV"]

       
    ]
}          
class MiamiUniversityParser < CourseParser
    def start
      
    end
end
