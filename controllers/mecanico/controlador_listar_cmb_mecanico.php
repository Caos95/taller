<?php
require "../../models/modelo_mecanico.php";
$MM = new Modelo_Mecanico();
$consulta = $MM->listar_combo_mecanico();
echo json_encode($consulta);
?>  
