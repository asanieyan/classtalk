Info = {
    :name=>"McGill University",
    :nid=>"16777353",
    :city=>"montreal",
    :region=>"quebec",    
    :country=>"canada",
    :semesters=>[
      ["Fall","9/1"],
      ["Winter","1/1"],
      ["Summer","5/1"]
    ]
}          
class McgillParser < CourseParser
    def start
    
      ["200709","200801","200805"].each do |term_date|
      #["200709"].each do |term_date|

      parse(post("https://banweb.mcgill.ca/mcgp/bwckctlg.p_disp_cat_term_date?call_proc_in=bwckctlg.p_disp_dyn_ctlg&search_mode_in=&cat_term_in=#{term_date}",nil)).at("select[@name='sel_subj']").search("option").each do |subject|

        begin

        if subject.attributes['value'] != "%"  && subject.attributes['value'] != "EXTL" then
          s_code = subject.attributes['value']
          s_name = subject.inner_html.sub(/.* - /,'')
          xsubject = get_subject(s_code, s_name)

          

          parse(post("https://banweb.mcgill.ca/mcgp/bwckctlg.p_display_courses?term_in=#{term_date}&sel_subj=dummy&sel_levl=dummy&sel_schd=dummy&sel_coll=dummy&sel_divs=dummy&sel_dept=dummy&sel_attr=dummy&search_mode_in=&sel_subj=#{subject.attributes['value']}&sel_crse_strt=&sel_crse_end=&sel_title=&sel_levl=%25&sel_schd=%25&sel_divs=%25&sel_dept=%25&sel_from_cred=&sel_to_cred=&sel_attr=%25", nil)).search("td[@class='nttitle'] a").each do |course_link|

            begin

            course_desc_table = parse(post("https://banweb.mcgill.ca#{course_link.attributes['href']}",nil)).at("table[@class='datadisplaytable']")
            
            name_and_number = course_desc_table.at("td[@class='nttitle']").inner_html
            
            c_name = name_and_number.sub(/.*- (.*)./,'\1')

            c_number = name_and_number.sub(/\D*(\d+).*/,'\1')

            c_description = course_desc_table.at("td[@class='ntdefault']").inner_html.sub(/(.*)\n\<br(.*\n)*/,'\1')

            c_credits = course_desc_table.at("td[@class='ntdefault']").inner_html[/\d\.\d+/]

            course = xsubject.get_course(c_number,c_name,c_description,c_credits)

            puts c_number + "-" + c_name

            #puts c_name + " " + c_number + " " + c_description


            rescue Exception => e
              puts "EXCEPTION!"
              puts term_date.to_s
              puts subject.attributes['value']
              puts e
            end

          end
          
        end
        
        rescue Exception => e
          puts "EXCEPTION!"
          puts term_date.to_s
          puts subject.attributes['value']
          puts e

        end
        
      end 
        
      end
    end
end
