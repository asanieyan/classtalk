Info = {
    :name=>"New Mexico",
    :nid=>"16777333",
    :city=>"albuquerque",
    :region=>"new mexico",    
    :country=>"united states",
    :semesters=>[
  ["Fall 16WK","8/20", "12/25"],
  ["Fall 8WK1","8/20", "10/13"],
  ["Fall 8WK2","10/15", "12/25"],
  ["Spring 16WK","1/16", "5/12"],
  ["Spring 8WK1","1/16", "3/10"],
  ["Spring 8WK2","3/19", "5/12"],
  ["Summer 8WK","6/4", "7/28"],
  ["Summer 6WK","6/4", "7/14"], 
  ["Summer 4WK1","6/4", "6/30"],     
  ["Summer 4WK2","7/2", "7/28"]     
    ]
}          
class NewMexicoParser < CourseParser
    def start
      doc = parse(post("https://www8.unm.edu/pls/banp/bwckctlg.p_disp_cat_term_date","call_proc_in=&cat_term_in=200780"))
      doc.at("#subj_id").search("option").each do |option|
          scode = option['value']      
          sname = option.inner_text
          s = get_subject(scode,sname)                    
          s_doc = parse(post("https://www8.unm.edu/pls/banp/bwckctlg.p_display_courses","term_in=200780&sel_subj=dummy&sel_levl=dummy&sel_schd=dummy&sel_coll=dummy&sel_divs=dummy&sel_dept=dummy&sel_attr=dummy&sel_subj=#{s.code}&sel_crse_strt=&sel_crse_end=&sel_title=&sel_levl=%25&sel_schd=%25&sel_divs=%25&sel_dept=%25&sel_from_cred=&sel_to_cred=&sel_attr=%25"))
          s_doc.search("td.nttitle a").each do |link|
              code,cname = link.inner_text.split(" - ")
              code.slice!(/#{s.code}/)
              cnum = normalize(code)
              href = "https://www8.unm.edu#{link['href']}".gsub(/&amp;/,'&')
              c_doc = doc_at(href)
              cdesc = normalize(c_doc.at("table.datadisplaytable").search("tr")[1].inner_text)
              cc = cdesc.slice(/\d+\.\d+ Credit Hours/)
              s.get_course(cnum,cname,cdesc,cc.to_f)
          end
      end
    end
end
