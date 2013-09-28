Info = {
    :name=>"Kent State",
    :nid=>"16777450",
    :city=>"kent",
    :region=>"ohio",    
    :country=>"united states",
    :semesters=>[

  ["Fall","8/25","12/25"],
  ["Spring","1/1","5/14"],
  ["Summer Inter ","5/18","6/11"],
  ["Summer I","6/9","7/18"],
  ["Summer II","6/9","8/8"],
  ["Summer III","7/14","8/22"]


    ],
    :paths => [
      ["Fall","Spring","Summer Inter"],
      ["Fall","Spring","Summer I"],
      ["Fall","Spring","Summer II"],
      ["Fall","Spring","Summer III"]
    ]
}          
class KentStateParser < CourseParser
    def start
      
    end
end
