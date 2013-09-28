Info = {
    :name=>"Pittsburgh",
    :nid=>"16777359",
    :city=>"pittsburgh",
    :region=>"pennsylvania",    
    :country=>"united states",
    :semesters=>[

  ["Fall","9/1","12/25"],
  ["Spring","1/1","5/3"],
  ["Summer 4WK1","5/12","6/7"],
  ["Summer 4WK2","6/9","7/4"],
  ["Summer 4WK3","7/7","8/8"],
  ["Summer 6WK1","5/12","6/21"],
  ["Summer 6WK2","6/23","8/8"],
  ["Summer 12WK","5/12","8/8"],
  ["Summer Term","5/5","8/15"]

    ],
    :paths => [
     ["Fall","Spring","Summer 4WK1","Summer 4WK2","Summer 4WK3"],
     ["Fall","Spring","Summer 6WK1","Summer 6WK2"],
     ["Fall","Spring","Summer 12WK"],
     ["Fall","Spring","Summer Term"],


    ]
}          
class PittsburghParser < CourseParser
    def start
      
    end
end
