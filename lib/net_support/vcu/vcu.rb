Info = {
    :name=>"VCU",
    :nid=>"16777472",
    :city=>"richmond",
    :region=>"virginia",    
    :country=>"united states",
    :semesters=>[

      ["Fall","8/23","12/25"],
      ["Spring","1/10","5/10"],
      ["Summer 3WK1","5/19","6/6"],
      ["Summer 5WK1","5/19","6/19"],
      ["Summer 8WK","5/19","7/10"],
      ["Summer 4.5WK1","6/9","7/9"],      
      ["Summer 6WK","6/9","7/17"],      
      ["Summer 5WK2","6/23","7/24"],
      ["Summer 4.5WK2","7/10","8/8"],
      ["Summer 3WK2","7/21","8/8"]
    ],
    :paths => [
      ["Fall","Spring","Summer 3WK1","Summer 3WK2"],
      ["Fall","Spring","Summer 5WK1","Summer 5WK2"],
      ["Fall","Spring","Summer 8WK"],
      ["Fall","Spring","Summer 6WK"],
      ["Fall","Spring","Summer 4.5WK1","Summer 4.5WK2"]
    ]
}          
class VcuParser < CourseParser
    def start
      
    end
end
