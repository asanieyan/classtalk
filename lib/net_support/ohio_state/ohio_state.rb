Info = {
    :name=>"Ohio State",
    :nid=>"16777341",
    :city=>"columbus",
    :region=>"ohio",    
    :country=>"united states",
    :semesters=>[
    
    ["Autumn","9/19","12/20"],
    ["Winter","1/3","3/20"],
    ["Spring","3/24","6/11"],
    ["Summer I","6/16","7/24"],
    ["Summer II","7/21","8/29"]

    ]
}          
class OhioStateParser < CourseParser
    def start
#      ["winter","spring","summer","autumn"].each do |season|
#      #["autumn"].each do |season|
#        ['a','b','c','d','e','f','g','h','i','j','k','l','m','n','o','p','r','s','t','u','v','w','x','y','z'].each do |letter|
#
#          parse(get("http://www.ureg.ohio-state.edu/course/#{season}/#{letter}.html")).search("a").each do |link|
#            if link.inner_html =~ /Bulletin/ && link.attributes['href'] != nil then
#
#              msched_link = link.attributes['href'].sub(/(.*\/)book3\/B(\d+.htm)/, '\1msched/M\2')
#
#              subject_line = parse(get("http://www.ureg.ohio-state.edu#{msched_link}")).inner_html[/<b>.* \(.*\)<\/b>/i].gsub(/<\/?b>/,'')
#              s_name = subject_line.sub(/.*\((.*)\)/,'\1')
#              s_code = subject_line[/^.{8}/]
#              xsubject = get_subject(s_code,s_name)
#
#              
#              lines = parse(get("http://www.ureg.ohio-state.edu#{link.attributes['href']}")).inner_html.scan(/.*\n/)
#
#              get_description = false
#              c_name = nil
#              c_number = nil
#              c_credits = nil
#              c_description = nil
#              lines.each do |line|
#               begin
#                if line =~ /<tr><td bgcolor="white" colspan="3"><font size="-1"><a.*<\/b>/ then
#                  edited_line = line.sub(/.*<b>(.*)<\/b>.*/, '\1').gsub(/&nbsp;|\n/,'')
#                  c_number = edited_line[/^.{2,6} /].gsub(/[\^\* ]/, '').to_s
#                  c_name = edited_line.sub(/(.*) .*$/, '\1').sub(/^.{2,6} /, '')
#                  c_credits = edited_line.sub(/.* ([PUG\-\d]*)$/, '\1').gsub(/[PUG]/,'')
#                  
#                  if c_credits =~ /\-/ then
#                    c_credits = c_credits.sub(/.*\-(.*)/,'\1')
#                  end
#
#                  if c_credits == "" then
#                    c_credits = "0"
#                  end
#
#                  get_description = true
#                elsif get_description == true then
#                  if line !~ /Qtr\.|Qtrs\.|Prereq/ && line =~ /<tr><td width="20">&nbsp;<\/td><td colspan="2"><font size="-1">(.*)<\/font><\/td><\/tr>/ then
#                    c_description = line.sub(/<tr><td width="20">&nbsp;<\/td><td colspan="2"><font size="-1">(.*)<\/font><\/td><\/tr>/, '\1')
#                  else
#                    c_description = "no description"
#                  end
#                
#puts season + "::" + letter + " --> " + s_code + "," + c_number + " " + c_name
#                  course = xsubject.get_course(c_number,c_name,c_description,c_credits)
#                  c_name = nil
#                  c_number = nil
#                  c_credits = nil
#                  c_description = nil
#
#                  get_description = false
#                end
#               rescue Exception => e
#                 puts e
#               end
#              end
#
#
#
#            end
#          end
#        end      
#        puts "done with first section -> #{season}"
#      end

      #begin regional parse here...
      #["winter","spring","summer","autumn"].each do |season|
      ["spring","summer","autumn"].each do |season|
        ['lima','mansfield','marion','newark','wooster'].each do |location|
          parse(get("http://www.ureg.ohio-state.edu/course/#{season}/regional/#{location}/")).search("a").each do |link|

            if link.inner_html =~ /Bulletin/ && link.attributes['href'] != nil then

              msched_link = link.attributes['href'].sub(/(.*\/)book3\/B(\d+.htm)/, '\1msched/M\2')

              subject_line = parse(get("http://www.ureg.ohio-state.edu#{msched_link}")).inner_html[/<b>.* \(.*\)<\/b>/i].gsub(/<\/?b>/,'')
              s_name = subject_line.sub(/.*\((.*)\)/,'\1')
              s_code = subject_line[/^.{8}/]

              xsubject = get_subject(s_code,s_name)

              lines = parse(get("http://www.ureg.ohio-state.edu#{link.attributes['href']}")).inner_html.scan(/.*\n/)

              get_description = false
              c_name = nil
              c_number = nil
              c_credits = nil
              c_description = nil
              lines.each do |line|

                if line =~ /<tr><td bgcolor="white" colspan="3"><font size="-1"><a.*<\/b>/ then
                  edited_line = line.sub(/.*<b>(.*)<\/b>.*/, '\1').gsub(/&nbsp;|\n/,'')
                  c_number = edited_line[/^.{2,6} /].gsub(/[\^\* ]/, '').to_s rescue c_number = nil
                  c_name = edited_line.sub(/(.*) .*$/, '\1').sub(/^.{2,6} /, '') rescue c_name = nil
                  c_credits = edited_line.sub(/.* ([PUG\-\d]*)$/, '\1').gsub(/[PUG]/,'') rescue c_credits = nil
                  
                  if c_credits =~ /\-/ then
                    c_credits = c_credits.sub(/.*\-(.*)/,'\1')
                  end

                  if c_credits == "" then
                    c_credits = "0"
                  end

                  get_description = true
                elsif get_description == true then
                  if line !~ /Qtr\.|Qtrs\.|Prereq/ && line =~ /<tr><td width="20">&nbsp;<\/td><td colspan="2"><font size="-1">(.*)<\/font><\/td><\/tr>/ then
                    c_description = line.sub(/<tr><td width="20">&nbsp;<\/td><td colspan="2"><font size="-1">(.*)<\/font><\/td><\/tr>/, '\1')
                  else
                    c_description = "no description"
                  end

puts season + "::" + location + " --> " + s_code + "," + c_number + " " + c_name
                  course = xsubject.get_course(c_number,c_name,c_description,c_credits)
                  c_name = nil
                  c_number = nil
                  c_credits = nil
                  c_description = nil

                  get_description = false
                end
              end



            end
          end
        end      
        puts "done with second section -> #{season}"
      end
      
    end
end
