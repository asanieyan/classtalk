Info = {
    :name=>"WVU",
    :nid=>"16777475",
    :city=>"morgantown",
    :region=>"west virginia",    
    :country=>"united states",
    :semesters=>[
      
        ["Fall","8/20","12/25"],
        ["Spring","1/1","5/15"],
        ["Summer 6WK","5/19","7/3"],
        ["Summer 12WK","5/19","8/12"]    

    ],
    :paths => [
      ["Fall","Spring","Summer 6WK"],
      ["Fall","Spring","Summer 12WK"]
    ]
}          
class WvuParser < CourseParser
    def start
      
    end
end
