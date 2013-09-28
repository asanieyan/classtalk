Info = {
    :name=>"Kansas State",
    :nid=>"16777387",
    :city=>"manhattan",
    :region=>"kansas",    
    :country=>"united states",
    :semesters=>[

  ["Fall","8/20","12/25"],
  ["Spring","1/1","5/8"],
  ["Summer","5/17","8/13"],
  ["Summer Inter","7/1","8/17"]

    ],
    :paths => [
      ["Fall","Spring","Summer"],
      ["Fall","Spring","Summer Inter"]
    ]
}          
class KansasStateParser < CourseParser
    def start
      
    end
end
