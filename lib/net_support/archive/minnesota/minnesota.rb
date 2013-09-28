Info = { 
    :name=>"Minnesota",
    :nid=>"16777356",
    :city=>"minneapolis",
    :region=>"minnesota",    
    :country=>"united states",
    :semesters=>[
      ["Fall","8/25","12/1"],
      ["Spring","1/1","5/1"],
      ["Summer Session","6/1","8/1"],
    ]
}          
class MinnesotaParser < CourseParser
    def start      
      %w(UMNTC).each do |inst|
        parse(get("http://onestop2.umn.edu/courses/designators.jsp?institution=#{inst}")).at("#designator").search("option").each do |option|
                s_code = option['value']
                inside = option.inner_html.strip
                s_name = inside[inside.index("-")+1..inside.size]
                s = get_subject(s_code,s_name,:select_old_name=>true)
                doc = get("http://onestop2.umn.edu/courses/courses.jsp?designator=#{s.code}&submit=Show+the+courses&institution=#{inst}")
                doc = parse(doc)
            begin
              doc.search("span.bodysubtitlered").each do |span|
                c_num = span.inner_html.gsub(/#{s.code}/,'')
                c_name = span.next_sibling
                c_c  = c_name.next_node.next_node.next_node 
                
                c_des = c_c.next_node.next_node
                c_name = c_name.inner_html.gsub(/&nbsp;/,'').sub(/-/,'')              
                c_c =  if c_c.text? 
                          c_c.to_s.split(";")[0]
                       else
                          ""
                       end
                c_des = c_des.text? ? c_des.to_s : ""
                c = s.get_course(c_num,c_name,c_des,c_c)               
  
              end
            rescue
            
            end  
        end
      end
    end
    def start0

#      ["UMNTC%2C1079%2CFall%2C2007%2Cfalse","UMNTC%2C1083%2CSpring%2C2008%2Cfalse"].each do |search_term|
#
#        parse(get("http://onestop2.umn.edu/courseinfo/classschedule_selectsubject.jsp?institution=UMNTC&searchTerm=#{search_term}")).at("select[@id=sSubject]").search("option").each do |option|
#          
#          s_name = option.inner_html.split(' - ')[0]
#          s_code = option.inner_html.split(' - ')[1]
#
#          xsubject = get_subject(s_code,s_name)
#
#          search_subject = option.attributes['value']
#
#          begin
#            search_subject = URI.escape(search_subject)
#          rescue Exception => e
#            #puts e
#          end
#          
#          parse(get("http://onestop2.umn.edu/courseinfo/viewClassScheduleTermAndSubject.do?institution=UMNTC&searchTerm=#{search_term}&searchSubject=#{search_subject}&searchFullYearEnrollmentOnly=false&Submit=View")).at("table[@class='coursetable']").search("table").each do |course|
#            
#            c_name = course.at("span[@class='label']").inner_html.sub(/.*;.*;(.*)/,'\1')
#            c_number = course.at("span[@class='label']").inner_html.sub(/.*;(.*)&nbsp;.*/,'\1')
#            puts c_number + " " + c_name
#          end
#
#        end
#
#      end

      parse(get("http://onestop2.umn.edu/courseinfo/courseguide_selectsubject.jsp?institution=UMNTC")).at("select[@id='sSubject']").search("option").each do |option|

    
          s_name = option.inner_html.split(' - ')[0]
          s_code = option.inner_html.split(' - ')[1]

          xsubject = get_subject(s_code,s_name)

          search_subject = option.attributes['value']

          if search_subject != nil then 

            begin
              search_subject = URI.escape(search_subject)
            rescue Exception => e
              #puts e
            end
        
            parse(get("http://onestop2.umn.edu/courseinfo/viewCourseGuideTermAndSubject.do?institution=UMNTC&searchTerm=UMNTC%2C1079%2CFall%2C2007&searchSubject=#{search_subject}&Submit=View")).search("table[@class='coursetable']").each do |course|
            
              begin
                c_name = course.at("span[@class='label']").inner_html.sub(/.*;.*;(.*)/,'\1').gsub(/\n/m,'').gsub(/[ ]{2,}/m,' ').strip
                c_number = course.at("span[@class='label']").inner_html.sub(/.*;(.*)&nbsp;.*/,'\1').gsub(/\n/m,'').gsub(/[ ]{2,}/m,' ').sub(/(\d+)\D*/,'\1').strip
                c_credits = course.inner_html[/\d+ credits/].sub(/ credits/,'') rescue c_credits = 0
                c_description = course.inner_html[/<span class="labelsmaller">Description:<\/span>.*<span class="bodytext">.*<\/span><\/td><\/tr>/m].sub(/.*<span class="bodytext">(.*)<\/span>.*/,'\1') rescue c_description = "no description"
                course = xsubject.get_course(c_number,c_name,c_description,c_credits)
              rescue Exception => e
              end
            end
          
          end
      
      end
    end
end
