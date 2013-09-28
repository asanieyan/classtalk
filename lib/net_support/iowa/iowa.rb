Info = {
    :name=>"Iowa",
    :nid=>"16777365",
    :city=>"iowa city",
    :region=>"iowa",    
    :country=>"united states",
    :semesters=>[

      
      ["Fall","9/25","12/25"],
      ["Spring","1/1","5/16"],
      ["Summer 3WK","5/19","6/6"],
      ["Summer 8WK","6/10","8/5"],
      ["Summer 6WK","6/24","8/5"]

    ],
    :paths => [
       ["Fall","Spring","Summer 3WK"],
       ["Fall","Spring","Summer 8WK"],
       ["Fall","Spring","Summer 6WK"],

    ]
}          
class IowaParser < CourseParser
    def start
      
    end
end
