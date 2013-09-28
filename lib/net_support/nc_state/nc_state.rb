Info = {
    :name=>"N.C. State",
    :nid=>"16777335",
    :city=>"raleigh",
    :region=>"north carolina",    
    :country=>"united states",
    :semesters=>[

  ["Fall","8/20","12/25"],
  ["Spring","1/1","5/10"],
  ["Summer 1","5/21","6/26"],
  ["Summer 2","7/2","8/3"],
  ["Summer 10w","5/21","8/8"]


    ],
    :paths => [
      ["Fall","Spring","Summer 1", "Summer 2"],
      ["Fall","Spring","Summer 10w"]
    ]
}          
class NcStateParser < CourseParser
    def start
      parse(get("http://www2.acs.ncsu.edu/reg_records/crs_cat/directory.html")).search("li > a").each do |link|

        s_code = link.at("b").inner_html.split(" - ")[0]
        s_name = link.at("b").inner_html.split(" - ")[1]       
        
        xsubject = get_subject(s_code, s_name)
        if s_code =~ /AGI/i then
          
#          {
#                      'AGI'=>'AGRICULTURAL INSTITUTE',
#                      'AEE'=>'AGRICULTURAL AND EXTENSION EDUCATION',
#                      'ANS'=>'ANIMAL SCIENCE',
#                      'ARE'=>'AGRICULTURAL AND RESOURCE ECONOMICS',
#                      'BAE'=>'BIOLOGICAL AND AGRICULTURAL ENGINEERING',
#                      'CS'=>'CROP SCIENCE',
#                      'ENT'=>'ENTOMOLOGY',
#                      'FS'=>'FOOD SCIENCE',
#                      'HS'=>'HORTICULTURAL SCIENCE',
#                      'PE'=>'PHYSICAL EDUCATION',
#                      'PO'=>'POULTRY SCIENCE',
#                      'PP'=>'PLANT PATHOLOGY',
#                      'SOC'=>'SOCIOLOGY',
#                      'SSC'=>'SOIL SCIENCE',
#                      'TOX'=>'TOXICOLOGY',
#                      'VMF'=>'VETERINARY MEDICINE',
#                      'ZO'=>'ZOOLOGY'
#          }.each do |agi_s_code, agi_s_name|
#            agi_subject = get_subject(agi_s_code, agi_s_name)
#            page = parse(get("http://ceres.cals.ncsu.edu/cfdocs/star/modules/websitebuilder2/WebSite/index.cfm?CurrentWebSiteID=169&CurrentLocation=11")).inner_html
#
#            puts "*"*40
#            puts page[/<p><font face="arial">.*?#{agi_s_code} \d{3}.*?<\/font><\/p>/mi]
#            
#            
#          end
        else
          course_description_pg = parse(get("http://www2.acs.ncsu.edu/reg_records/crs_cat/#{link.attributes['href']}")).at("li").at("a").attributes['href'].split('#')[0]
          get_next_line = false
          
          c_name = nil
          c_number = nil
          c_credits = nil
          c_description = nil
          
          parse(get("http://www2.acs.ncsu.edu/reg_records/crs_cat/#{course_description_pg}")).search("tr").each do |tr_tag|
            if get_next_line == true then
              if tr_tag.inner_html =~ /Preq\:|Coreq\:/ then
                #puts "preq/coreq line"
              elsif tr_tag.inner_html =~ /#{s_code}/ && tr_tag.inner_html =~ /<td>.*?<td>.*?<td>/ then
                raise "FUUUUUUUUUUUUUUUUUUUUUUUUCK"
              else
                c_description = tr_tag.at("td").inner_html
                puts s_code + " " + c_number + " " + c_name + " " + c_credits
                xcourse = xsubject.get_course(c_number,c_name,c_description,c_credits)
                get_next_line = false
              end
            elsif tr_tag.inner_html =~ /#{s_code}/ && tr_tag.inner_html =~ /<td>.*?<td>.*?<td>/ then
              td_tags = tr_tag.search('td')
              c_number = td_tags[0].at('b').at('a').inner_html.gsub(/\(.*?\)/,'').gsub(/ {2,}/, ' ').sub(/.*? (.*?)/, '\1')
              c_name = td_tags[1].at('b').inner_html
              c_credits = td_tags[2].at('i').inner_html[/^\d+/].sub(/\(/,'') rescue c_credits = "0"
              
              



              get_next_line = true 
            end
          end
        end
        
      end
    end
end
