Info = {
    :name=>"UC Irvine",
    :nid=>"16777277",
    :city=>"irvine",
    :region=>"california",    
    :country=>"united states",
    :semesters=>[

  
  ["Fall","9/20","12/25"],
  ["Winter","1/1","3/23"],
  ["Spring","3/24","6/16"],
  ["Summer I","6/18","7/30"],
  ["Summer 10WK","6/18","8/30"],
  ["Summer II","8/4","9/12"]

    ],
    :paths => [
     ["Fall","Winter","Spring","Summer 10WK"],
     ["Fall","Winter","Spring","Summer I","Summer II"]
    ]
}          
class UcIrvineParser < CourseParser
    def start
      
    end
end
