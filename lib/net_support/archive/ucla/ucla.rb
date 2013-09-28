Info = {
    :name=>"UCLA",
    :nid=>"16777242",
    :city=>"los angeles",
    :region=>"california",    
    :country=>"united states",
    :semesters=>[
      ["Fall","9/23","12/15"],
      ["Winter","1/3","3/25"],
      ["Spring","3/27","6/15"],
      ["Session A 6WK","6/25","8/3"],
      ["Session A 8WK","6/25","8/17"],
      ["Session A 10WK","6/25","8/31"],                 
      ["Session C 6WK","8/6","9/14"],            
    ],:paths=>[
        ["Fall","Winter","Spring","Session A 6WK"],
        ["Fall","Winter","Spring","Session A 8WK"],
        ["Fall","Winter","Spring","Session A 10WK"],
        ["Fall","Winter","Spring","Session B"],
        ["Fall","Winter","Spring","Session C 6WK"]        
    ]
}          
class UclaParser < CourseParser
    def start
        @subjects.each do |subject|
            subject.code.gsub!(/_+$/,'')
            subject.courses.each do |course|
                course.subject.gsub!(/_+$/,'')
            end
        end
    end
    def start1

      parse(get("http://www.registrar.ucla.edu/schedule/catsel.aspx")).search("li").each do |subject_area|
      
        s_name = subject_area.at("a").inner_html.strip
        href = subject_area.at("a").attributes['href']
        s_code = href.sub(/.*\?sa=(.*)&.*/,'\1').gsub(/\+|(\%26)/,'_')

        xsubject = get_subject(s_code, s_name)

        do_next_line = false
        
        c_name = nil
        c_number = nil
        c_credits = nil
        c_description = nil
        
        parse(get("http://www.registrar.ucla.edu/schedule/#{href}")).search("span").each do |span|
          if do_next_line == true then
            if span.attributes['class'] == nil then
              c_description = span.inner_html.sub(/<br.*>/,'')
            else
              c_description = "no description"
            end
            puts c_number + " " + c_name + " " + c_credits
            course = xsubject.get_course(c_number,c_name,c_description,c_credits)
            do_next_line = false
          elsif span.attributes['class'] == 'bold' then

            c_number = span.inner_html[/^.+?\./].sub(/\./,'')
            c_name = span.inner_html.sub(/.*\. ?(.*)<br.*/, '\1').sub(/\(.*\)$/,'')
            c_credits = span.inner_html.sub(/.*(\(.*\)).*$/, '\1').sub(/\(\d*?( to | or )?(\d?\.?\d+)\)/,'\2')
            do_next_line = true

          end
        end

      end
      
    end
end
