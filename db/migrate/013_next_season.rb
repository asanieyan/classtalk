class NextSeason < ActiveRecord::Migration
    def self.up
#        change_column :semesters,:next_sem_id,:string
#        change_column :semesters,:pre_sem_id,:string
        
        add_column :seasons,:parent_id,:integer
        add_column :seasons,:lft,:integer
        add_column :seasons,:rgt,:integer       
        add_column :seasons,:start_str,:string,:limit=>5
        add_column :seasons,:end_str,:string,:limit=>5

        begin
        remove_index "semesters",:name=>"semesters_school_id_index" rescue nil
        add_index "semesters",["school_id","start_date","end_date"],:unique=>true,:name=>"uniq_semesters"  rescue nil
        Semester.reset_column_information 
        Season.reset_column_information 
        School.find(:all).each do |school|          
          puts school.name
          school.seasons.each_with_index do |season,i|
              next_season =  school.seasons[i+1]
              start_str =    [season['start_month'].to_s,season['start_day'].to_s].join("/")
              end_str   =    [season['end_month'].to_s,season['end_day'].to_s].join("/")
              Season.update_all("start_str = '#{start_str}', end_str = '#{end_str}'","id = #{season.id}")
              season.reload
              if next_season  
                season.add_child(next_season)
              end
          end          
          school.outline_seasons
          
        end
        rescue Exception=>e
          self.down
          raise e
        end

    end
    def self.down
       remove_column :seasons,:start_str
       remove_column :seasons,:end_str
       remove_column :seasons,:parent_id       
       remove_column :seasons,:lft
       remove_column :seasons,:rgt
    end
end