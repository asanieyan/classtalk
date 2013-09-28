Info = {
    :name=>"UCSD",
    :nid=>"16777250",
    :city=>"la jolla",
    :region=>"california",    
    :country=>"united states",
    :semesters=>[

 
  ["Fall","9/20","12/25"],
  ["Winter","1/1","3/25"],
  ["Spring","3/26","6/13"],
  ["Summer I","7/2","8/4"],
  ["Summer II","8/6","9/10"],
  ["Summer Special","6/16","9/15"]


    ],
    :paths => [
      ["Fall","Winter","Spring","Summer Special"],
      ["Fall","Winter","Spring","Summer I","Summer II"]
    ]
}          
class UcsdParser < CourseParser
    def start
      
    end
end
