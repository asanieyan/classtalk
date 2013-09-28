Info = {
    :name=>"Wisconsin Milwaukee",
    :nid=>"16777484",
    :city=>"milwaukee",
    :region=>"wisconsin",    
    :country=>"united states",
    :semesters=>[

  ["Semester I","9/1", "12/20"],
  ["Semester II","1/5", "5/25"],
  ["Summer 3WK","5/29", "6/20"] ,
  ["Summer 4WK1","5/25", "6/23"] ,  
  ["Summer 4WK2","6/25", "7/21"] ,
  ["Summer 4WK3","7/23", "8/18"] ,
  ["Summer 6WK1","5/29", "7/10"] ,
  ["Summer 6WK2","6/11", "7/24"] ,
  ["Summer 6WK3","6/25", "8/6"] ,
  ["Summer 6WK4","7/9", "8/20"] ,
  ["Summer 8WK","6/25", "8/20"] ,
  ["Summer 12WK","5/29", "8/20"] 
  
  ],
    :paths => [
      ["Semester I","Semester II","Summer 3WK"],
      ["Semester I","Semester II","Summer 4WK1","Summer 4WK2","Summer 4WK3"],    
      ["Semester I","Semester II","Summer 6WK1"],
      ["Semester I","Semester II","Summer 6WK2"],
      ["Semester I","Semester II","Summer 6WK3"],
      ["Semester I","Semester II","Summer 6WK4"],
      ["Semester I","Semester II","Summer 8WK"],
      ["Semester I","Semester II","Summer 12WK"]
]
}          
class WisconsinMilwaukeeParser < CourseParser
    def start
      
    end
end
