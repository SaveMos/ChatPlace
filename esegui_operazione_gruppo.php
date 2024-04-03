<?php

    session_start();

    $host = "localhost";
    $database = "chat";
    $user = "root";
    $pass = "";
    $conn = mysqli_connect($host , $user , $pass , $database);
    if(mysqli_connect_errno()) die("Connessione a MySQL : FALLITA!"."<br>"); 

 
    $id_mittente  = $_SESSION['username'];
    $operazione   = $_GET['op'];

    if($operazione == 1){
        $new_name = $_GET['nome_g'];
        $new_name = TRIM($new_name);
        $new_name = mysqli_real_escape_string($conn , $new_name);

        $sql = "CALL Crea_Gruppo('$id_mittente' , '$new_name');";
    }

    if($operazione == 2){
        $id_gruppo    = $_SESSION['current_group_chat'];
        $sql = "CALL Elimina_Gruppo('$id_gruppo' , '$id_mittente' );";
    }

    if($operazione == 3){
        $id_gruppo = $_SESSION['current_group_chat'];
        $new_name = $_GET['nome_g'];
        $new_name = TRIM($new_name);
        $new_name = mysqli_real_escape_string($conn , $new_name);

        $sql = "CALL Rinomina_Gruppo('$id_gruppo' , '$new_name', '$id_mittente' );";
    }

    if($operazione == 4){
        $id_gruppo = $_SESSION["current_group_chat"];
        $new_name  = $_GET['user'];
          
        $new_name = TRIM($new_name);
        $new_name = mysqli_real_escape_string($conn , $new_name);
      
        $sql = "CALL Aggiungi_Utente_al_Gruppo('$new_name' , '$id_gruppo');";

    }

    if($operazione == 5){    
        $id_gruppo   = $_SESSION['current_group_chat'];
        $new_name = $_GET['user'];
        $new_name = TRIM($new_name);
        $new_name = mysqli_real_escape_string($conn , $new_name);
      
        $sql = "CALL Elimina_Utente_dal_Gruppo('$new_name' , '$id_gruppo');";
        echo json_encode(5);
    }

    $result = mysqli_query($conn , $sql);  
    mysqli_close($conn);
   

   


?>