  Info = {
    :name=>"Bowling Green",
    :nid=>"16777426",
    :city=>"bowling green",
    :region=>"ohio",    
    :country=>"united states",
    :semesters=>[
	  ["Fall","8/20", "12/20"],
	  ["Spring","1/5", "5/5"],
	  ["Summer 6WK1","5/14", "6/24"] ,
	  ["Summer 6WK2","6/25", "8/5"] ,
	  ["Summer 8WK","6/10", "8/5"] 
	  
   ],:paths=>[
	["Fall","Spring","Summer 6WK1","Summer 6WK2"],
	["Fall","Spring","Summer 8WK"]
   ]
}          
class BowlingGreenParser < CourseParser
    def start
      parse(get("http://webapps.bgsu.edu/courses/search.php")).at("select[@name='course_prefix']").search("option").each do |option|
        s_code = option.attributes['value']
        if s_code != "" then 
          s_name = option.inner_html.sub(/.*?\((.*)\)/,'\1')
          xsubject = get_subject(s_code, s_name)
          puts s_code
          params = "keyword=&course_prefix=#{s_code.sub(/&/,'%26')}&course_number=&course_level=&min_credits=&max_credits=&gen_ed_courses=&category_code=&full_description=on"
          parse(get("http://webapps.bgsu.edu/courses/result.php?#{params}")).search("p").each do |p_tag|
            if p_tag.inner_html =~ /#{s_code.sub(/&/,'&amp;')}/ then
              
              
              ssc = s_code.sub(/&/,'&amp;')
              
              c_name=p_tag.search("em")[0].inner_html
              c_number=p_tag.at("strong").inner_html.sub(/#{ssc}/,'').gsub(/[\. ]/,'')
              c_credits=p_tag.search("em")[1].inner_html.sub(/\((\d+-)?(\d+)\).*/, '\2')
              c_description=p_tag.inner_html.gsub(/<em>(.*?)<\/em>|<strong>(.*?)<\/strong>/,'').gsub(/<a.*?>(.*?)<\/a>/,'\1')
              puts c_number + " " + c_name + " " + c_credits
              puts c_description
              xcourse = xsubject.get_course(c_number,c_name,c_description,c_credits)
              puts "*"*40
            end
          end
        end
      end
    end
end
