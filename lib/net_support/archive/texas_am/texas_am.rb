Info = {
    :name=>"Texas A&M",
    :nid=>"16777300",
    :city=>"college station",
    :region=>"texas",    
    :country=>"united states",
    :semesters=>[
    ["Fall","8/27"],
    ["Spring","1/1"],
    ["Summer","5/20"]

    ]
}          
class TexasAmParser < CourseParser
    def start           
      url1 = "http://www.tamu.edu/admissions/catalogs/06-07_UG_Catalog/course_descriptions"
      url2 = "http://www.tamu.edu/admissions/catalogs/GRAD_catalog06_07/course_descriptions"
      [url1,url2].each do |url|
        parse(get(url + "/index.htm")).search("td a").each do |s_link|
          s_code = s_link.inner_html.strip
          next if s_code == ""
          s_name = s_link.previous_node.to_s.sub(/\s+\(/,'').strip      
          if s_name == ""
            s_name = s_code          
          end
          s_code.gsub!(',','')
          s_link = url + "/" + s_link['href']
          doc = parse(get(s_link))
          subject = get_subject(s_code,s_name)        
          doc.search("h6").each do |h6|
            title = h6.inner_html.split(".")
            c_num = title.shift
            c_name = title.shift
            c_something = title.shift
            if c_something =~ /Credit/
              c_credit = c_something
            else
              c_credit = title.shift
            end
            desc = h6.next_sibling
            if desc and desc.xpath =~ /p\[\d+\]$/
              desc = desc.inner_html
            else          
              desc = ""
            end
            subject.get_course(c_num,c_name,desc,c_credit)
            
            
          end
        end
      end
    end
end
