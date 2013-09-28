Info = {
    :name=>"Georgia Tech",
    :nid=>"16777345",
    :city=>"atlanta",
    :region=>"georgia",    
    :country=>"united states",
    :semesters=>[

  ["Fall","8/20","12/20"],
  ["Spring","1/5","5/5"],
  ["Summer Full","5/14","8/2"],
  ["Summer Short","5/14","7/6"],
  ["Summer Freshmen","6/15","8/2"] 
  
 
  

    ]
}          
class GeorgiaTechParser < CourseParser
    def start

      parse(get("https://oscar.gatech.edu/pls/bprod/bwckctlg.p_disp_cat_term_date?call_proc_in=bwckctlg.p_disp_dyn_ctlg&cat_term_in=200708")).at("select[@name='sel_subj']").search("option").each do |option|

        s_code = option.attributes['value']
        s_name = option.inner_html
        xsubject = get_subject(s_code, s_name)
        page = parse(get("https://oscar.gatech.edu/pls/bprod/bwckctlg.p_display_courses?term_in=200708&sel_subj=dummy&sel_levl=dummy&sel_schd=dummy&sel_coll=dummy&sel_divs=dummy&sel_dept=dummy&sel_attr=dummy&sel_subj=#{s_code}&sel_crse_strt=&sel_crse_end=&sel_title=&sel_levl=%25&sel_schd=%25&sel_coll=%25&sel_divs=%25&sel_dept=%25&sel_from_cred=&sel_to_cred=&sel_attr=%25")).inner_html.gsub(/\s+/,' ').gsub(/> +</,'><')

     
if s_code == "ESL" then
        page.scan(/<td bgcolor="#ff0000".*?<td class="ntdefault">.*?Continuing Education/).each do |course|
          line = course.sub(/<td bg.*?>(.*?)<\/td>.*/,'\1').sub(/#{s_code}/,'').strip
          c_number = line.split(' - ')[0]
          c_name = line.split(' - ')[1]
          c_description = course.sub(/.*<td class="ntdefault">(.*?)<br.*/,'\1').strip
          c_credits = course[/\d+\.\d+ Continuing/].sub(/^(\d+).*/,'\1')

          xcourse = xsubject.get_course(c_number, c_name, c_description, c_credits)

        end

else
        page.scan(/<td bgcolor="#ff0000".*?<td class="ntdefault">.*?Credit Hours/).each do |course|

          line = course.sub(/<td bg.*?>(.*?)<\/td>.*/,'\1').sub(/#{s_code}/,'').strip
          c_number = line.split(' - ')[0]
          c_name = line.split(' - ',2)[1]
          c_description = course.sub(/.*<td class="ntdefault">(.*?)<br.*/,'\1').strip
          c_credits = course[/\d+\.\d+ Credit/].sub(/^(\d+).*/,'\1')

          xcourse = xsubject.get_course(c_number, c_name, c_description, c_credits)

        end
end
      end
      
    end
end
