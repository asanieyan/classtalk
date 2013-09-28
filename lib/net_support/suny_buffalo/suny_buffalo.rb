Info = {
    :name=>"SUNY Buffalo",
    :nid=>"16777374",
    :city=>"buffalo",
    :region=>"new york",    
    :country=>"united states",
    :semesters=>[

  ["Fall","8/25","12/25"],
  ["Spring","1/1","5/12"],
  ["Summer I","5/15","6/27"],
  ["Summer II","6/23","8/1"],
  ["Summer III","6/24","8/12"],
  ["Summer 9WK-L","5/15","7/22"],
  ["Summer 10WK-A","5/15","7/25"],
  ["Summer 12WK-I","5/15","8/12"]


    ],
    :paths => [
      ["Fall","Spring","Summer I"],
      ["Fall","Spring","Summer II"],
      ["Fall","Spring","Summer III"],
      ["Fall","Spring","Summer 9WK-L"],
      ["Fall","Spring","Summer 10WK-A"],
      ["Fall","Spring","Summer 12WK-I"]
   
    ]
}          
class SunyBuffaloParser < CourseParser
    def start
      
    end
end
