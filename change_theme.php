<?php

    session_start();

    $host = "localhost";
    $database = "chat";
    $user = "root";
    $pass = "";
    $conn = mysqli_connect($host , $user , $pass , $database);
    if( mysqli_connect_errno() ) die("Connessione a MySQL : FALLITA!"."<br>");

    $id_current_user =  $_SESSION['username'];
    $tema_voluto = !$_SESSION['theme'];

    $result = mysqli_query($conn , "CALL Cambia_Tema('$id_current_user' , ' $tema_voluto');"); 

    $_SESSION['theme'] = $tema_voluto;

    if($tema_voluto) echo json_encode("1");
    else echo json_encode("0");
  
?>