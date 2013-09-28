Info = {
    :name=>"UNC",
    :nid=>"16777244",
    :city=>"chapel hill",
    :region=>"north carolina",    
    :country=>"united states",
    :semesters=>[
        
        ["Fall","8/20","12/25"],
        ["Spring","1/1","5/7"],
        ["Summer 1","5/12","6/12"],
        ["Summer 2","6/18","7/21"],
        ["Maymester","5/13","5/29"]

    ],
    :paths => [
      ["Fall","Spring","Summer 1","Summer 2"],
      ["Fall","Spring","Maymester"]
    ]
}          
class UncParser < CourseParser
    def start
      
    end
end
