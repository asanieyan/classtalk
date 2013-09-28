Info = {
    :name=>"Tennessee",
    :nid=>"16777311",
    :city=>"knoxville",
    :region=>"tennessee",    
    :country=>"united states",
    :semesters=>[

  ["Fall","8/20","12/25"],
  ["Spring","1/1","5/6"],
  ["Summer Mini","5/7","5/30"],
  ["Summer Full","6/2","8/7"],
  ["Summer 1","6/2","7/3"],
  ["Summer 2","7/7","8/10"]


    ],
    :paths => [
       ["Fall","Spring","Summer Mini","Summer Full"],
       ["Fall","Spring","Summer Mini","Summer 1","Summer 2"]
    ]
}          
class TennesseeParser < CourseParser
    def start
      
    end
end
