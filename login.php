

<?php      

    session_start();

    $host = "localhost";
    $database = "chat";
    $user = "root";
    $pass = "";
    $conn = mysqli_connect($host , $user , $pass , $database);
    if( mysqli_connect_errno() ) die("Connessione a MySQL : FALLITA!"."<br>");

    $user_inserimento = $_POST["name"];
    $pass_inserimento = $_POST["psw"];

    if(strlen($user_inserimento) > 15){ // se il nome utente è troppo grande
        $user_inserimento = substr($user_inserimento , 0 , 15);
    }

    if(strlen($pass_inserimento) > 120){ // se la password è troppo grande
        $pass_inserimento = substr($pass_inserimento , 0 , 120);
    }
   
    $user_inserimento = $conn->real_escape_string($user_inserimento); // evito SQL Injection

    
    $pass_inserimento_MD5 = password_hash($pass_inserimento , PASSWORD_BCRYPT);

    if(isset($_POST['Register'])){  // se ha premuto il pulsante di registrazione

           
           $sql =  "INSERT INTO utente VALUES ('$user_inserimento' , '$pass_inserimento_MD5' , CURRENT_TIMESTAMP , 0)";
         
            $stat = mysqli_query($conn , $sql);

            if($stat === true){
                header("Location: chat_place.php");

                $_SESSION['logged'] = true;
                $_SESSION['theme'] = 0;
                $_SESSION['username'] = $user_inserimento;             
            }
            else{
                printf("Registrazione Fallita!" . "<br>");
                header("Location: index.php");
            }

           
    }
    if(isset($_POST['Login'])){ // se ha premuto il pulsante di login
        $sql =  "SELECT psw , tema FROM utente WHERE username = '$user_inserimento'";
        $stat = mysqli_query($conn , $sql);
        $row = mysqli_fetch_assoc($stat);

      if(password_verify($pass_inserimento , $row['psw'])){
            $_SESSION['logged'] = true;
            $_SESSION['theme'] = $row['tema'];
            $_SESSION['username'] = $user_inserimento;

            
            header("Location: chat_place.php");
         
       }else{
           echo("LOGIN FALLITO : Password Errata!" . "<br>");
           header("Location: index.php");
    }  
      
}

    mysqli_close($conn); // chiudo la connessione con il Database
    exit();
?>