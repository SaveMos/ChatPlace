<?php
    session_start();

    $host = "localhost";
    $database = "chat";
    $user = "root";
    $pass = "";
    $conn = mysqli_connect($host , $user , $pass , $database);
    if(mysqli_connect_errno()) die("Connessione a MySQL : FALLITA!"."<br>"); 

    if(!isset($_SESSION['current_group_chat'])){
        $a =array('priv' => -1 , 'grup' => 0);
        echo json_encode($a);
    }else{
        $gr = $_SESSION['current_group_chat'];

        $sql = 
        "SELECT 
        g.private_chat as priv , 
        g.ID_Gruppo as grup
        FROM gruppo g
        WHERE g.ID_Gruppo = '$gr'";

        $result = mysqli_query($conn , $sql);
        $row = mysqli_fetch_assoc($result);
        
        mysqli_close($conn);

        if($row == null){
            $a =array('priv' => -1 , 'grup' => 0);
            echo json_encode($a);
        }else{
            echo json_encode($row);
    }
}
    

?>