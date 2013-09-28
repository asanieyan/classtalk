Info = {
    :name=>"FSU",
    :nid=>"16777269",
    :city=>"tallahassee",
    :region=>"florida",    
    :country=>"united_states",
    :semesters=>[
    
      ["Fall","8/20", "12/25"],  
      ["Spring","1/1", "5/1"],
      ["Summer A","5/9", "8/5"],
      ["Summer B","5/9", "6/18"],
      ["Summer C","6/24", "8/5"],
      ["Summer D","6/18", "8/13"]


    ],
    :paths => [
      ["Fall","Spring","Summer A"],
      ["Fall","Spring","Summer B"],
      ["Fall","Spring","Summer C"],
      ["Fall","Spring","Summer D"]
 
    ]
}          
class FsuParser < CourseParser
    def start
      
    end
end
