var sfz_qian="4201171988";
var sfz_hou4="1638";
var sfzhm="";
for(i=1;i<=12;i++)
{
  //为了程序的方便，我就假设每个月有31天
  for(j=1;j<=31;j++){
		if(i<10){
			if(j<10){
				sfzhm=sfz_qian+"0"+i+"0"+j+sfz_hou4;
			}else{
				sfzhm=sfz_qian+"0"+i+j+sfz_hou4;
			}
			result=getvalidcode(sfzhm);
	        	if(result!=false){
        	        	console.log(result);
        		}
 
		}else{
			if(j<10){
                               sfzhm=sfz_qian+i+"0"+j+sfz_hou4;
                        }else{
                               sfzhm=sfz_qian+i+j+sfz_hou4;
                        }
			result=getvalidcode(sfzhm);
       	 		if(result!=false){
			      console.log(result);
        	        }
		}		
 
		}
	}
 
 
 
function getvalidcode(sfzhm_new){
 
var sum=0;
var weight=[7,9,10,5,8,4,2,1,6,3,7,9,10,5,8,4,2];
var validate=['1','0','X','9','8','7','6','5','4','3','2'];
for(m=0;m<sfzhm_new.length-1;m++){
sum+=sfzhm_new[m]*weight[m];
}
mode=sum%11;
if(sfzhm_new[17]==validate[mode]){
	return sfzhm_new;
}else{
	return false;
}
 
}

