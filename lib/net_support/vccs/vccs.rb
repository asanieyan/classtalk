Info = {
    :name=>"VCCS",
    :nid=>"16777898",
    :city=>"lynchburg",
    :region=>"virginia",    
    :country=>"united states",
    :semesters=>[
    ["Fall","8/21"],
    ["Spring","1/6"],
    ["Summer","6/4"]
    ]
}          
class VccsParser < CourseParser
    def start
      ('a'..'z').each do |letter|
        puts "Getting page: http://system.vccs.edu/mcf/crs#{letter}file.HTM"
        parse(get("http://system.vccs.edu/mcf/crs#{letter}file.HTM")).search("h2 > p > b > font").each do |subject|
          s_code = subject.inner_html.sub(/.*?\((.*?)\).*/,'\1').strip
          s_name = subject.inner_html.sub(/(.*?)\(.*?\).*/,'\1').strip

          puts "Creating subject: #{s_code} -> #{s_name}"
          xsubject = get_subject(s_code, s_name)

          parse(get("http://system.vccs.edu/mcf/FILEDES#{letter}.HTM")).inner_html.gsub!(/[\n\r\t\a\e\f\v]/,'').gsub(/ {2,}/,' ').scan(/<a name="#{s_code}.*?"><h4><font .*?>#{s_code}.*?<\/h4>.*?<\/font>/mi).each do |course|
            
            c_number = course.sub(/.*?<font.*?>.*? (.*?) .*?\(.*?CR\).*?<\/font>.*/mi, '\1').strip
            c_name = course.sub(/.*?<font.*?>.*? .*? (.*?)\(.*?CR\).*?<\/font>.*/mi, '\1').strip
            c_credits = course.sub(/.*?<font.*?>.*? .*? .*?\((.*?)CR\).*?<\/font>.*/mi, '\1').gsub(/ /, '').strip.sub(/\d?-?(\d+)/, '\1')
            c_description = course[/<p>.*?<font.*?>.*?<\/font>/mi].sub(/.*?<font.*?>(.*?)<\/font>.*/mi, '\1').strip rescue c_description = "no description"


            if c_number =~ /-/ then
              numbers = c_number.split('-')
              numbers.each do |number|
                puts "*" + number.to_s + " " + c_name + " " + c_credits
                xcourse = xsubject.get_course(number,c_name,c_description,c_credits)
              end
            else
              puts c_number + " " + c_name + " " + c_credits
              xcourse = xsubject.get_course(c_number,c_name,c_description,c_credits)
            end



            

          end

        end
      end
    end
end
