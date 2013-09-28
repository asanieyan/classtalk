Info = {
    :name=>"Iowa State",
    :nid=>"16777386",
    :city=>"ames",
    :region=>"iowa",    
    :country=>"united states",
    :semesters=>[

  ["Fall","8/20","12/25"],
  ["Spring","1/1","5/12"],
  ["Summer I","5/15","7/12"],
  ["Summer II","6/14","8/10"]

    ],
    :paths => [
      ["Fall","Spring","Summer I"],
      ["Fall","Spring","Summer II"]
    ]
}          
class IowaStateParser < CourseParser
    def start
      
    end
end
