

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
        
    $result = mysqli_query($conn , "CALL ID_Visualizzato_MAX('$id_gruppo' ,'$id_current_user');");  
    $row = mysqli_fetch_assoc($result);

    echo json_encode($row);

    
    mysqli_close($conn);


?>