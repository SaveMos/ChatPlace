<?php
    session_start();

    $host = "localhost";
    $database = "chat";
    $user = "root";
    $pass = "";
    $conn = mysqli_connect($host , $user , $pass , $database);
    if(mysqli_connect_errno()) die("Connessione a MySQL : FALLITA!"."<br>"); 


    $id_gruppo    = $_SESSION['current_group_chat'];
    $id_mittente  = $_SESSION['username'];

    $message_text = TRIM($_REQUEST['msg_text']);
    $message_text = mysqli_real_escape_string($conn , $message_text);


   if($message_text != '') { 
        $result = mysqli_query($conn ,"CALL Invia_Messaggio('$id_mittente' , '$id_gruppo' , '$message_text');");
   }
    
   $sql =     
   "SELECT (MAX(m.ID_Messaggio)) as id_mess
   FROM messaggio m
   WHERE m.ID_Gruppo = '$id_gruppo'";  
   $result = mysqli_query($conn , $sql);  
   $row = mysqli_fetch_assoc($result);
   $_SESSION['message_id_dump']  = $row['id_mess']; // servirà per l'upload dei file associati a questo messaggio

    mysqli_close($conn);

    $arr = array(
        "Mitt" => $id_mittente , 
        "msg"  => $message_text , 
        "times" => date("Y-d-m H:i:s" , time())
    );

    echo json_encode($arr);

?>