Info = {
    :name=>"Purdue",
    :nid=>"16777354",
    :city=>"west lafayette",
    :region=>"indiana",    
    :country=>"united states",
    :semesters=>[
      ["Fall","8/16"],
      ["Spring","1/1"],
      ["Summer 1st Module","5/10"],
      ["Summer 2nd Module","6/10"],
      ["Summer 3rd Module","7/10"],      
    ]
}          
class PurdueParser < CourseParser
    def start
      base_url = "http://www.courses.purdue.edu"
     
      doc = doc_at("http://www.courses.purdue.edu/cgi-bin/relay.exe/query?adminCampusLocation=westLafayette&academicProgramDesignation=&submitController=&qid=courseCatalogSubjectList")
      table = doc.search("table[@cellpadding=4]")[1]
      trs = table.search("tr")
      trs.shift;
      trs.each do |tr|
          link = tr.at("td > a")
          href = base_url + link['href']
          s_code = link.at("b").inner_html
          s_name = link.at("b").next_node.to_s.sub(/-/,'')
          subject = get_subject(s_code,s_name)
          trs2 = doc_at(href).search("table[@cellpadding=4]")[1].search("tr") rescue next
          trs2.shift;      
          trs2.each do |tr2|    
            link2 = tr2.search("a")[1]
            cnum,cname = link2.inner_html.split(" - ",2)
            #s_code2 = tds2[0].inner_html.strip          
            href2 = base_url + link2['href']
  
            cc = 0
            desc = ""
            desc_table = doc_at(href2).at("h2").next_sibling
            if desc_table
              desc_table.search("td[@align='right']").each do |desc_td|
                   if desc_td.at("b").inner_html =~ /Credits/
                     cc = desc_td.next_sibling.inner_html 
                   end  
                   if desc_td.at("b").inner_html =~ /Description/
                     desc = desc_td.next_sibling.inner_html 
                   end
              end
            end
            subject.get_course(cnum,cname,desc,cc)    
          end      
      end
      
    end
end
