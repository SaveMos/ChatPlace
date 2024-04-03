<?php
    session_start();
    $host = "localhost";
    $database = "chat";
    $user = "root";
    $pass = "";
    $conn = mysqli_connect($host , $user , $pass , $database);
    if(mysqli_connect_errno()) die("Connessione a MySQL : FALLITA!"."<br>"); 

    // Cancella_Chat
    $id_gruppo = $_SESSION['current_group_chat'];
    $id_current_user =  $_SESSION['username'];
    
    $result = mysqli_query($conn , "CALL Cancella_Chat('$id_current_user' ,'$id_gruppo' )"); 

    echo json_encode(1);

?>