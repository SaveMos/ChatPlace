
<!DOCTYPE html>


<html lang="it">
  <head>
      <meta charset="utf-8">
      <meta name="viewport" content="width = device-width">
      <link rel="stylesheet"  href="chat_style.css">
      <script src="chat_place.js"></script> 
      <title>Chat Place</title>
  </head>

  <body onload = "EventHandler()">
    
        <div id="logged_user_console">
            <div id="logged_user_information_container">
                  <span id='current_logged_display'>Logged</span>
                  <br>

                  <form name="logout_form" id="logout_form" method="post" action="logout.php" enctype="multipart/form-data">
                        <label for='logout_button'>
                          <input id='logout_button' class='sub_button' type="submit" name='logout' value='LOGOUT'>
                        </label>   
                  </form>   
            </div>
              <div id="contact_searcher_container">
                  <input type='text' id="contact_searcher_input" placeholder="Inserisci un nome.">
                  <div id="suggested_contact_list_container"></div>
              </div>
        </div>
           
      <div id="contact_list" class ="main_div">
            <?php
                /*
                In questa sezione di codice viene caricata la lista di chat dell utente che ha 
                effettuato il login.
                */
                $host = "localhost";
                $database = "chat";
                $user = "root";
                $pass = "";
                $conn = mysqli_connect($host , $user , $pass , $database);
                if(mysqli_connect_errno()) die("Connessione a MySQL : FALLITA!"."<br>"); 

                session_start();

                if(!isset($_SESSION['username'])) header("Location: index.php"); 
          
                $nome_utente_loggato = $_SESSION['username'];
                /*
                In questa query vengono recuperati i nomi dei gruppi o dei contatti 
                con cui l'utente che ha appena effettuato il login ha una chat aperta

                in seguito vi è anche il codice php che dal risultato della query stampa la lista effettiva
                */ 

                $sql =                        
                  "SELECT ID_g , contatto , t 
                  FROM
                  ((       
                  SELECT g.ID_Gruppo as ID_g, g.Nome as contatto , g.ultima_attivita as t
                  FROM gruppo g
                  INNER JOIN user_gruppo ug ON ug.gruppo = g.ID_Gruppo
                  INNER JOIN utente u ON u.username = ug.utente
                  WHERE u.username = '$nome_utente_loggato' AND g.private_chat = 0
                  )
                  UNION
                  (
                  SELECT g.ID_Gruppo as ID_g, ug2.utente as contatto , g.ultima_attivita as t
                  FROM user_gruppo ug1
                  INNER JOIN gruppo g ON g.ID_Gruppo = ug1.gruppo
                  INNER JOIN user_gruppo ug2 ON (ug2.gruppo = g.ID_Gruppo AND ug1.utente <> ug2.utente)
                  WHERE g.private_chat = 1 AND ug1.utente = '$nome_utente_loggato'
                  )) as D
                  ORDER BY t DESC";

                $result = mysqli_query($conn , $sql);
                $id_group = 0;

                while($row = mysqli_fetch_assoc($result)) {
                      $id_group = $row['ID_g']; 
                      
                      if($_SESSION['theme']){
                        $class = 'contact_list_element_black';
                      }else{
                        $class = 'contact_list_element_white';
                      }

                      echo (  
                      "<div id='$id_group' class='$class'>".
                      "<p class ='contact_list_element_nome'>"    . $row['contatto'] ." "."</p>".
                   
                      "<p class ='contact_list_element_attivita'>"  . $row['t']  . "</p>". 
                      "</div>"
                      );                
                }

            ?>
      </div>

        <div id="current_chat_info_container">
           <span id="current_contact_name">The Chat Place</span>
           <div id="option_container">
              <input id="delete_chat"    name="delete_chat" class="upper_button" type="button" value="Cancella Chat">
              <input id="change_theme"   name="change_theme" class="upper_button" type="button" value="Cambia Tema"> 
             
              <br>
              <input id="crea_gruppo" name="crea_gruppo" class="upper_button" type="button" value="Nuovo Gr.">
              <input id="cancella_gruppo" name="cancella_gruppo" class="upper_button" type="button" value="Cancella Gr.">
              <input id="rinomina_gruppo"  name="rinomina_gruppo" class="upper_button" type="button" value="Rinomina Gr.">
        
            </div>
        </div>

        <div id="chat_monitor" class ="main_div"></div>

        <div id="message_box_container"> 
         
         <form method="post" id="message_form" name = "message_form" enctype="multipart/form-data" onkeydown ="return event.key != 'Enter'">

                <label for="message_box">
                    <input placeholder="Inserisci il tuo messaggio." name="msg_text" id="message_box" type="text" >
                </label>
                
                <label for="send_button">
                    <input id="send_button" name="file_send"  value="Invia" type="button">  
              </label>  
                
                <label id="file_selector_label" for="file_send"> File
                    <input id="file_send" multiple="" name="file_send[]" type="file" 
                    accept=".png , .jpg , .jpeg , .pdf , .txt , .mp3 , .mp4 , .exe ">
              </label>  
                    <span id="file_list_label">File : </span> 
                    <span id="file_list">Nessuno</span>      
         </form> 

        </div>

 

  </body>



</html>

