Info = {
    :name=>"UConn",
    :nid=>"16777307",
    :city=>"storrs mansfield",
    :region=>"connecticut",    
    :country=>"united states",
    :semesters=>[

  ["Fall","8/25","12/25"],
  ["Spring","1/1","5/6"],
  ["May Term","5/7","5/25"],
  ["Summer I","5/29","7/6"],
  ["Summer I Intens","6/4","6/22"],
  ["Summer II","7/9","8/17"],
  ["Summer II Intens","7/16","8/3"],
  ["Summer IV","5/29","8/17"]


    ],
    :paths => [
      ["Fall","Spring","May Term","Summer IV"],
      ["Fall","Spring","May Term","Summer I","Summer II"],
      ["Fall","Spring","May Term","Summer I Intens","Summer II Intens"]

    ]
}          
class UconnParser < CourseParser
    def start
      
    end
end
