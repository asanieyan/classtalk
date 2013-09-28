Info = {
    :name=>"NYU",
    :nid=>"16777225",
    :city=>"new york",
    :region=>"new york",    
    :country=>"united states",
    :semesters=>[
      ["Fall","9/1","12/25"],
      ["Spring","1/1","5/15"],
      ["Summer 6WK1","5/19","6/27"],
      ["Summer 6WK2","6/30","8/8"],
      ["Summer 3WK1","5/19","6/6"],
      ["Summer 3WK2","6/9","6/27"],
      ["Summer 3WK3","6/30","7/18"],
      ["Summer 3WK4","7/21","8/8"],
      ["Summer 8WK","5/19","7/11"],
      ["Summer 7WK","5/19","7/3"]
    ],
    :paths=>[
      ["Fall","Spring","Summer 6WK1","Summer 6WK2"],
      ["Fall","Spring","Summer 3WK1","Summer 3WK2","Summer 3WK3","Summer 3WK4"],      
      ["Fall","Spring","Summer 8WK"],
      ["Fall","Spring","Summer 7WK"]
    ]    
}          
class NyuParser < CourseParser
    
    def start
     
         post_url = "term=Fall+2007&school=cas&subject=V14.&crsName=&showCX=A"
         schools = {}
          set_s_name "V18"=>"American Studies/Africana Studies","E59"=>"Media, Culture & Communication",
                     "C40"=>"Social Impact",
                     "V49"=>"Advanced Honors Seminars",
                     "V28"=>"Earth & Environmental Science",
                     "V31"=>"Econimics",
                     "V37"=>"Engineering Pgm with Stevens"                     
         get("subjects.txt").each_line do |line|
            v1,v2 = line.split(";",2)
            school_name = v1.slice(/[^\[]+/)
            s_line = v1.slice(/".*?"/)
            s_line = s_line[1..s_line.size-2]
            s_code = s_line.slice!(/\(.*?\)/)
            if s_code
              s1_code = s_code.delete(")").delete("(") 
              s_name = s_line.strip
              subject = get_subject(s1_code,s_name,:select_old_name=>true)
              schools[school_name] ||= []
              schools[school_name] << subject
            end
         end
         doc_at("https://www1.albert.nyu.edu/helpregistrar/subjecthelp.htm#UA").search("li").each do |list|
            next unless list.at("b")
            s_name = list.at("b").inner_html
            s_code = list.search("i").last.inner_html rescue ""
            s_code =  s_code.slice(/[A-Z0-9]+/) rescue nil                      
            subject = get_subject(s_code,s_name,:dont_add=>true,:select_new_name=>true)
         end       
        schools.each do |school_name,subjects|         
          subjects.each do |subject|
              ["Fall+2007","Spring+2007"].each do |term| 
                post_url = "term=#{term}&school=#{school_name}&subject=#{subject.code}&crsName=&showCX=A"
                doc = parse(post("http://www.nyu.edu/registrar/listings/results.html",post_url))
                doc.search("tbody tr.T") do |course|
                    cnum,cname = strip_tags(course.inner_html).split(" - ",2)
                    s_code = cnum.slice!(subject.code)
                    subject = find_subject_by_code(s_code)
                    if not subject
                        raise unless confirm("subject not found for #{cnum} cont.")                                            
                    end 
                    if subject
                      if course.next_sibling['class'] != 'T' 
                          cc = course.next_sibling.search("td")[8].inner_html
                      else
                          cc = 0
                      end
                      subject.get_course(cnum,cname,"",cc,:code=>subject.code.delete("."))
                    end
                end                       
              end
          end
        end
    end
end
