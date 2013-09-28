var TimeSaver = Class.create();
var ScheduleDay = Class.create();
var Period = Class.create();
Period.parse = function(periodStr) {
    try{    
        
        start = periodStr.split(" to ",2)[0];
        end = periodStr.split(" to ",2)[1];
        shour = parseInt(start.split(":")[0]);
        if(start.include("pm"))
            shour += 12;
        smin = parseInt(start.split(":")[1]);    
        ehour = parseInt(end.split(":")[0]);
        if(end.include("pm"))
            ehour += 12;            
        emin = parseInt(end.split(":")[1]);
        
        from = new Date();
        to = new Date();
        from.setHours(shour,smin,0,0);
        to.setHours(ehour,emin,0,0);
/*        (from = new Date()).setHours(start.split(":",2)[0],start.split(":",2)[1])
        (to = new Date()).setHours(end.split(":",2)[0],end.split(":",2)[1])
        alert(from)*/
        return new Period(from,to);
        
    }catch(e){}
}
/*
 * Period class represents the a time interval with a set begining and ending 
 * there are some comparison methods to compare two periods
 * 
 */
Period.prototype = {
    initialize : function(start,end) {       
        start.setSeconds(0);
        start.setMilliseconds(0);

        end.setSeconds(0);
        end.setMilliseconds(0);
 
        
        if (start.getTime() >= end.getTime()) {
            throw ""
        }           
      
        this.start = start;
        this.end = end;

    },  
    duration : function(min) {
        duration = Math.abs(this.start.getTime() - this.end.getTime())
        if (min)
            return duration / 1000 / 60
        else    
            return duration / 1000 / 60 / 60
    },
	/*
	 * joins the start time and end time of a period using a character c
	 * the join uses the format helper function to format the times 
	 */  
    join : function(c,hour24) {
        start = this.format(this.start,hour24);
        end = this.format(this.end,hour24);   
        return start + c + end;
    },
	/*
	 * Format the a time to string format of "hh:mm" 
	 * Parameters hour24: if set to true then the stringed time is 24 hour format
	 * 					  if set to false then the stringed time is in 12 hour format with am or pm appened to it
	 */
    format : function(time,hour24) {           
           med = "am";
           hour = time.getHours();          
           if (hour >= 12){                
                hour = hour - 12  ;                 
                med = "pm"; 
           }
           if (hour == 0)
                 hour = 12;           
           min = time.getMinutes();
           if (min == 0)
                min = "00";
           if (hour24)
               return time.getHours() + ":" + min;
           else     
               return hour + ":" + min + " " + med;
    },    
    /*
     * check whether two periods conflict with each other
     */	
    conflicts : function(period) {
         if ((this.start.getTime() <= period.end.getTime() && this.end.getTime() >= period.end.getTime()) ||
             (period.start.getTime() <= this.end.getTime() &&  period.end.getTime() >= this.end.getTime())){
                 
                    return true;                                        
            }        
            else if ((period.start.getTime() >= this.start.getTime() && period.end.getTime() <= this.end.getTime())||
                     (period.start.getTime() <= this.start.getTime() && period.end.getTime() >= this.end.getTime())) {
     
                    return true ;                   
            }        
            else 
                    return false;                         
    },
	/*
	 * fast helper method to get a string format of a period
	 */
    toString : function(){
        return this.join("-",true);
        
    },    
    eql : function(period) {
        return period.join("-") == this.join("-");
    
    }
}
/*
 * Schedule day represent a day with one or many periods 
 * this class is responsible for managing its time and making sure within itself
 * its periods don't conflict
 */
ScheduleDay.prototype = {
    initialize : function(day,time) {
       
        this.day = day;
        this.times = new Array();
        if(time)
           this.addTime(time);      
    },
    getPeriods : function() {
        return this.times.map(function(p){
                return p.toString();       
        })
    
    },
    totalDuration : function() {        
        sum = 0
        this.times.each(function(e){
                sum += e.duration();                
        })
        return sum
    },
    addTime : function(time) {
        newPeriod = time
      
        if (this.times.length == 0)
            this.times.push(newPeriod);            
         else {
            this.times.each(function(period) {
                 if (newPeriod.conflicts(period))
                     throw "conflict in times";                        
            })
        }
       
        this.times.push(newPeriod);   
        this.times = this.times.uniq();      
        
    }
}
TimeSaver = {            
    initialize : function(){
	     $('register_button').style.display = 'none'
         TimeSaver.dayKeyHash = {}
         
    },
    removeTime : function(event,periodString) {           
        period = Period.parse(periodString);
		newDayKeyedHash = {}
        $H(this.dayKeyHash).each(function(pair){                                
				try{
					day = pair.value;   
					tmpArray = [];            
	                day.times.each(function(p){                      
						if (!p.eql(period)) {	                        
							tmpArray.push(p);                       
	                    }
	                });   				                                               
					if (tmpArray.length > 0) {
						newDayKeyedHash[pair.key] = day
						day.times = 	tmpArray
	                }          					
	            }
				catch(e){

				}                       
        }.bind(this));    
		this.dayKeyHash = newDayKeyedHash 
		this.constructTable(this.dayKeyHash);
        return false;
    },
    constructTable : function(dayKeyHash) {
            TimeSaver.dayKeyHash = dayKeyHash;           
            TimeSaver.timeKeyHash = new Hash();
            inputs = "";
			for (day in TimeSaver.dayKeyHash){					
                    try{					
						timesForDay = TimeSaver.dayKeyHash[day]  					
						inputs += "<input type='hidden' name='day["+day+"]' value='";
						timesForDay.times.each(function(period){                                   
	                        if (period instanceof Period){
	                            pstr = period.join(" to ");
	                            if (this[pstr])
	                                this[pstr].push(day);
	                            else
	                                this[pstr] = [day];                   
	                            this[pstr] = this[pstr].uniq();
	                        }
	                        
	                    }.bind(TimeSaver.timeKeyHash));
	                    inputs += timesForDay.getPeriods().join(",") + "' /> ";                
					}catch(e){}
             }
             try {             
                 $('timetable_info').innerHTML = "";             
    			  $('register_button').style.display = 'none'
             }catch(e){}
             $H(TimeSaver.timeKeyHash).each(function(pair) {
                    //key : period time
                    //value : [day1,day2,...]
                    div  = $('timetable_info').appendChild(document.createElement("div"))	
                    div.innerHTML  = pair.value.join(", ") + "&nbsp;&nbsp;&nbsp;" +  pair.key + "&nbsp;&nbsp;&nbsp;"
                    alink = div.appendChild(document.createElement("a"));
                    alink.href = '#';
                    alink.innerHTML = "remove";
                    alink.onclick = function(){return false;}
                    Event.observe(alink,'click',this.removeTime.bindAsEventListener(this,pair.key));                                 
             }.bind(this));
             if ($('timetable_info').innerHTML != "") {
                 new Insertion.Bottom($('timetable_info'),inputs);

                 $('register_button').style.display = 'inline'
             }
           
    },
	/*
	 * save the time for the days that are checked 
	 * each day is a class of schedule day whick keep tracks of the time within that day
	 */
    saveNewTimeTableFor : function(id) {
		 
		 timeselects = new Array();
         dayselects = new Array()  ;       
         $$(".day").each(function(e){
               if (e.checked){
                   e.checked = false;
                   dayselects.push(e.value);
               }
         });
         if ($('start[time]').value.blank() || $('end[time]').value.blank()) {

				showErrorMessageAndHide('message','Please enter start and the finish time for the class.')
                return;
         }      
         start_hour = parseInt($('start[time]').value.split(":")[0]);
         start_min = parseInt($('start[time]').value.split(":")[1]);     
         end_hour =   parseInt($('end[time]').value.split(":")[0]);
         end_min =   parseInt($('end[time]').value.split(":")[1]);
                 
         if (start_hour == 12 && $('ms').value == "am") {
            start_hour = 0
         }else if (start_hour < 12 && $('ms').value == "pm")
               start_hour += 12;  
        
         if (end_hour == 12 && $('me').value == "am") {
               end_hour = 0
         }else if (end_hour < 12 && $('me').value == "pm")
               end_hour += 12;                 
               
         $('start[time]').value = ""
		 $('end[time]').value = ""
		 start = new Date();
         start.setHours(start_hour,start_min);
         end = new Date();
         end.setHours(end_hour,end_min);

         try {
             time = new Period(start,end) ;            
             if (time.duration() >= 8)
                return
             dayselects.each(function(day){                    			
					
					 try{
    					 if (!TimeSaver.dayKeyHash) {
        					 TimeSaver.dayKeyHash = {}
    					 }
    					 if (!TimeSaver.dayKeyHash[day])
                         {                                     
                              if ($H(TimeSaver.dayKeyHash).size() <= 4)
                                  TimeSaver.dayKeyHash[day] = new ScheduleDay(day,time); //raises and exception if the times in a day conflicts                              
                         }
                         else {                                
                            if (TimeSaver.dayKeyHash[day].totalDuration() <= 8)
                                TimeSaver.dayKeyHash[day].addTime(time);  
						 }	
						 
                     }catch(e){}
                     
             });  
			 TimeSaver.constructTable(TimeSaver.dayKeyHash);
         }catch(e){   
            try {			     
			     showErrorMessageAndHide('message','The time you selected is either invalid or conflics with other selected times.')
			}catch(e){}
         }
         return;          
    },
    validateTime : function(textField,meridiem,start) {
        meridiem = $(meridiem);
        time = textField.value;
        time = time.gsub(/[^0-9]/,'');
        
        if (time.length == 0 ) {
            textField.value = "";
            return;
        }
        else if (time.length <= 2 ) {
            time += "00";
        }else if (time.length == 5) {           
            time = time.sub(/\d$/,'');
        }
        min = parseInt(time.sub(/\d+?(\d{2}$)/,'#{1}'));
        hour = parseInt(time.sub(/\d{2}$/,''));
        if (min % 5 <= 2) {
            min = min - (min % 5);
        }else {
            min = min + (5 - (min % 5));
        }
        if(min >= 60)
            min = 0;
        if (min < 10)
            min = "0" + min;
        
        if (hour >= 24 || hour == 0) {
            textField.value = "";
            return;
        }                
        if (hour >= 12) {
            hour = hour % 12;
            if(hour == 0)
                hour = 12;
            $('me').setOptionByValue('pm');
            meridiem.setOptionByValue('pm');   
        }else if (start) {
            if (hour >= 7 && hour <= 11) {
                meridiem.setOptionByValue('am'); 
            }else {
                meridiem.setOptionByValue('pm'); 
                $('me').setOptionByValue('pm');
            }
        }else {
           if (hour >= 1 && hour <= 8) {
                meridiem.setOptionByValue('pm'); 
            }else {
                meridiem.setOptionByValue('am'); 
                $('ms').setOptionByValue('am');
            }             
        
        }
        textField.value = [hour,min].join(":");
    }
    
}