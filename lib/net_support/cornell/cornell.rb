Info = {
    :name=>"Cornell",
    :nid=>"16777221",
    :city=>"ithaca",
    :region=>"new york",    
    :country=>"united states",
    :semesters=>[

        ["Fall","8/20","12/25"],
        ["Spring","1/1","5/20"],
        ["Summer 3WK","5/28","6/20"],
        ["Summer 6WK","6/23","8/5"],
        ["Summer 8WK","6/9","8/5"]


    ],
    :paths => [
      ["Fall","Spring","Summer 3WK"],
      ["Fall","Spring","Summer 6WK"],
      ["Fall","Spring","Summer 8WK"]
   ]
}          

class CornellParser < CourseParser
    def start
    
    end
end