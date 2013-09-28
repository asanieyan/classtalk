Info = {
    :name=>"University OF Minnesota Duluth",
    :nid=>"16827586",
    :city=>"duluth",
    :region=>"minnesota",    
    :country=>"united states",
    :semesters=>[

  ["Fall","10/2", "4/1"],
  ["Spring","4/2", "5/1"],
  ["Summer","5/2", "10/1"] 
  

    ]
}          
class UniversityOfMinnesotaDuluthParser < CourseParser
    def start
      %w(UMNDL).each do |inst|
        parse(get("http://onestop2.umn.edu/courses/designators.jsp?institution=#{inst}")).at("#designator").search("option").each do |option|
                s_code = option['value']
                inside = option.inner_html.strip
                s_name = inside[inside.index("-")+1..inside.size]
                s = get_subject(s_code,s_name,:select_old_name=>true)
                doc = get("http://onestop2.umn.edu/courses/courses.jsp?designator=#{s.code}&submit=Show+the+courses&institution=#{inst}")
                doc = parse(doc)
            begin
              doc.search("span.bodysubtitlered").each do |span|
                c_num = span.inner_html.gsub(/#{s.code}/,'')
                c_name = span.next_sibling
                c_c  = c_name.next_node.next_node.next_node

                c_des = c_c.next_node.next_node
                c_name = c_name.inner_html.gsub(/&nbsp;/,'').sub(/-/,'')
                c_c =  if c_c.text?
                          c_c.to_s.split(";")[0]
                       else
                          ""
                       end
                c_des = c_des.text? ? c_des.to_s : ""
                c = s.get_course(c_num,c_name,c_des,c_c)

              end
            rescue

            end
        end
      end
    end

end
