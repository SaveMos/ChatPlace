<?php

    // id del gruppo nell array $_GET
    session_start();
    $host = "localhost";
    $database = "chat";
    $user = "root";
    $pass = "";
    $conn = mysqli_connect($host , $user , $pass , $database);
    if(mysqli_connect_errno()) die("Connessione a MySQL : FALLITA!"."<br>"); 

    $id_gruppo = $_REQUEST['group'];
    $_SESSION['current_group_chat'] = $_REQUEST['group'];
    $id_current_user = $_SESSION['username'];
    

    $result = mysqli_query($conn , "CALL Open_Chat('$id_current_user' , '$id_gruppo');");  


    $sql = 
    "SELECT * FROM (
        (
            SELECT 
            m.ID_messaggio AS ID_mess , 
            m.Mittente AS Mitt , 
            m.testo_messaggio AS msg , 
            m.Timestamp_Invio AS times ,
            0 AS tipo_mess 
            FROM messaggio m
            INNER JOIN gruppo g ON g.ID_Gruppo = m.ID_Gruppo
            INNER JOIN user_gruppo ug ON ug.gruppo = g.ID_Gruppo
            WHERE g.ID_Gruppo = '$id_gruppo' AND 
            ug.ignora_da < m.ID_Messaggio AND
            ug.utente = '$id_current_user'   
        )
        UNION
        (
            SELECT
            CONCAT(lg.ID_evento , 'lg') as ID_mess ,
            lg.user AS Mitt ,
            lg.descrizione AS msg , 
            lg.data_evento AS times ,
            1 AS tipo_mess 
            FROM log_gruppo lg
            WHERE lg.ID_Gruppo = '$id_gruppo'
        )
        
        ) AS D
         ORDER BY times DESC;
    
    ";
    

    $result = mysqli_query($conn , $sql);  
    $arr = array();

    while($row = mysqli_fetch_assoc($result)) $arr[] = $row;
 
    $res =  json_encode($arr);  // chat in formato JSON

    echo $res;

    mysqli_close($conn);

    
    
?>