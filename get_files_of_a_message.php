<?php

    session_start();
    $host = "localhost";
    $database = "chat";
    $user = "root";
    $pass = "";
    $conn = mysqli_connect($host , $user , $pass , $database);
    if(mysqli_connect_errno()) die("Connessione a MySQL : FALLITA!"."<br>"); 

    $id_mess = $_REQUEST['message'];

    $sql = 
    "SELECT
    f.nome_memoria as nome_mem,
    f.nome_effettivo as name,
    f.estensione as est, 
    f.Dimensione as size
    FROM messaggio m
    INNER JOIN file f on f.ID_Messaggio = m.ID_Messaggio
    WHERE m.ID_Messaggio = '$id_mess';
    ";

    $result = mysqli_query($conn , $sql);  
    $arr = array();

    while($row = mysqli_fetch_assoc($result)) $arr[] = $row;

    $result = json_encode($arr);   // chat in formato JSON

    mysqli_close($conn);

    echo $result;

?>