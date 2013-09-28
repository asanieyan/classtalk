Info = {
    :name=>"Western Michigan",
    :nid=>"16777338",
    :city=>"kalamazoo",
    :region=>"michigan",    
    :country=>"united states",
    :semesters=>[

  
  ["Fall","9/1","12/25"],
  ["Spring","1/1","5/1"],
  ["Summer I","5/4","6/30"],
  ["Summer II","6/25","8/20"]

    ],
    :paths => [
     ["Fall","Spring","Summer I"],
     ["Fall","Spring","Summer II"]
    ]
}          
class WesternMichiganParser < CourseParser
    def start
      
    end
end
