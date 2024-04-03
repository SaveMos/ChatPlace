
<?php
session_start();
if(isset($_SESSION['current_group_chat']))  echo json_encode($_SESSION['current_group_chat']);
else echo json_encode(0);

?>