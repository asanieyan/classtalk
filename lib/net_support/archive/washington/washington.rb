Info = {
    :name=>"Washington",
    :nid=>"16777324",
    :city=>"seattle",
    :region=>"washington",    
    :country=>"united states",
    :semesters=>[
      ["Autumn","9/26","12/20"],
      ["Winter","1/5","3/25"],
      ["Spring","3/27","6/18"],
      ["Summer Full","6/23","8/22"],
      ["Summer A","6/23","7/23"],  
      ["Summer B","7/24","8/22"]    
    ],
    :paths=>[
      ["Autumn","Winter","Spring","Summer Full"],
      ["Autumn","Winter","Spring","Summer A","Summer B"]
    ]
}          
class WashingtonParser < CourseParser
    def start

      parse(get("http://www.washington.edu/students/crscat/")).search("li > a").each do |link|

        if link.inner_html !~ /\bsee\b/i then

          s_line = link.inner_html.sub(/&nbsp;/,'_').sub(/\n/,'')
          if s_line.scan(/\(/).length == 2 then
            s_code = s_line[/\(.*?\)$/]
            s_code = s_code.sub(/\(.*?\)/, '')
          else
            s_code = s_line[/\(.*?\)$/]
          end

          if s_code != nil then

            s_name = s_line[/^.*\(/].sub(/\($/,'')
            s_code.gsub!(/[\(\)]/, '')

            xsubject = get_subject(s_code, s_name)
            
            page = parse(get("http://www.washington.edu/students/crscat/#{link.attributes['href']}")).inner_html
            
            courses = page.scan(/<p><b><a name=".*?<\/a>.*?\n/mi)

            courses.each do |c|

              c_line = c[/<b.*?b>/]

              c_number = c_line.sub(/.*<a name=".*?">(.*)<\/a>.*/,'\1').gsub(/\D/, '')
              c_name = c_line.sub(/.*<\/a>(.*?)\(.*/,'\1').strip
              c_credits = c_line.sub(/.*\((.*)\).*<\/b>$/, '\1')
              if c_credits == "*" || c_credits == nil then 
                c_credits = "0"
              else
                c_credits = c_credits.gsub(/-|\[|]|/,'').sub(/.*? ?(\d+)$/,'\1')
              end
              c_description = c.sub(/.*<br \/>(.*)/,'\1')

puts s_name + " " + s_code + " " + c_number + " " + c_name + " " + c_credits
              course = xsubject.get_course(c_number,c_name,c_description,c_credits)

            end



          end
        end
      end
    end
end
