Info = {
    :name=>"Missouri",
    :nid=>"16777376",
    :city=>"columbi",
    :region=>"missouri",    
    :country=>"united states",
    :semesters=>[

      
        ["Fall","8/20","12/25"],
        ["Spring","1/1","5/16"],
        ["Summer 8WK","6/9","8/1"],
        ["Summer 4WK1","6/9","7/3"],
        ["Summer 4WK2","7/7","8/1"]


    ],
    :paths => [
       ["Fall","Spring","Summer 8WK"],
       ["Fall","Spring","Summer 4WK1"],
       ["Fall","Spring","Summer 4WK2"]
    ]
}          
class MissouriParser < CourseParser
    def start
      
    end
end
