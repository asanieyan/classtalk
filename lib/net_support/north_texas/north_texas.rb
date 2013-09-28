Info = {
    :name=>"North Texas",
    :nid=>"16777456",
    :city=>"denton",
    :region=>"texas",    
    :country=>"united states",
    :semesters=>[

  ["Fall","8/25","12/25"],
  ["Spring","1/1","5/10"],
  ["Summer","5/11","8/12"],
  ["Summer 3WK1","5/11","5/31"],
  ["Summer 8WK1","5/11","7/5"],
  ["Summer 5WK1","6/2","7/3"],
  ["Summer 10WK","6/2","8/12"], 
  ["Summer 5WK2","7/6","8/12"]




    ],
    :paths => [
      ["Fall","Spring","Summer"],
      ["Fall","Spring","Summer 3WK1"],
      ["Fall","Spring","Summer 5WK1","Summer 5WK2"],
      ["Fall","Spring","Summer 8WK1"],
      ["Fall","Spring","Summer 10WK"]



    ]
}          
class NotrhTexasParser < CourseParser
    def start
      
    end
end
