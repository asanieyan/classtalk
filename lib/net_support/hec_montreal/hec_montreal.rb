Info = {
    :name=>"HEC Montreal",
    :nid=>"16778710",
    :city=>"montreal",
    :region=>"quebec",    
    :country=>"canada",
    :semesters=>[
    
      ["Automne","8/25","12/25"],
      ["Hiver","1/4","5/10"],
      ["Ete","5/1","8/20"],
     
    ]
}          
class HecMontrealParser < CourseParser
    def start
    
    end
    def start0
      
      ["BAA","CERT","MBA","MSC","DES","PHD","APRE"].each do |category|
      
        parse(get("http://zonecours.hec.ca/accueil.txp?lang=fr&t=programme&v=#{category}")).at("table[@class='tableauNormal2']").search("tr").each do |row|

          s_name = row.search("td")[1].inner_html.sub(/.*\((.*)\)/,'\1')
          s_code = row.search("td")[1].inner_html.sub(/.*\((.*)\)/,'\1')

          xsubject = get_subject(s_code,s_name)

          c_number = row.search("td")[0].inner_html
          c_name = row.search("td > a").inner_html

          doc = parse(get("http://zonecours.hec.ca/#{row.at('td > a').attributes['href']}"))

          c_description = doc.at("div[@class='texte']").inner_html

          c_credits = doc.at("div[@id='encadreNewsAnnuaire']").search("div")[5].inner_html[/\d+/m]

          course = xsubject.get_course(c_number,c_name,c_description,c_credits)
        end
      
      end
      
    end
end
