Info = {
    :name=>"Oklahoma",
    :nid=>"16777313",
    :city=>"norman",
    :region=>"oklahoma",    
    :country=>"united states",
    :semesters=>[

  ["Fall","8/20","12/25"],
  ["Spring","1/1","5/9"],
  ["Summer 8WK","6/1","8/5"],
  ["Summer I","6/1","7/1"],
  ["Summer II","7/2","8/5"]

    ],
    :paths => [
    ["Fall","Spring","Summer 8WK"],
    ["Fall","Spring","Summer I","Summer II"]
    ]
}          
class OklahomaParser < CourseParser
    def start
      
    end
end
