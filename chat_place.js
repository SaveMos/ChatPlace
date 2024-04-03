
var tema_corrente = 0;
var chat_selezionata = 0; // booleano che indica se l'utente ha selezionato una chat
var chat_privata = 0; // booleano che indica il tipo di chat corrente
var current_user_name = '';

function EventHandler(){

    update_interface_for_current_chat();

    load_theme(); // funzione che carica il tema scelto dall utente

    var file_input = document.getElementById("file_send");
    file_input.addEventListener("change" , update_file_list , false);

    var contact_searcher_input = document.getElementById("contact_searcher_input");
    contact_searcher_input.addEventListener("keyup" , update_search_contact_list , false);

    var delete_chat_button = document.getElementById("delete_chat");
    delete_chat_button.addEventListener("click" , delete_chat , false);

    var change_theme_button = document.getElementById("change_theme");
    change_theme_button.addEventListener("click" , inverti_tema , false);

    var upload_button = document.getElementById("send_button");
    upload_button.addEventListener("click" , upload_message , false);

    var message_box = document.getElementById("message_box");
    message_box.addEventListener("keyup" , upload_message_with_enter , false);

    var new_group_button = document.getElementById("crea_gruppo");
    new_group_button.addEventListener("click" , nuovo_gruppo , false);

    var delete_group_button = document.getElementById("cancella_gruppo");
    delete_group_button.addEventListener("click" , cancella_gruppo , false);

    var rename_group_button = document.getElementById("rinomina_gruppo");
    rename_group_button.addEventListener("click" , rinomina_gruppo , false);
 
    var contact_list = document.getElementById("contact_list").childNodes;
    for(const t of contact_list) t.addEventListener('click' , load_Chat , false);
    
    current_logged_user_loader();

    current_chat_loader();
}

function nuovo_gruppo(){
   
    var nome_g = prompt("Nome del nuovo Gruppo?");
    nome_g = nome_g.trim();

    var uri = "esegui_operazione_gruppo.php?op="+1+"&nome_g="+nome_g;
  
    fetch(uri)
    .then(location.reload());

}
function cancella_gruppo(){
    if(chat_selezionata == 0 || chat_privata == 1) return;
    var r = confirm("Sei sicuro/a di eliminare il gruppo? tutti i messaggi saranno eliminati");

    if(r){
        var uri = "esegui_operazione_gruppo.php?op="+2;
        fetch(uri)
        .then(location.reload());
    }
    
}
function rinomina_gruppo(){
    if(chat_selezionata == 0 || chat_privata == 1) return;
    var nome_g = prompt("Nuovo nome del gruppo?");
    nome_g = nome_g.trim();

    var uri = "esegui_operazione_gruppo.php?op="+3+"&nome_g="+nome_g;

    fetch(uri)
    .then(location.reload());
}

function upload_message(){
    if(chat_selezionata == 0) return;
    const mess= document.getElementById("message_box").value.trim(); // messaggio scritto nel campo input

    const p = document.getElementById("file_send").files; // Numero dei file caricati

    if( (mess == '') && (p.length == 0) ) return; // se non ho scritto nessun carattere E non ho caricato nessun file esco
 
    var uri = "upload_message.php?msg_text="+mess;

    fetch(uri)
    .then(response => response.json())
    .then(text => upload_files(text));
}

function upload_message_with_enter(){
    if(event.keyCode === 13) upload_message();
}

function upload_files(txt){
   
    let p = new Array();
    p = document.getElementById("file_send").files;

    if(p.length == 0){
        update_chat_box(txt , null);
        return;// se non sono stati caricati file
    } 
       
    const uri = 'upload_files.php';

    let pack_files_dataForm = new FormData(); // l oggetto che devo inviare alla pagina php

    for(let c = 0 ; c < p.length ; c++) {
        pack_files_dataForm.append("file"+c , p[c]);
    }
    
    var x = new XMLHttpRequest;
    x.open('POST' , 'upload_files.php');
    x.send(pack_files_dataForm);
    x.responseType = 'json'; // dal server ricevo un file json

    x.addEventListener("readystatechange" , function(){
            if(this.readyState === 4){
                update_chat_box(txt , this.response);
            }
    });

}

function update_chat_box(txt , files){
   
   var message_el = document.createElement('div');
   message_el.className = "messaggio_chat";

   if(txt['msg'] == '' && files === null) return;
   aggiungi_messaggio(txt , message_el);


   if(files === null) return;
   print_files_of_the_message(files , message_el);

   document.getElementById("message_form").reset();
   document.getElementById("file_list").textContent = 'Nessuno';
 
}

function aggiungi_messaggio(txt , mess_body){
    if(txt['msg'] == '') {
        txt['msg'] = '*no-text*';
    }

    const chat_box = document.getElementById("chat_monitor");
   
    var mess_txt  = document.createTextNode("["+ txt['times']+"] "+txt['Mitt']+": " + txt['msg']);
    
    let visualizzato_dot = document.createElement("span");
    visualizzato_dot.className = "visualizzato_dot";

    visualizzato_dot.style.color = 'rgb(31, 168, 43)';
    visualizzato_dot.style.backgroundColor = 'rgb(31, 168, 43)';

    visualizzato_dot_text = document.createTextNode(".");
    visualizzato_dot.appendChild(visualizzato_dot_text);

    mess_body.appendChild(visualizzato_dot); 
    mess_body.appendChild(mess_txt);

    chat_box.insertBefore(mess_body , chat_box.firstChild);

    document.getElementById("message_box").value = '';  
}

function load_theme(){
    var uri = "get_theme.php";
    fetch(uri)
    .then(response => response.json())
    .then(text => modifica_tema(text));
}

function inverti_tema(){
    var uri = "change_theme.php";
    fetch(uri)
    .then(response => response.json())
    .then(text => modifica_tema(text));
}

function modifica_tema(tema){
    tema_corrente =tema;

    const contact_list = document.getElementById("contact_list");
    const contact_list_childs = contact_list.childNodes;

    if(tema_corrente == 0){
        contact_list.style.backgroundColor = "gainsboro";
        contact_list.style.color = "black";
        document.getElementById("chat_monitor").style.backgroundColor = "whitesmoke";
        document.getElementById("chat_monitor").style.color = "black";
        document.getElementById("current_chat_info_container").style.backgroundColor = "whitesmoke";
        document.getElementById("message_box_container").style.backgroundColor = "whitesmoke";
        document.getElementById("message_box_container").style.color = "black";  
        document.getElementById("logged_user_console").style.backgroundColor = "whitesmoke";
        document.getElementById("message_box").style.backgroundColor = "whitesmoke";
        document.getElementById("contact_searcher_input").style.backgroundColor = "whitesmoke";
        document.getElementById("send_button").style.backgroundColor = "gainsboro";
        document.getElementById("file_send").style.backgroundColor = "gainsboro";
        document.getElementById("logout_button").style.backgroundColor = "gainsboro";
        document.getElementById("delete_chat").style.backgroundColor = "gainsboro";
        document.getElementById("change_theme").style.backgroundColor = "gainsboro";
        document.getElementById("crea_gruppo").style.backgroundColor = "gainsboro";
        document.getElementById("rinomina_gruppo").style.backgroundColor = "gainsboro";
        document.getElementById("cancella_gruppo").style.backgroundColor = "gainsboro";
        document.getElementById("suggested_contact_list_container").style.backgroundColor = "whitesmoke";
        document.getElementById("suggested_contact_list_container").style.color = "black";
        document.getElementById("current_logged_display").style.color = "black";
        document.getElementById("current_contact_name").style.color = "black";
        document.getElementById("file_selector_label").style.color = "black";
        document.getElementById("file_selector_label").style.backgroundColor = "gainsboro";
      
        for(const t of contact_list_childs) t.className = "contact_list_element_white";
       
    }else{
        contact_list.style.backgroundColor = "grey";
        contact_list.style.color = "gainsboro";
        document.getElementById("chat_monitor").style.backgroundColor = "#6F7073";
        document.getElementById("chat_monitor").style.color = "gainsboro";
        document.getElementById("current_chat_info_container").style.backgroundColor = "#4A4B4C";
        document.getElementById("current_logged_display").style.color = "gainsboro";
        document.getElementById("message_box_container").style.backgroundColor = "#4A4B4C";
        document.getElementById("message_box_container").style.color = "gainsboro";
        document.getElementById("logged_user_console").style.backgroundColor = "grey";
        document.getElementById("message_box").style.backgroundColor = "#ADAFB2";
        document.getElementById("contact_searcher_input").style.backgroundColor = "#ADAFB2";
        document.getElementById("send_button").style.backgroundColor = "#ADAFB2";
        document.getElementById("file_send").style.backgroundColor = "#ADAFB2";
        document.getElementById("logout_button").style.backgroundColor = "#ADAFB2";
        document.getElementById("delete_chat").style.backgroundColor = "#ADAFB2";
        document.getElementById("change_theme").style.backgroundColor = "#ADAFB2";
        document.getElementById("crea_gruppo").style.backgroundColor = "#ADAFB2";
        document.getElementById("rinomina_gruppo").style.backgroundColor = "#ADAFB2";
        document.getElementById("cancella_gruppo").style.backgroundColor = "#ADAFB2";
        document.getElementById("suggested_contact_list_container").style.backgroundColor = "#6F7073";
        document.getElementById("suggested_contact_list_container").style.color = "gainsboro";
        document.getElementById("current_contact_name").style.color = "whitesmoke";
        document.getElementById("file_selector_label").style.backgroundColor = "#ADAFB2";
        document.getElementById("file_selector_label").style.color = "black";


        for(const t of contact_list_childs) t.className = "contact_list_element_black";   

        


        
        

    }
}

function delete_chat(){
    if(chat_selezionata == 0) return;
    
    let decisione = confirm("Sei sicuro/a di cancellare la chat? L'altra persona o gli altri partecipanti del gruppo potranno comunque vedere i messaggi precedenti alla cancellazione. Confermi di procedere?");
   
    if(decisione) {
        var uri = "cancella_chat.php";

        fetch(uri)
        .then(response => response.json())
        .then(text => location.reload());

    }
}

function update_search_contact_list(){
    var tip = document.getElementById("contact_searcher_input").value;

    if(tip == '' || tip === null) {
        clear_suggested_contact_box();
        return;
    }

    var uri = "get_list_of_contact.php?tip="+tip;

    fetch(uri)
    .then(response => response.json())
    .then(text => print_suggested_users(text));

}

function print_suggested_users(suggest_users){
   
   clear_suggested_contact_box()
    const container = document.getElementById("suggested_contact_list_container");
    
    var backcolor_bottone = "gainsboro";
    if(tema_corrente) backcolor_bottone = "#ADAFB2";

    for(var i in suggest_users){
        var list_el = document.createElement("p");
        list_el.className="suggested_contact_list_element";

        var list_el_span = document.createElement("span");
        list_el_span.className="suggested_contact_list_element_span";
        list_el_span.id = suggest_users[i]['name_suggest'];
        list_el_span.onclick = start_chat;
        var list_el_text = document.createTextNode(suggest_users[i]['name_suggest']);
        list_el_span.appendChild(list_el_text);

        var group_button1 = document.createElement("button");
        group_button1.name = suggest_users[i]['name_suggest'];
        group_button1.className = "bottone_gestione_gruppo";
        group_button1.style.backgroundColor = backcolor_bottone;
        group_button1.addEventListener("click" , operazione_gruppo_utente , false);
        var group_button1_text = document.createTextNode('-');
        group_button1.appendChild(group_button1_text);
        group_button1.value = 5; 

        var group_button2 = document.createElement("button");
        group_button2.name = suggest_users[i]['name_suggest'];
        group_button2.style.backgroundColor = backcolor_bottone;
        group_button2.addEventListener("click" , operazione_gruppo_utente, false);
        group_button2.className = "bottone_gestione_gruppo";
        var group_button2_text = document.createTextNode('+');
        group_button2.appendChild(group_button2_text);
        group_button2.value = 4;

       
        var sep = document.createElement("br");

      
        list_el.appendChild(list_el_span);
        list_el.appendChild(sep);
        list_el.appendChild(group_button2);
        list_el.appendChild(group_button1);

        container.appendChild(list_el);

    }
   
}

function operazione_gruppo_utente(){

    if(chat_selezionata == 0 || chat_privata == 1) return;// nessuna chat è selezionata , oppure è una chat privata

    var uri = "esegui_operazione_gruppo.php?user="+this.name+"&op="+this.value;

    fetch(uri)
    .then(location.reload());
}

function start_chat(){
    var uri = "start_private_chat.php?utente="+this.id;
    // prendo dal database le informazioni sui file 
    fetch(uri)
    .then(response => response.json())
    .then(text => 
        {
            current_chat_loader();
            location.reload();
        });

}

function current_logged_user_loader(){
    const uri = "get_current_logged_user_name.php";

    fetch(uri)
    .then(response => response.json())
    .then(text => write_logged_user_name(text));
}

function write_logged_user_name(name){
    document.getElementById("current_logged_display").textContent = name;
    current_user_name = name;
}

function update_file_list(){
    /*
    Questa funzione dopo ogni combiamento effettuato al campo input file_send
    (ovvero il campo dove si allega i file da inviare)
    aggiorna il testo dell'elemento span file list
    mettendo al posto del "Nessuno" , la lista dei nomi con estensione dei file inseriti
    con in fondo la dimensione delle dimensioni dei file espressa in Kb
    */
    

    var output = document.getElementById("file_list");
    const fileList = this.files;
    var children = "";
    var peso = 0;
    
    for(let i = 0; i < fileList.length ; i++){
        children += fileList[i].name;
        peso += fileList[i].size;
        if(i < fileList.length - 1) children += ' , ';
    }

  output.textContent = children + " ~ [" + (peso/(1024*1024)).toPrecision(4) + "] KB.";

}

function load_Chat(){
   

    if(this.id == 0) {
        chat_selezionata = 0; // se l'ID della chat selezionata non è valido esco dalla funzione
        return;
    }

    if(this.id == chat_selezionata) { // se la chat è gia stata selezionata
        return;
    }

    chat_selezionata = this.id;
    var visualizz = 0;

    var uri = "get_ID_Visualizzato_MAX.php?group="+chat_selezionata;

    fetch(uri)
    .then(response => response.json())
    .then(text =>  visualizz = text['mess_max']);

    sleep(90);

    var uri = "get_Chat.php?group="+chat_selezionata;

    fetch(uri)
    .then(response => response.json())
    .then(text => write_chat(text , visualizz));

    sleep(90);

    uri = "get_current_chat_name.php?group="+chat_selezionata;

    fetch(uri)
    .then(response => response.json())
    .then(text => write_chat_name(text));
  
}

function write_chat(json_chat , vis){
    // data la chat in formato JSON , questa funzione la stampa nell interfaccia
   
  chat_box = document.getElementById("chat_monitor");

  clear_chat_box();

  if(json_chat == null || chat_selezionata < 1) return;

  for(var i in json_chat)
  {
    const mess_body = document.createElement('p');
    let tipo_mess = json_chat[i]['tipo_mess'] ;
    var mess_txt = "";
  
    if(tipo_mess == 0){
        mess_txt  = document.createTextNode("["+ json_chat[i]['times']+"] "+json_chat[i]['Mitt']+": " + json_chat[i]['msg']);
        mess_body.className = "messaggio_chat";

        var visualizzato_dot = document.createElement("span");
        visualizzato_dot.className = "visualizzato_dot";
        var visualizzato_dot_text = document.createTextNode(".");

     

        if(parseInt(json_chat[i]['ID_mess']) <= vis){ // controllo per il visualizzato          
            visualizzato_dot.style.color = 'rgb(47, 137, 255)';
            visualizzato_dot.style.backgroundColor = 'rgb(47, 137, 255)';
        }else{ 
            visualizzato_dot.style.color = 'rgb(31, 168, 43)';
            visualizzato_dot.style.backgroundColor = 'rgb(31, 168, 43)';
        }

        visualizzato_dot.appendChild(visualizzato_dot_text);

        mess_body.appendChild(visualizzato_dot); 
        mess_body.appendChild(mess_txt);
              

    }else{
        let mess_testo = '';

        if(json_chat[i]['msg'] == 1){
            mess_testo = (json_chat[i]['Mitt']) + " è stato aggiunto!";
        }
        if(json_chat[i]['msg'] == 2){
            mess_testo = (json_chat[i]['Mitt']) + " è stato rimosso!";
        }
        if(json_chat[i]['msg'] == 3){
            mess_testo = "Il gruppo è stato rinominato!";
        }

        mess_txt  = document.createTextNode("["+ json_chat[i]['times']+"] " +  mess_testo);
        mess_body.className = "log_messaggio_chat";

        mess_body.appendChild(mess_txt);
       
    }
   
   
    if(tipo_mess == 0)  print_file_of(json_chat[i] , mess_body); // mando in stampa i file del messaggio appena stampato a schermo

    chat_box.appendChild(mess_body);

  }
 
}


function write_chat_name(text){

    if(text == null || chat_selezionata < 1) {  
        document.getElementById("current_contact_name").textContent  = "The Chat Place";
    }else{
        document.getElementById("current_contact_name").textContent  = text['info_g'];
    }
  
    update_interface_for_current_chat();
}

function update_interface_for_current_chat(){
    const uri = "get_current_chat_type.php";

    fetch(uri)
    .then(response => response.json())
    .then(text => {
        chat_privata = text['priv'];
        chat_selezionata = text['grup'];
        update_buttons();
    });

}

function update_buttons(){
    if(chat_selezionata < 1){
        document.getElementById("cancella_gruppo").disabled = 1;
        document.getElementById("rinomina_gruppo").disabled = 1;
        return;
    }
    if(chat_privata == 1){
        document.getElementById("cancella_gruppo").disabled = 1;
        document.getElementById("rinomina_gruppo").disabled = 1;
    }else{
        document.getElementById("cancella_gruppo").disabled = 0;
        document.getElementById("rinomina_gruppo").disabled = 0;
    }
}

function print_file_of(mess , message_element){
    var uri = "get_files_of_a_message.php?message="+(mess['ID_mess']);
    // prendo dal database le informazioni sui file 
    fetch(uri)
    .then(response => response.json())
    .then(text => print_files_of_the_message(text , message_element));
}

function print_files_of_the_message(files , message_element){
  
    if(files.lenght == 0) return; // se non ci sono file esco

   
    for(var f of files)  {
        var file_elemento = document.createElement('p');
        file_elemento.className = 'messaggio_file';

        var file_el = document.createElement('a'); 
        var file_download = document.createElement('a'); 
        const file_text_download_label = "Download";

        uri = "uploads/"+f['nome_mem'];
        file_el.setAttribute('href' , uri);

        file_text = document.createTextNode("- " + f['name']+" ~ " + (parseInt(f['size'])/1024).toPrecision(3) + "  Kb ");
       
        file_el.appendChild(file_text);
        file_el.className = 'mess_file_element_name';

        file_download.setAttribute('href' , uri);
        file_download.setAttribute('download' , f['name']);
        file_download.className = 'mess_file_element_download';
        file_download_text = document.createTextNode(" "+ file_text_download_label);
        file_download.appendChild(file_download_text);

       
        file_elemento.appendChild(file_el);
        file_elemento.appendChild(file_download);

        message_element.appendChild(file_elemento);
  }
 
}

function clear_chat_box(){
    const nodo = document.getElementById("chat_monitor");
    while(nodo.firstChild){
        nodo.removeChild(nodo.lastChild);
    }
}

function clear_suggested_contact_box(){
    const nodo = document.getElementById("suggested_contact_list_container");
    while(nodo.firstChild){
        nodo.removeChild(nodo.lastChild);
    }
}

function current_chat_loader(){
    var uri = "get_current_group_chat.php";

    fetch(uri)
    .then(response => response.json())
    .then(text => load_CURRENT_Chat(text));
}

function load_CURRENT_Chat(chat){

    if(chat == 0) return;
    chat_selezionata = chat;
   
        var visualizz = 0;

        var uri = "get_ID_Visualizzato_MAX.php?group="+chat_selezionata;

        fetch(uri)
        .then(response => response.json())
        .then(text => visualizz = text['mess_max']);

        sleep(60); 

        var uri = "get_current_chat_name.php?group="+chat_selezionata;

        fetch(uri)
        .then(response => response.json())
        .then(text => write_chat_name(text));
    
        sleep(60);

        var uri = "get_Chat.php?group="+chat_selezionata;

        fetch(uri)
        .then(response => response.json())
        .then(text => write_chat(text , visualizz));

      
    
}

function sleep(ms){
    // funzione che ferma il javascript per ms millisecondi
    const Data = Date.now();

    let Data_Corrente = null;

    do{
        Data_Corrente = Date.now();
    }while( Data_Corrente - Data < ms);
}
