Info = {
    :name=>"Indiana",
    :nid=>"16777285",
    :city=>"bloomington",
    :region=>"indiana",    
    :country=>"united states",
    :semesters=>[
      ["Fall","8/21"],
      ["Winter","1/1"],
      ["Summer 1","5/7"],
      ["Summer 2","6/15"]    
    ]
}          
class IndianaParser < CourseParser
    def start
      urls = ["http://www.indiana.edu/~deanfac/blfal07/"]
      urls.each do |url|
          list = doc_at(url).search("li");list.shift;
          list.each do |li|
              href = li.at("a")['href']
              s_code = li.at("a").inner_html
              s_name = li.at("a").next_node.to_s.sub(/-/,'').strip
              subject = get_subject(s_code,s_name)
              list2 = doc_at(href).search("li");list2.shift;
              list2.each do |li2|
                  href2 = li2.at("a")['href']                
                  cnum = li2.at("a").inner_html
                  cname = li2.at("a").next_node.to_s.sub(/-/,'').strip                  
                  desc = doc_at(href2).at("pre").inner_html rescue next
                  cc = desc[0..desc.index(")")] rescue 0
                  subject.get_course(cnum,cname,desc,cc)
              end
          end
      end
    end
end
