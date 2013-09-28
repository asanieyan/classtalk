Info = {
    :name=>"ASU",
    :nid=>"16777317",
    :city=>"tempe",
    :region=>"arizona",    
    :country=>"united states",
    :semesters=>[
    
      ["Fall","8/20","12/25"],
      ["Spring","1/1","5/10"],
      ["Summer 1 5WK","6/2","7/4"],
      ["Summer 1 8WK","6/2","7/25"],
      ["Summer 2 5WK","7/7","8/8"]

   

 ],
    :paths => [
      ["Fall","Spring","Summer 1 5WK"],
      ["Fall","Spring","Summer 1 8WK"],
      ["Fall","Spring","Summer 2 5WK"]
    ]
}          
class AsuParser < CourseParser
    def start
      
    end
end
