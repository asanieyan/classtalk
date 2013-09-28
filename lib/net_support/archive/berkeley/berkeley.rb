Info = {
    :name=>"Berkeley",
    :nid=>"16777229",
    :city=>"berkeley",
    :region=>"california",    
    :country=>"united states",
    :semesters=>[
      ["Fall","8/20"],
      ["Spring","1/1"],
      ["Summer","5/1"]
    ]
}          
class BerkeleyParser < CourseParser
    def start
      e = parse(get("http://sis.berkeley.edu/catalog/gcc_search_menu")).at("select[@name='p_dept_name']").search("option")
      e.shift
      require 'URI'
      e.each do |option|
         v = option.inner_html.strip
         s_name = v         
         v  = URI::encode(v,/[ &()]/)
         doc = parse(get("http://sis.berkeley.edu/catalog/gcc_search_sends_request?p_dept_name=#{v}"))
         c_name = s_code = c_credit = c_num = ""
         doc.search("tr").each do |tr|
                td  = tr.search("td").pop
                title = td.at("font[@size=2][@face='Verdana, Geneva, sans-serif']").inner_html rescue ""
                if title.size > 0
                  title = clear(html_decode(strip_tags(title)).gsub(/\s+/,' '))
                  next if title == "Search Results"
                  c_name = title.match(/(.*?) \-/).to_s.gsub(/ \-/,'')
                  s_code = title.scan(/\([A-Z]*[ ,-\/]?[A-Z]*[ ,-\/]?[A-Z]+\)/).pop.to_s.gsub(/\(|\)/,'')
                  p s_code
                  c_credit = title.match(/\[.*? units\]/).to_s.gsub(/\[(.*?) units\]/,'\1')                 
                  c_num = title.match(/\(#{s_code}\) \w+/).to_s.sub(/\(#{s_code}\) (\w+)/,'\1')
#                  p c_name
#                  if s_code == ""
#                      p title
#                  end
                elsif td.inner_html =~ /Description/ 
                        subject =  get_subject(s_code,s_name);
                        
                        td.search("b").remove;
                        c_desc = strip_tags(td.inner_html)
                        course = subject.get_course(c_num,c_name,c_desc,c_credit)                        
                end
         end
      end
      
      
      
    end
end
