Info = {
    :name=>"UF",
    :nid=>"16777237",
    :city=>"gainesville",
    :region=>"florida",    
    :country=>"united states",
    :semesters=>[
      ["Fall","8/23"],
      ["Spring","1/1"],
      ["Summer A","5/10"],
      ["Summer B","6/26"]    
    ]
}          
class UfParser < CourseParser
    def undergrad
        url = "http://www.registrar.ufl.edu/catalog/programs/courses/"
        doc = doc_at(url)
        doc.search("p > a[@href$='html']").each do |link|
            doc_at(url + link['href']).search("div.crsTITLE").each do |title|
                code,num,name = strip_tags(title.inner_html).gsub(/\s+/,' ').strip.split(" ",3)
                if num !~ /\d/
                      crap,code,num,name = strip_tags(title.inner_html).gsub(/\s+/,' ').strip.split(" ",4)
                      next unless code == "ENL"                                            
                end
                c = title.next_sibling
                if c['class'] == "crsCREDITS"
                 c =  c.inner_html.split(";")[0]
                end
                desc = title.next_sibling.next_sibling
                if c['class'] == "crsDESCRIPTION"
                 desc =  desc.inner_html
                end                
                get_subject(code).get_course(num,name,desc,c)
            end
        end
        
    end
    def grad
          url = "http://gradschool.rgp.ufl.edu/catalog/current-catalog/"
          doc_at(url + "/" + "foi-links.html").search("a[@id^='gridCourse']").each do |link|
              href = link['href'].match(/[A-Z0-9]+\.htm/).to_s             
              doc_at(url + "/FOI/" + href).search("b").each do |title|
                  code,num,name = title.inner_html.split(" ",3)
                  next unless num =~ /\d:$/
                  num = num[0..num.size-2]
                  c = name.slice!(/\(.*?\)/)
                  x = title 
                  desc = ""
                  if x.next_node.text? || x.next_node.to_html =~ /^<i/ 
                    desc =  x.next_node.text? ? x.next_node.to_s : x.next_node.inner_html
                    x = x.next_node
                    desc = x.to_s if x.next_node.text?
                  end
                  get_subject(code).get_course(num,name,desc,c)
                  
              end
              
          end
    end
    def start
        undergrad
        grad
    end
end
