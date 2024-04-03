<?php
session_start();

if(isset($_SESSION['theme']))  echo json_encode($_SESSION['theme']);
else echo json_encode(0);

?>