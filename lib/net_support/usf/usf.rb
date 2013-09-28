Info = {
    :name=>"USF",
    :nid=>"16777267",
    :city=>"tampa",
    :region=>"florida",    
    :country=>"united states",
    :semesters=>[

  ["Fall","8/25","12/25"],
  ["Spring","1/1","5/6"],
  ["Summer A","5/10","6/30"],
  ["Summer B","6/30","8/12"],
  ["Summer C","5/10","7/20"]
    ],
    :paths => [
        ["Fall","Spring","Summer A"],
        ["Fall","Spring","Summer B"],
        ["Fall","Spring","Summer C"]

    ]
}          
class UsfParser < CourseParser
    def start
      subjects = Hash.new
      parse(get("http://www.ugs.usf.edu/sab/sabs.cfm")).at("select[@name='SUBJ']").search("option").each do |option|
        if option.attributes['value'] != nil then
          subjects[option.inner_html.strip] = nil
        end
      end

      parse(get("http://www.ugs.usf.edu/sab/sabs.cfm")).at("select[@name='DEPT']").search("option").each do |option|
        subjects[option.attributes['value']] = option.inner_html.strip
      end
      
      subjects.each do |k,v|
      
        if k != nil && k != "" then
          puts "creating subject => #{k.inspect} -- #{v.inspect}"
          xsubject = get_subject(k, v)
          parse(get("http://www.ugs.usf.edu/sab/sabr.cfm?LEV=&COL=&DEPT=&SUBJ=#{k}&NUM=&FULLTITLE=&CR=")).search("td > a").each do |link|
            table = parse(get("http://www.ugs.usf.edu/sab/#{link.attributes['href']}")).at("table[@border=0]")
            if table == nil then
              puts "NO DATA IN THIS TABLE"
            else
              x = table.inner_html.gsub(/[\s+]/,' ').gsub(/> +</, '><').strip
    
              c_number = x.sub(/.*?<tr><td valign="TOP" align="RIGHT"><b>NUMBER\:<\/b><\/td><td valign="TOP" align="LEFT">(.*?)<\/td><\/tr>.*/i,'\1')
              c_name = x.sub(/.*?<tr><td valign="TOP" align="RIGHT"><b>TITLE\:<\/b><\/td><td valign="TOP" align="LEFT">(.*?)<\/td><\/tr>.*/i,'\1')
              c_credits = x.sub(/.*?<tr><td valign="TOP" align="RIGHT"><b>CREDIT HOURS\:<\/b><\/td><td valign="TOP" align="LEFT">(.*?)<\/td><\/tr>.*/i,'\1')
              c_description = x.sub(/.*?<tr><td valign="TOP" align="RIGHT"><b>DESCRIPTION\:<\/b><\/td><td valign="TOP" align="LEFT">(.*?)<\/td><\/tr>.*/i,'\1')
              puts c_number + " " + c_name + " " + c_credits
              xcourse = xsubject.get_course(c_number,c_name,c_description,c_credits)
            end
          end
        end
      end
      
      
    end
end
