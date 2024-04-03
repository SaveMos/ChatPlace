<?php
    session_start();

    $host = "localhost";
    $database = "chat";
    $user = "root";
    $pass = "";
    $conn = mysqli_connect($host , $user , $pass , $database);
    if(mysqli_connect_errno()) die("Connessione a MySQL : FALLITA!"."<br>"); 

    $id_gruppo = $_REQUEST['group'];
    $id_current_user =  $_SESSION['username'];


    $result = mysqli_query($conn , "CALL Get_Info_gruppo('$id_gruppo' , '$id_current_user');"); 

    $row = mysqli_fetch_assoc($result);
    $result = json_encode($row);

    echo $result;
    mysqli_close($conn);
    
?>