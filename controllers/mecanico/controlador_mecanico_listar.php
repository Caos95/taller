<?php
require "../../models/modelo_mecanico.php";
header('content-type:application/json');
$MM = new Modelo_Mecanico();
$consulta = $MM->listar_mecanico();

$data = $consulta ? $consulta : [];

$response = [
    "sEcho" => 1,
    "iTotalRecords" => count($data),
    "iTotalDisplayRecords" => count($data),
    "aaData" => $data
];

echo json_encode($response);

?>


