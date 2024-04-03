

var interval_shade;
var el_opacity =0;
var opacity_var = 100;

function Index_EventHandler(){

  document.getElementById("name_input").addEventListener("keyup" , limitaTesto , false);
}


function limitaTesto(el , input_name_limit){
    if(el.value.length > input_name_limit){
        el.value = el.value.substring(0 , input_name_limit);

        var message_container_id = '';
        var number_max;
        var t;
    
        if(el.id == 'name_input') {
          message_container_id = 'wrong_name_input_display';
          number_max = 15;
          t='username';
        }else{
          message_container_id = 'wrong_password_input_display';
          number_max = 120;
          t='password';
        }
        var tum =   document.getElementById(message_container_id);
    
        tum.innerHTML = "Il campo "+t+" contiene massimo "+number_max+" caratteri.";
        opacity_var = 100;
        el_opacity = tum;
        
        interval_shade = setInterval(set_msg_shade ,70);
    }
   
 }

 function set_msg_shade(){
   el_opacity.style.opacity =  opacity_var+'%';

   if(opacity_var <= 20){
      opacity_var = 0;
      el_opacity.style.opacity =  '0%';
      clearInterval(interval_shade);
   }else{
    opacity_var --;
   }
 }