Info = {
    :name=>"University of Alberta",
    :nid=>"16778421",
    :city=>"edmonton",
    :region=>"alberta",    
    :country=>"canada",
    :semesters=>[
      ["Fall","9/1"],
      ["Winter","1/1"],
      ["Spring","5/1"],
      ["Summer","7/1"]                 
    ]
}          
class UniversityOfAlbertaParser < CourseParser
    def start     
#       options = {"cookie"=>"sedm9022-8089-PORTAL-PSJSESSIONID=GJZXJlks4pLyZt1R524Q1yvYKwGpjKJl!-2126390033; SignOnDefault=; ExpirePage=https://www.beartracks.ualberta.ca/servlets/iclientservlet/uahebprd/; PS_LOGINLIST=https://www.beartracks.ualberta.ca/uahebprd; PS_TOKENEXPIRE=29_Aug_2007_02:29:17_GMT; PS_TOKEN=AAAAogECAwQAAQAAAAACvAAAAAAAAAAsAARTaGRyAgBObwgAOAAuADEAMBQUNsTvRgmWK8S8A95tO6BqTU4afgAAAGIABVNkYXRhVnicNYrBCYAwEAQnKj7TiUFDIDag+YgIiW9LsEGLcw14A7N3xwK3adoOg6Z5PluySJwsytIrdpLl0LVSuNjIAc8oIoM8y756IuC0Rzno42rr5wWS8gvY"}
#               new_url =  "https://www.beartracks.ualberta.ca/servlets/iclientservlet/uahebprd/?ICType=Panel&Menu=SA_LEARNER_SERVICES&Market=GBL&PanelGroupName=CATALOG_SEARCH"
#               post_data = "ICType=Panel&ICElementNum=0&ICStateNum=3&ICAction=CATLG_SRCH_WRK_CLASS_SRCH_PB&ICXPos=0&ICYPos=0&ICFocus=&ICChanged=-1&CATLG_SRCH_WRK_INSTITUTION%2412%24=UOFAB&TERM_CAT_REG%24rad=R&TERM_CAT_REG=R&ZSS_DERIVED_ZSS_CATLG_SCHED_FL%24chk=&SS_SUBJECT_DROP=AFHE&CATLG_SRCH_WRK_CATALOG_NBR%2423%24=&CATLG_SRCH_WRK_EXACT_MATCH1=W"
#               resp = post(new_url,post_data,
#                  options.update("Referer"=>"https://www.beartracks.ualberta.ca/servlets/iclientservlet/uahebprd/?ICType=Panel&Menu=SA_LEARNER_SERVICES&Market=GBL&PanelGroupName=CATALOG_SEARCH"))
#              puts resp               
#               parse(resp).search("table.PSFRAME[@width='653']").each do |table|
#                    trs = table.search("tr")
#                    trs.shift;
#                    tr1 = trs.shift
#                    tds = tr1.search("td")
#                    tds.shift;
#                    s_code = tds.shift.at("div").inner_html
#                    c_num  = tds.shift.at("div").inner_html
#                    p s_code
#               end        
#        parse(post(url,
#               "ICType=Panel&ICElementNum=0&ICStateNum=11&ICAction=LS_LINK_WRK_SS_VIEW_CAT_LINK&ICXPos=0&ICYPos=0&ICFocus=&ICChanged=-1",
#                options)).at("#SS_SUBJECT_DROP").search("option").each do |option|
#                s_code = option['value']     
#                s_name = option.inner_html.sub(/#{s_code} - /,'')
#
#        end
    end
end
