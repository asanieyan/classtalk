Info = {
    :name=>"Texas",
    :nid=>"16777296",
    :city=>"austin",
    :region=>"texas",    
    :country=>"united states",
    :semesters=>[
      ["Fall","8/25"],
      ["Spring","1/1"],
      ["1st Term Summer","6/1"],
      ["2nd Term Summer","7/12"]      
    ]
}          
class TexasParser < CourseParser
    def reset_session
        if @response.body =~ /please log in!/          
          login = "CDT=20070830094053&NEW_PASSWORD=&CONFIRM_NEW_PASSWORD=&PASSWORDS=&LOGON=ka6262&PASSWORDS=CLITO113"
          login("https://utdirect.utexas.edu/security-443/logon_check.logonform",login);
        end
    end
    def start
        options = {}
        url =  "https://utdirect.utexas.edu/registrar/nrclav/index.WBX?s_ccyys=20079#field_and_level"
        url2 = "https://utdirect.utexas.edu/registrar/nrclav/results.WBX"
        html = get(url,options);
        parse(html).at("select[@name='s_field_of_study']").search("option").each do |option|
          s_code = option['value']
          s_name = option.inner_html.gsub(/#{s_code} &#45;(.*)/,'\1').strip
          years = %w(2007)
          years.each do |year|
            %w(2 6 9).each do |s|
              calendar = year + s
              p calendar
              s_calendar = calendar.match(/\d\d\d$/).to_s
              subject = get_subject(s_code,s_name);
              %W(L U G).each do |l|
                parse(post("https://utdirect.utexas.edu/registrar/nrclav/results.WBX","s_ccyys=#{calendar}&s_search_type=FIELD&s_field_of_study=#{s_code}&s_level=#{l}&s_mtg_start_time=+&s_mtg_days=+",options)).search("tr.tbon").each do |row|
                    #text = row.at("span.em").search("*").first
                    begin 
                           x = row.at("span.em")                      
                           c = x.at("span.on")
                           x = x.inner_html.gsub(/#{c.to_html}/,'').strip
                           c_name = c.inner_html.strip
                           c_num = x.gsub(/#{s_code}\s+(\S+)/,'\1')
                           if %w(N S F W).include?(c_num[0..0])
                              c_num = c_num[1..-1]
                           end
                           c_credit = c_num.match(/./).to_s.to_i
                           desc = ""
                           course = subject.get_course(c_num,c_name,desc,c_credit)
#                           q = row.next_sibling.at("a").inner_html.strip
#                           raise "no uique for #{s_code}-#{c_num}" unless q =~ /\d+/
#                           url3 = "https://utdirect.utexas.edu/registrar/nrclav/details.WBX?s_yys=#{s_calendar}&s_unique=#{q}"
#    #                       url3 = "https://utdirect.utexas.edu/registrar/nrclav/details.WBX?s_yys=076&s_unique=71115"
#                           c_desc = parse(get(url3,options))
#                           c_desc = c_desc.at("p.ctx").inner_html.gsub(/\s+/,' ').gsub(/<span.*>/,'')
                           
                           
                    rescue Exception=>e
#                        p e.message
                    end
                end
              end
            end   
          end      
        end
    end
end
