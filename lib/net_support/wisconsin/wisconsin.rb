Info = {
    :name=>"Wisconsin",
    :nid=>"16777303",
    :city=>"madison",
    :region=>"wisconsin",    
    :country=>"united states",
    :semesters=>[
      ["Fall","8/27","12/25"],
      ["Spring","1/17","5/21"],
      ["Summer 3WK","5/22","6/22"],
      ["Summer 8WK","6/16","8/8"]           
    ]
    
}          
class WisconsinParser < CourseParser
    def start

      links = parse(get("http://www.wisc.edu/pubs/ug/courses.html")).search('a')

      edited_links = Array.new
      previous_links = Array.new
      links.each do |link|
        if link.attributes['href'] !~ /^#/i && link.inner_html !~ /[<>]/ && link.attributes['name'] == nil then 
          if !previous_links.include?(link.attributes['href']) then
            previous_links << link.attributes['href']
            edited_links << [link.attributes['href'], link.inner_html.gsub(/\n/,'')]
          end      
        end
      end

      edited_links.each do |link, text|




        s_name = text.gsub(/ {2}/, ' ')
        s_name.strip!
                      
        if s_name !~ / / then
          s_code = s_name[/^.{3,4}/].upcase
        elsif s_name.scan(/ /).length >= 3 then
          s_code = s_name.sub(/^(.{1}).* (.{1}).* (.{1}).* (.{1}).*$/, '\1\2\3\4').upcase
        elsif s_name.scan(/ /).length == 2 then
          s_code = s_name.sub(/^(.{2}).* +(.{1}).* +(.{1}).*$/, '\1\2\3').upcase
        elsif s_name.scan(/ /).length == 1 then
          s_code = (s_name[/^.{3}/] + s_name.sub(/.* (.{1}).*?$/, '\1')).upcase
        else

        end

        puts s_code + " " + s_name
        
        xsubject = get_subject(s_code, s_name)
        
        if link =~ /#courses/i then

          parse(get("http://www.wisc.edu/pubs/ug/#{link}")).search("p").each do |p_tag|
            if p_tag.inner_html =~ /^<b>\d+ .*<\/b>.*/ then
              c_number = p_tag.at("b").inner_html[/^\d+ /]
              c_name = p_tag.at("b").inner_html.sub(/^\d+ (.*)/, '\1').gsub(/&#8212;/,'-').gsub(/[\(\)]/,'')
              c_credits = p_tag.inner_html[/ \d?-?\d+ cr/].sub(/cr/,'').strip.sub(/\d-(\d+)/, '\1')
              c_description = p_tag.inner_html[/ cr .*\..*/]
              if c_description == nil then
                c_description = "no description"
              else  
                c_description = c_description.sub(/ cr .*?\.(.*)/, '\1')  
              end
            
            course = xsubject.get_course(c_number,c_name,c_description,c_credits)
            puts c_number + " " + c_name
            end
          end
          
         

        elsif link !~ /#.*/ then
          #puts "NO ANCHOR" + link
        else
          location,anchor = link.split('#')
          
          section = parse(get("http://www.wisc.edu/pubs/ug/#{location}")).inner_html[/<a name="#{anchor}">.*?(<a name=|<script)/mi]

          p_tags = section.scan(/<p><b>.*?<\/b>.*?<\/p>/)


          p_tags.each do |p_tag|
              c_number = p_tag[/<b>.*<\/b>/].sub(/^<b>(\d+) .*<\/b>/, '\1')
              c_name = p_tag[/<b>.*<\/b>/].sub(/^<b>\d+ (.*)<\/b>/, '\1').gsub(/&#8212;/,'-').gsub(/[\(\)]/,'')
              c_credits = p_tag[/<\/b>.* \d?-?\d+ cr/].gsub(/^[^\d\-]*/, '').sub(/cr/,'').strip.sub(/\d-(\d+)/, '\1')

              c_description = p_tag.sub(/^<p><b>.*<\/b>.*cr(.*)<\/p>/,'\1')
              if c_description == nil then
                c_description = "no description"
              else  
                c_description = c_description.sub(/^.*?\. /, '')
              end
          course = xsubject.get_course(c_number,c_name,c_description,c_credits)
          puts c_number + " " + c_name
          end

          
        end

        


      end

      
            
      
    end
end
