Info = {
    :name=>"UCF",
    :nid=>"16777268",
    :city=>"orlando",
    :region=>"florida",    
    :country=>"united states",
    :semesters=>[

  ["Fall","8/20","12/25"],
  ["Spring","1/1","5/1"],
  ["Summer A ","5/12","6/20"],
  ["Summer B","6/23","8/1"],
  ["Summer C","5/12","8/1"],
  ["Summer D","5/12","7/11"]

    ],
    :paths => [
      ["Fall","Spring","Summer A", "Summer B"],
      ["Fall","Spring","Summer C"],
      ["Fall","Spring","Summer D"]

    ]
}          
class UcfParser < CourseParser
    def start
      
    end
end
