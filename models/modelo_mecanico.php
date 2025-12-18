<?php
class modelo_Mecanico
{
    private $conexion;

    function __construct()
    {
        require_once 'modelo_conexion.php';
        $this->conexion = new conexion();
        $this->conexion->conectar();

    }
    public function cerrarConexion()
    {
        $this->conexion->cerrar();
    }

    public function listar_mecanico()
    {
        $sql = "CALL SP_LISTAR_MECANICO()";
        $stmt = $this->conexion->conexion->prepare($sql);
        if ($stmt === false) {
            return [];
        }
        $arreglo = array();
        if ($stmt->execute()) {
            $resultado = $stmt->get_result();
            while ($datos = $resultado->fetch_assoc()) {
                $arreglo[] = $datos;
            }
        }
        $stmt->close();
        return $arreglo;
    }

    public function registrar_mecanico($usuario, $contra, $estado, $nombre, $apellido, $rut, $email, $telefono, $sexo, $rol, $especialidad, $taller)
    {
        $sql = "CALL SP_REGISTRAR_MECANICO(?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)";
        $stmt=$this->conexion->conexion->prepare($sql);
        if ($stmt === false) {
            return 0;
        }
        $contrahash = password_hash($contra, PASSWORD_DEFAULT, ['cost' => 10]);
        $stmt->bind_param("ssisssssiisi",$usuario,$contrahash,$estado,$nombre,$apellido,$rut,$email,$telefono,$sexo,$rol,$especialidad,$taller);

        $stmt->execute();
        $resultado = $stmt->get_result();
        if ($fila = $resultado->fetch_assoc()) {
            $stmt->close();
            return (int)$fila['resultado'];
        }
        $stmt->close();
        return 0;
    }


    public function modificar_estado($id_usuario, $estado)
    {
        $estado_int = 0;
        if ($estado == 'ACTIVO') {
            $estado_int = 1;
        }
        $sql = 'CALL SP_MODIFICAR_ESTADO(?, ?)';
        $stmt = $this->conexion->conexion->prepare($sql);
        if ($stmt === false) {
            return 0;
        }

        $stmt->bind_param('ii', $id_usuario, $estado_int);

        if ($stmt->execute()) {
            $stmt->close();
            return 1;
        } else {
            $stmt->close();
            return 0;
        }
    }

    public function listar_combo_mecanico()
    {
        $sql = "CALL SP_LISTAR_COMBO_MECANICO()";
        $stmt = $this->conexion->conexion->prepare($sql);
        if ($stmt === false) {
            return [];
        }
        $arreglo = array();
        if ($stmt->execute()) {
            $resultado = $stmt->get_result();
            while($datos = $resultado->fetch_assoc()) {
                $arreglo[] = $datos;
            }
        }
        $stmt->close();
        return $arreglo;

    }
}

?>