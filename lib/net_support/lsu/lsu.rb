Info = {
    :name=>"LSU",
    :nid=>"16777451",
    :city=>"baton rouge",
    :region=>"louisiana",    
    :country=>"united states",
    :semesters=>[
      
        ["Fall","8/25","12/25"],
        ["Spring","1/1","5/10"],
        ["Summer A","6/9","7/31"],
        ["Summer B","6/30","8/2"],
        ["Summer Intersession","8/4","8/20"]

    ],
    :paths => [
     ["Fall","Spring","Summer A"],
     ["Fall","Spring","Summer B"],
     ["Fall","Spring","Summer Intersession"]
    ]
}          
class LsuParser < CourseParser
    def start
      
    end
end
