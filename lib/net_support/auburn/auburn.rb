Info = {
    :name=>"Auburn",
    :nid=>"16777287",
    :city=>"auburn university",
    :region=>"alabama",    
    :country=>"united states",
    :semesters=>[

  ["Fall","8/16","12/25"],
  ["Spring","1/1","5/10"],
  ["Summer Full","5/20","8/10"],
  ["Summer I","5/20","6/29"],
  ["Summer I Ext","5/16","6/27"],
  ["Summer II","6/30","8/10"]


    ],
    :paths => [
      ["Fall","Spring","Summer Full"],
      ["Fall","Spring","Summer I","Summer II"],
      ["Fall","Spring","Summer I Ext","Summer II"]
    ]
}          
class AuburnParser < CourseParser
    def start
      
    end
end
