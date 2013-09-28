Info = {
    :name=>"UVA",
    :nid=>"16777232",
    :city=>"charlottesville",
    :region=>"virginia",    
    :country=>"united states",
    :semesters=>[

  ["Fall","8/25","12/25"],
  ["Spring","1/1","5/11"],
  ["Summer I","5/12","6/11"],
  ["Summer II","6/12","7/10"],
  ["Summer III","7/12","8/12"],
  ["Summer 9WK","6/12","8/12"]


    ],
    :paths => [
     ["Fall","Spring","Summer 9WK"],
     ["Fall","Spring","Summer I","Summer II","Summer III"]
    ]
}          
class UvaParser < CourseParser
    def start
      
    end
end
