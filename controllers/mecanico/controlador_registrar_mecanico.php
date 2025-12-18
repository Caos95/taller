<?php
    require '../../models/modelo_mecanico.php';
    
    $MM= new modelo_Mecanico();
    $usuario= htmlspecialchars($_POST['usuario'], ENT_QUOTES, 'UTF-8');
    $contra= htmlspecialchars($_POST['contra'], ENT_QUOTES, 'UTF-8');
    $estado= htmlspecialchars($_POST['estado'], ENT_QUOTES, 'UTF-8');
    $nombre= htmlspecialchars($_POST['nombre'], ENT_QUOTES, 'UTF-8');
    $apellido= htmlspecialchars($_POST['apellido'], ENT_QUOTES, 'UTF-8');
    $rut= htmlspecialchars($_POST['rut'], ENT_QUOTES, 'UTF-8');
    $email= htmlspecialchars($_POST['email'], ENT_QUOTES, 'UTF-8');
    $telefono= htmlspecialchars($_POST['telefono'], ENT_QUOTES, 'UTF-8');
    $sexo= htmlspecialchars($_POST['sexo'], ENT_QUOTES, 'UTF-8');
    $rol= htmlspecialchars($_POST['rol'], ENT_QUOTES, 'UTF-8');
    $especialidad= htmlspecialchars($_POST['especialidad'], ENT_QUOTES, 'UTF-8');
    $taller= htmlspecialchars($_POST['taller'], ENT_QUOTES, 'UTF-8');
    
    $consulta = $MM->registrar_mecanico($usuario, $contra, $estado, $nombre, $apellido, $rut, $email, $telefono, $sexo, $rol, $especialidad, $taller);
    echo $consulta;


    //datos tabla usuario
/*
    $usuario = htmlspecialchars($_POST['usuario'] ?? '', ENT_QUOTES, 'UTF-8');
    $contra = htmlspecialchars($_POST['contra'] ?? '', ENT_QUOTES, 'UTF-8');
    $sexo = htmlspecialchars($_POST['sexo'] ?? '', ENT_QUOTES, 'UTF-8');
    $rol = 4;

    //tabla mecanico

    $rut = htmlspecialchars($_POST['rut_mecanico'] ?? '', ENT_QUOTES, 'UTF-8');
    $nombre = htmlspecialchars($_POST['nombre_mecanico'] ?? '', ENT_QUOTES, 'UTF-8');
    $especialidad = htmlspecialchars($_POST['especialidad_mecanico'] ?? '', ENT_QUOTES, 'UTF-8');
    $telefono = htmlspecialchars($_POST['telefono_mecanico'] ?? '', ENT_QUOTES, 'UTF-8');
    $email = htmlspecialchars($_POST['email_mecanico'] ?? '', ENT_QUOTES, 'UTF-8');
    $taller = htmlspecialchars($_POST['taller_mecanico'] ?? '', ENT_QUOTES, 'UTF-8');

    if (empty($usuario) || empty($contra) || empty($sexo) || empty($rut) || empty($nombre) || empty($especialidad) || empty($telefono) || empty($email) || empty($taller)) {
        echo "Error: Todos los campos son obligatorios.";
        exit();
    }   

    $consulta = $MC->registrar_mecanico_completo($usuario, $contra, $sexo, $rol, $rut, $nombre, $especialidad, $telefono, $email, $taller);
    echo $consulta;
*/
?>