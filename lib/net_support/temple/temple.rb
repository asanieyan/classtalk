Info = {
    :name=>"Temple",
    :nid=>"16777299",
    :city=>"philadelphia",
    :region=>"pennsylvania",    
    :country=>"united states",
    :semesters=>[
      
        ["Fall","8/25","12/25"],
        ["Spring","1/1","5/16"],
        ["Summer 1","5/17","7/4"],
        ["Summer 2","7/5","8/20"]


    ]
}          
class TempleParser < CourseParser
    def start
 
      get("http://voyager.adminsvc.temple.edu/tucourses/tu_coursesemester.asp")
      set_cookie
#      parse(get("http://voyager.adminsvc.temple.edu/tucourses/tu_courses.asp?radSemester=0736&radCrseType=All")).at("select[@name='lstDept']").search("option").each do |option|
#        department = option.attributes['value']
#        set_s_code get("subject.yml")                            
#        xsubject = get_subject(nil, department.strip)
#      end
      parse(get("http://voyager.adminsvc.temple.edu/tucourses/tu_courses.asp?radSemester=0736&radCrseType=All")).at("select[@name='lstDept']").search("option").each do |option|
        department = option.attributes['value']
        set_s_code get("subject.yml")                            
        xsubject = get_subject(nil, department.strip)
#        puts URI.encode(option.attributes['value'])   #.gsub(/ /,'+')
        subject_coursenumbers = Array.new
        parse(get("http://voyager.adminsvc.temple.edu/tucourses/tu_courseslist.asp?lstCrsLevel=All&radCampus=All&lstDept=#{URI.encode(department).gsub(/\+/,'%2B').gsub(/&/,'%26')}&lstCredHrs=All&radDivn=All&radStatus=All&lstReq=All&Day1=&Day2=&Day3=&Day4=&Day5=&Day6=&Day7=&PrevCourse1B=&PrevTextCourse1B=&PrevCourse2B=&PrevTextCourse2B=&PrevCourse3B=&PrevTextCourse3B=&PrevCourse4B=&PrevTextCourse4B=&PrevCourse5B=&PrevTextCourse5B=&PrevCourse4B=&PrevTextCourse4B=&PrevCourse5B=&PrevTextCourse5B=&browser=&host=")).search("tr[@bgcolor='#FFFFFF']").each do |tr_tag|

#puts "form course number"
          coursenumber = tr_tag.search("td")[1].at("div").inner_html + tr_tag.search("td")[2].at("div").inner_html
#puts "course number formed!"
          if !subject_coursenumbers.include?(coursenumber) then
            subject_coursenumbers << coursenumber
            href = tr_tag.search("td")[0].at("a").attributes['href']
            page = parse(get("http://voyager.adminsvc.temple.edu/tucourses/#{href}")).inner_html.gsub(/\s+|&nbsp;/,' ').gsub(/> +</,'><')
#puts "beginning number parse"
            c_number = page.sub(/.*<td nowrap align="right" width="20%"><div id="descrip" align="left">Course Number:<\/div><\/td><td nowrap width="3%"><\/td><td nowrap width="26%"><div id="descripNobold">(.*?)<\/div><\/td>.*/,'\1').strip
#puts "beginning name parse"
            c_name = page.sub(/.*Course Title\:(.*?)<\/b>.*/,'\1').strip
#puts "beginning credits parse"
            c_credits = page.sub(/.*<div id="descrip" align="left">Credit Hours:<\/div><\/td><td nowrap width="3%"><\/td><td nowrap width="26%"><div id="descripNobold">(.*?)<\/div><\/td>.*/,'\1').strip[/(\d+\.0$)/]
#puts "beginning description parse"
            c_description = page.sub(/.*<tr><td nowrap valign="top" width="20%"><div id="descrip" align="left">Course Description:<\/div><\/td><td nowrap width="3%"><\/td><td valign="top" colspan="5"><div id="descripNobold" align="left">(.*?)<\/div><\/td><\/tr>.*/i,'\1').strip

            if c_number == nil || c_name == nil || c_credits == nil then; puts "ERROR IN ONE OF THE THREE"; end
#            puts c_number.inspect + " " + c_name.inspect + " " + c_credits.inspect

#            puts c_description
            xcourse = xsubject.get_course(c_number,c_name,c_description,c_credits)
#            puts "*"*40
            
          end
          
        end

      end
    end
end
