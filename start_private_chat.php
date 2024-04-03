<?php
    session_start();
    $host = "localhost";
    $database = "chat";
    $user = "root";
    $pass = "";
    $conn = mysqli_connect($host , $user , $pass , $database);
    if(mysqli_connect_errno()) die("Connessione a MySQL : FALLITA!"."<br>"); 

    $new_user = TRIM($_REQUEST['utente']);
    $new_user = mysqli_real_escape_string($conn , $new_user);
    
    $id_current_user = $_SESSION['username'];

    $result = mysqli_query($conn , "CALL Crea_Chat_Privata('$id_current_user' , '$new_user')"); 

    if($result) {
       if($result != 1 && $result != 0){
            $row = mysqli_fetch_assoc($result);
            $_SESSION['current_group_chat'] = $row['ID_G'];
       }
        echo json_encode(1);
    }else{
        $_SESSION['current_group_chat'] = 0;
        echo json_encode(0);
    }

    mysqli_close($conn);
    
?>