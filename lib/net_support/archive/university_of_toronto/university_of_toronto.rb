Info = {
    :name=>"University of Toronto",
    :nid=>"16777498",
    :city=>"toronto",
    :region=>"ontario",    
    :country=>"canada",
    :semesters=>[
          ["Fall/Winter","9/10","8/20"],  
          ["Fall","9/10","12/25"],
          ["Winter","1/1","5/10"],
          ["Summer","5/14","8/20"], 
          ["Summer I","5/14","6/29"],      
          ["Summer II","7/3","8/20"]
    ]
}          

class UniversityOfTorontoParser < CourseParser
#    def initialize *args
#      @coursechecker = {}
#      super(args)
#    end

    def get_subjects(confused)
        subject_hash = {}
        confused.each do |subject|
            code,name = subject.split(" ",2)
            subject_hash[name] = code
        end
        subject_hash
    end
    def camp2
        confused = [   "CHM Chemistry",
                       "BGY Biology",
                       "CCT Communication, Culture and Information Technology",
                       "CSC Computer Science",
                       "CTE Concurrent Teacher Education",
                       "DTS Diaspora and Transnational Studies",
                       "ERS Earth Science",
                       "FAH Fine Art History (FAH)",
                       "FSC Forensic Science",
                       "FAS Fine Art Studio (FAS)",
                       "GGR Geography",
                       "RLG History of Religions",
                       "MGT Management",
                       "PHL Philosophy",
                       "WRI Professional Writing and Communication",
                       "WGS Study of Women and Gender",
                       "ECM Economics For Management Studies",
                       "EES Environmental Science",
                       "STE Environmental Science and Technology",
                       "HLT Health Studies",
                       "IMC Industrial Microbiology",
                       "IDS International Development Studies",
                       "IST International Studies",
                       "LGG Languages and Linguistics",
                       "NRO Neuroscience",
                       "NME New Media Studies",
                       "PMD Paramedicine",
                       "PSC Physical Sciences",
                       "SOE Society and Environment",
                       "VPA Visual and Performing Arts", 
                       "WST Women's Studies"
                       ]
         subject_hash = get_subjects(confused)
         
         doc = doc_at("subjects.html")
         doc.search("li").each do |depart_list|
            depart_link = depart_list.at("a")
            next if depart_link['href'].include?("#")
            s_name =  depart_link.inner_html.sub(/\s+\(.*$/,'').strip
            s_code = subject_hash[s_name]
            unless s_code
              s_code = s_name[0,3].upcase
            end
            s_code = s_code + " (UTSC)"
            subject = get_subject(s_code,s_name)
          end         
          subject = nil
         doc.search("li").each do |depart_list|
            depart_link = depart_list.at("a")
            next if depart_link['href'].include?("#")
            depart_page = doc_at("http://www.utsc.utoronto.ca/courses/calendar/#{depart_link['href']}")
            subdoc = depart_page.at("div.subtoc")
            next unless subdoc 
            if subdoc.inner_html.include?("<b>Courses</b>")
             subdoc.search("td a").each do |link_to_anchor|
                anchor_name = link_to_anchor['href'].delete("#")
                anchor = depart_page.at("a[@name='#{anchor_name}']}")
                ccode = anchor.inner_html[0..2]
                cnum  = anchor.inner_html[3..5]
                cc =    anchor.inner_html[6..-1]
                if cnum.size > 3
                    puts cnum
                    raise "invalid num"
                    
                end
                cname = anchor.next_node.to_s.strip
                ratio = cc[0..0] == "Y" ? 1 : 0.5
                cc = cc[1..-1].to_f * ratio                
                paragraph = anchor.parent.parent
                paragraph.search("span.ctitle").remove
                desc = strip_tags(paragraph.inner_html).gsub(/\s+/,' ').strip rescue ""                
                s_code = ccode + " (UTSC)" 
                subject = find_subject_by_code(s_code)
                if not subject
                    subject = get_subject(s_code)
                end
                
                if @coursechecker[anchor_name].nil?
                    subject.get_course(cnum,cname,desc,cc,:code=>ccode)
                else                  
                    puts "#{anchor_name} already addded to department #{@coursechecker[anchor_name]}"   
                end
                @coursechecker[anchor_name]=subject.name               
             end             
            end

         end
    end 
    def get_name(string)
        normalize(string).gsub(/\d\d[LSPT].*$/,'').gsub(/\(.*?\)/,'').gsub(/ TBA.*$/,'')
    end   
    def start
        doc = doc_at("http://www.artsandscience.utoronto.ca/ofr/calendar/crsindex.htm")
        links =  doc.search("small a")
        links.shift
        #set_s_name "SSC"=>"Social Science"  
        cnames = {
          "FAH246"=>"The Rise and Fall of the Modernist Empire c. 1900 to the Present"        
        }
            
        links.map! do |a|
           _,s_code = a['href'].delete(".htm").split("_")
           s_code.upcase!
           s_name = a.inner_html.gsub(/\s+/,' ').strip
           s_name.slice!(/Courses$/)  
           s_name.slice!(/Department of/)      
           next if s_name =~ /Asian Studies/
           s_code,s_name = s_name.split(" ",2)
           get_subject(s_code,s_name)
           confirm("cont") if s_code.size > 3
           "http://www.artsandscience.utoronto.ca/ofr/calendar/#{a['href']}"
        end
#        links = ["http://www.artsandscience.utoronto.ca/ofr/calendar/crs_env.htm"]
#        links = ["http://www.artsandscience.utoronto.ca/ofr/calendar/crs_nmc.htm"]
        @in_debug = false
        @all_debug = false
        links.compact.each do |link| 
            doc =  doc_at(link).search('td')
            courses_td =doc[2]
            courses_td = doc[1] if courses_td.nil?
            puts link
            bolds = (courses_td.search("strong") || []) + (courses_td.search("b") || [])
            bolds.each do |b|
                puts "******************************" if @in_debug
                segments = b.inner_html.split("<br />").map{|seg|                    
                    normalize(parse(seg).inner_text)
                }.select {|seg| seg.size > 0}
                number_seg = name_seg = next_name_seg = nil                                              
                segments.each do |seg|
                    puts "'" + seg + "'"  if @in_debug
                    if seg =~ /^[A-Z]{3,3} ?\d{3,3}/ and !number_seg
                        number_seg = seg.gsub(/\s+/,'')
                        puts "number seg"  if @in_debug
                    elsif !number_seg.nil?                        
                        name_seg = normalize(seg)                        
                        name_seg = nil if name_seg.size == 0 
                        puts "name seg"  if @in_debug
                    end  
                end
                if number_seg.nil?
#                    next if b.parent.search("b")[1] == b
#                    puts segments.join("\n**********************************\n")
#                    prompt ""
                    next
                end
                if !name_seg or name_seg.size == 0 
                     name_seg = b.next_sibling.inner_text rescue nil
                end                
                scode = number_seg.slice!(/^[A-Z]{3,3}/)      
                number_seg.delete("/").delete(",")
                number_seg.gsub!(/([HY]\d){2}/,'\1')
                courses = number_seg.scan(/\d\d\d[HY]\d/)
                cname = get_name(name_seg) rescue nil               
                courses.each do |course|
#                  puts course
                  cnum  = course.slice!(/^\d\d\d/) 
                  next if scode == "MAT" and 
                          ["123","124","125","126"].include?(cnum)
                  ind = course.slice!(/../)
                  cc = case ind
                         when "Y1";1
                         when "H1";0.5
                         else;0
                       end
                  cdesc = b.parent.next_sibling                                    
                  if (cdesc.at("b") rescue nil)
                    if cdesc.inner_text.match(/Offered/)
                        cdesc = b.parent.next_sibling.next_sibling
                    end
#                    puts cdesc
#                    prompt ""
                  end
                  cdesc = cdesc.inner_html rescue ""                  
                  begin
                    cname ||= cnames["#{scode}#{cnum}"]
                    if cname.nil?
                      cname = next_name_seg
                      puts cname
                      cnewname = prompt "enter name for #{scode + " - " + cnum}"
                      if cnewname.size > 0
                        cname = cnewname
                      end                      
                    end
                    get_subject(scode).get_course(cnum,cname,cdesc,cc)
                  rescue Exception=>e
                    puts e.message 
                    puts courses.join("\n")
                    prompt "cont"
                  end
                end
                puts "******************************"  if @in_debug                
#                subject = get_subject(s_code)
                            
            end
            
        end
#       camp2
#       camp1
    end
    def camp1       
          confused = [ "CHM Chemistry",
                       "CCT Communication, Culture and Information Technology",
                       "CSC Computer Science",
                       "CTE Concurrent Teacher Education",
                       "DTS Diaspora and Transnational Studies",
                       "DRE Drama",
                       "ERS Earth Science",
                       "FAH Fine Art History (FAH)",
                       "FAS Fine Art Studio (FAS)",
                       "FSC Forensic Science",
                       "GGR Geography",
                       "RLG History of Religions",
                       "MGM Management",
                       "PHL Philosophy",
                       "WRI Professional Writing and Communication",
                       "WGS Study of Women and Gender"
                    ]
        
        subject_hash =get_subjects(confused)
        doc_at("http://www.erin.utoronto.ca/regcal/WEBGEN2.html").search("tr li a").each do |link|
            s_name = link.inner_html
            s_code = subject_hash[s_name]
            unless s_code
              s_code = s_name[0,3].upcase
            end           
            next if s_name == "Slavic Language (Croatian)" 
            s_code =  s_code + " (UTM)"
            page_subject = get_subject(s_code,s_name)        
        end
        s_code = nil
        page_subject = nil
        doc_at("http://www.erin.utoronto.ca/regcal/WEBGEN2.html").search("tr li a").each do |link|
                      
            doc_at("http://www.erin.utoronto.ca/regcal/#{link['href']}").at("div.contentpos").search("td").each do |td| 
              unless td['valign'].nil?
                  td1 = td
                  td2 = td.next_sibling
                  code_num_cc = td1.at("a").inner_html.strip
                  s_code = code_num_cc[0..code_num_cc.index(/\d/)-1]
                  #s_code =  s_code + "(UTM)"
                  cnum = code_num_cc[code_num_cc.index(/\d/)..code_num_cc.rindex(/H|Y/)-1]
                  cc = code_num_cc[code_num_cc.rindex(/H|Y/)..-1]
                  ratio = cc[0..0] == "Y" ? 1 : 0.5
                  cc = cc[1..-1].to_f * ratio
                  cname = td2.search("*")[1]
                  cdesc = strip_tags(doc_at("http://www.erin.utoronto.ca/regcal/#{td1.at("a")['href']}").at("span.normaltext").inner_text).gsub(/\s+/,' ').strip                
                  subject = find_subject_by_code(s_code + " (UTM)")
                  if not subject
                      subject = get_subject(s_code + " (UTM)")
                  end
                  if @coursechecker[code_num_cc].nil?
                      subject.get_course(cnum,cname,cdesc,cc,:code=>s_code)
                  else
                      puts "#{code_num_cc} already addded to department #{@coursechecker[code_num_cc]}"   
                  end
                @coursechecker[code_num_cc] = subject.name                      
                  
              end
            end            
        end
    end
end
