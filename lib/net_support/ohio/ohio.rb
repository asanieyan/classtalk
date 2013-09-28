Info = {
    :name=>"OHIO",
    :nid=>"16777340",
    :city=>"athens",
    :region=>"ohio",    
    :country=>"united states",
    :semesters=>[
 
      ["Fall","9/1","12/25"],
      ["Winter","1/1","3/25"],
      ["Spring","3/26","6/16"],
      ["Summer I","6/20","7/26"],
      ["Summer II","7/27","8/30"],
      ["Summer Full","6/20","8/30"]     

     

],
    :paths => [
       ["Fall","Winter","Spring","Summer Full"],
       ["Fall","Winter","Spring","Summer I","Summer II"]
    ]
}          
class OhioParser < CourseParser
    def start
      
    end
end
