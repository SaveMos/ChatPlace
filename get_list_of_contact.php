<?php
    session_start();
    $host = "localhost";
    $database = "chat";
    $user = "root";
    $pass = "";
    $conn = mysqli_connect($host , $user , $pass , $database);
    if(mysqli_connect_errno()) die("Connessione a MySQL : FALLITA!"."<br>"); 

    $tip = TRIM($_REQUEST['tip']);
    $tip = mysqli_real_escape_string($conn , $tip);
    
    $id_current_user =  $_SESSION['username'];

    $sql = 
    "SELECT u.username as name_suggest
    FROM utente u
    WHERE 
    u.username LIKE '$tip%'
    AND u.username <> '$id_current_user'
    ORDER BY u.username ASC
    ";

    $result = mysqli_query($conn , $sql); 
    
    $arr = array();

    while($row = mysqli_fetch_assoc($result)) $arr[] = $row;

    $result = json_encode($arr);  

    mysqli_close($conn);

    echo $result;


?>