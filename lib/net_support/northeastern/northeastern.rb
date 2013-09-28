Info = {
    :name=>"Northeastern",
    :nid=>"16777235",
    :city=>"boston",
    :region=>"massachusetts",    
    :country=>"united states",
    :semesters=>[

	  ["Fall","9/5", "12/25"],
	  ["Spring","1/8", "5/1"],
	  ["Summer I","5/5", "6/27"],
	  ["Summer II","6/29", "8/23"]   

    ]
}          
class NortheasternParser < CourseParser
    def start
      
    end
end
