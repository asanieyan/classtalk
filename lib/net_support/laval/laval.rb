Info = {
    :name=>"Laval",
    :nid=>"16778253",
    :city=>"montreal",
    :region=>"quebec",    
    :country=>"canada",
    :semesters=>[
      ["Automne","9/1"],
      ["Hiver","1/1"],
      ["Ete 1ere","5/5"],
      ["Ete 2e","7/1"]      
    ]
}          
class LavalParser < CourseParser
    def start
      ["C1/premier.html","C2/second.html"].each do |address|
      #["C1/premier.html"].each do |address|
        section_id = address.split('/').first

        parse(get("http://www.ulaval.ca/sg/CO/#{address}",{})).at("ul").search("li > a").each do |list_item|

          s_name = list_item.inner_html
          s_code = list_item.attributes['href'][/[A-Z]{3}/]

          xsubject = get_subject(s_code, s_name)
          
          parse(get("http://www.ulaval.ca/sg/CO/#{section_id}/#{list_item.attributes['href']}")).at("ul").search("li > a").each do |course_link|

            
            
            the_doc = parse(get("http://www.ulaval.ca/sg/CO/#{section_id}/#{course_link.attributes['href']}")).at("jahia")
         
            c_name_and_number = the_doc.at("p > center > font > b").inner_html
            c_number =  c_name_and_number.sub(/.*-(\d{5}) .*/,'\1')
            c_name = c_name_and_number.sub(/.*#{c_number} (.*)/,'\1')
            
            c_credits = the_doc.inner_html[/dit\(s\)\:.*Sess/].sub(/\D*([\d\.]*)\D*/,'\1')

            temp = the_doc.inner_html.gsub(/<b>.+<br \/>/, '') 
            c_description = temp[/^<br \/>\n.+<br \/>$/].gsub(/<br \/>/, '')
          
            if c_description == nil then
              puts "FOUND EMPTY DESC"
            end
            
            puts section_id.to_s + " " + c_name_and_number.to_s
            
            course = xsubject.get_course(c_number,c_name,c_description,c_credits)
            
          end

        end
      end
    end
end
