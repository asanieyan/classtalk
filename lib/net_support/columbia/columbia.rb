Info = {
    :name=>"Columbia",
    :nid=>"16777218",
    :city=>"new york",
    :region=>"new york",    
    :country=>"united states",
    :semesters=>[
      
      ["Fall","9/1","12/25"],
      ["Spring","1/1","5/17"],
      ["Summer D","5/21","6/29"],
      ["Summer E","5/21","7/20"],
      ["Summer H","6/4","6/29"],
      ["Summer Q","7/2","8/10"],
      ["Summer R","7/2","7/27"],
      ["Summer X","5/21","8/10"]                    
    ],:paths=>[

        ["Fall","Spring","Summer D"],
        ["Fall","Spring","Summer E"],
        ["Fall","Spring","Summer H"],
        ["Fall","Spring","Summer Q"],
        ["Fall","Spring","Summer R"],
        ["Fall","Spring","Summer X"]        
    ]    
}   
class ColumbiaParser < CourseParser
  def start
    return
    parse(get("http://www.gs.columbia.edu/deptinfo.htm")).at("select[@name='subjectVar']").search("option").each do |option|          
        subjectVar = option.attributes['value']
        p subjectVar
        p 'd'
        if subjectVar.size > 0          
            parse(get("http://www.college.columbia.edu/unify/bulletinSearch.php?header=www.gs.columbia.edu%2Ftopinframe.htm&footer=www.gs.columbia.edu%2Ffooter.htm&school=GS&limitVar=50000&departmentVar=&subjectVar=#{subjectVar}&termVar=&instructorVar=&courseLevelVar=&dayVar=&beginHourVar=&endHourVar=&keywordVar=&submit=Begin+Search")).search("table td p").each do |b|
                p b            
            end
        end
    end
  end
end