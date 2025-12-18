function VerificarUsuario() {
    var usuario = $("#txt_usuario").val();
    var contra = $("#txt_contra").val();
    
    if (usuario.length == 0 || contra.length == 0) {
        return Swal.fire("Mensaje de Advertencia", "Los campos no pueden estar vacíos.", "warning");
    }
    $.ajax({
        url: '../controllers/usuario/controlador_verificar_usuario.php',
        type: 'POST',
        data: {
            usu: usuario,
            con: contra
        },
        dataType: 'json' // Es importante indicar que esperas un JSON de vuelta.
    }).done(function(data) {
        if (data && data.status) {
            switch (data.status) {
                case 'OK':
                    // El backend (PHP) se encarga de crear la sesión.
                    // Aquí solo mostramos un mensaje de éxito y recargamos la página.
                    Swal.fire({
                        icon: 'success',
                        title: '¡Bienvenido!',
                        text: 'Inicio de sesión correcto.',
                        timer: 1500,
                        showConfirmButton: false
                    }).then(() => {
                        location.reload();
                    });
                    break;
                // El código AJAX que estaba aquí era inalcanzable y probablemente innecesario.
                case 'BLOCKED':
                    Swal.fire(
                        'Acceso Denegado',
                        'El usuario se encuentra bloqueado. Por favor, contacte al administrador.',
                        'warning'
                    );
                    break;
                default: // Asumimos que cualquier otro caso es un error de usuario/contraseña
                    Swal.fire('Error de Autenticación', 'Usuario y/o contraseña incorrectos.', 'error');
                    break;
            }
        } else {
            Swal.fire('Error de Respuesta', 'No se recibió una respuesta válida del servidor.', 'error');
        }
    }).fail(function() {
        // Manejo de errores en la comunicación con el servidor
        Swal.fire('Error de Conexión', 'No se pudo establecer comunicación con el servidor.', 'error');
    });  
}

function TraerDatosUsuario() {
    var usuario = $("#usuarioprincipal").val(); 
    $.ajax({
        url: '../controllers/usuario/controlador_traerdatos_usuario.php',
        type: 'POST',
        data: {
            usu: usuario
        },
        dataType: 'json' // Añadido para que jQuery parsee la respuesta automáticamente
    }).done(function(data) {
        if (data && Object.keys(data).length > 0) {
            $("#txtcontra_bd").val(data.clave);
            if (data.sexo === "M") { // Usamos 'M' para Masculino
                $("#img_nav").attr("src", "../Plantilla/dist/img/avatar5.png");
                $("#img_subnav").attr("src", "../Plantilla/dist/img/avatar5.png");
                $("#img_lateral").attr("src", "../Plantilla/dist/img/avatar5.png");
            } else { // Por defecto o si es 'M', usamos la imagen masculina
                $("#img_nav").attr("src", "../Plantilla/dist/img/avatar3.png");
                $("#img_subnav").attr("src", "../Plantilla/dist/img/avatar3.png");
                $("#img_lateral").attr("src", "../Plantilla/dist/img/avatar3.png");
            }
        }
    });
}

var table;
function listar_usuario(){
     table = $("#tabla_usuario").DataTable({
       "ordering":false,   
       "bLengthChange":false,
       "searching": { "regex": false },
       "lengthMenu": [ [10, 25, 50, 100, -1], [10, 25, 50, 100, "All"] ],
       "pageLength": 10,
       "destroy":true,
       "processing": true,
       "ajax":{
           "url":"../controllers/usuario/controlador_usuario_listar.php",
           type:'POST'
       },
       "order":[[1,'asc']],
       "columns":[
           {"data":null}, // Columna para el contador #
           {"data":"rut"},
           {"data":"nombre_usuario"},
           {"data":"nombre_completo"},
           {"data":"rol_nombre"},
           {
             "data":"estado",
             render: function (data, type, row ) { // El estado ya funciona con 1 y 0 (TINYINT)
               if(data=='1'){
                   return "<span class='label label-success'>ACTIVO</span>";
               }else{
                 return "<span class='label label-danger'>INACTIVO</span>";
               }
             }
           },

           {"defaultContent": "",
            render: function (data, type, row ) {
                let status_button;
                    if (row.estado == '1') {
                        // El usuario está activo, mostrar el botón de desactivar (cruz roja)
                        status_button = "<button style='font-size:13px;' type='button' class='status btn btn-danger'><i class='fa fa-times'></i></button>";
                    } else {
                        // El usuario está inactivo, mostrar el botón de activar (verificación verde)
                        status_button = "<button style='font-size:13px;' type='button' class='status btn btn-success'><i class='fa fa-check'></i></button>";
                    }
                    return "<button style='font-size:13px;' type='button' class='editar btn btn-primary'><i class='fa fa-edit'></i></button>&nbsp;" + status_button;
            }
           }
       ],

       "language":idioma_espanol,
       select: true
   });

      document.getElementById("tabla_usuario_filter").style.display="none";
   // Usamos jQuery para ocultar el filtro.
   // Esto es más seguro porque no dará error si el elemento no existe.
   // DataTables crea este elemento, así que lo buscamos por su ID generado.
   $("#tabla_usuario_filter").hide();

   $('input.global_filter').on( 'keyup click', function () {
        filterGlobal();
    } );
    $('input.column_filter').on( 'keyup click', function () {
        filterColumn( $(this).parents('tr').attr('data-column') );
    });

   table.on('draw.dt', function () {
        var PageInfo = $('#tabla_usuario').DataTable().page.info();
        table.column(0, { page: 'current' }).nodes().each( function (cell, i) {
                cell.innerHTML = i + 1 + PageInfo.start;
            } );
        } );


}


function filterGlobal() {
    $('#tabla_usuario').DataTable().search(
        $('#global_filter').val(),
    ).draw();
}

function AbrirModalRegistro(){
    $("#modal_registro").modal({backdrop:'static',keyboard:false})
    $("#modal_registro").modal('show');
    $("#txt_usu").val("");
    $("#txt_rut").val(""); // Limpia el campo RUT
    $("#txt_email").val(""); // Limpia el campo email
    $("#txt_nombre").val(""); // Limpia el campo nombre
    $("#txt_apellido").val(""); // Limpia el campo apellido
    $("#txt_telefono").val(""); // Limpia el campo teléfono
    $("#txt_con1").val(""); // Limpia el campo contraseña
    $("#txt_con2").val(""); // Limpia el campo de repetir contraseña
    // Resetea los estilos de validación que pudieran haber quedado
    $("#txt_email").css("border", "");
    $("#emailOK").html("&nbsp;").css("color", "transparent");
}

function agregar_usuario() {
    // 1. Recolectar los datos del formulario del modal de registro.
    // Asumimos que los IDs de los campos son los siguientes:
    var usuario = $("#txt_usu").val();
    var contra = $("#txt_con1").val();
    var contra2 = $("#txt_con2").val();
    var nombre = $("#txt_nombre").val();
    var apellido = $("#txt_apellido").val();
    var rut = $("#txt_rut").val();
    var email = $("#txt_email").val();
    var telefono = $("#txt_telefono").val();
    var sexo = $("#cbm_sexo").val();
    var rol = $("#cbm_rol").val();
    var estado = '1'; // Por defecto, los nuevos usuarios se registran como 'ACTIVO'

    // 2. Validar los datos
    if (usuario.length == 0 || contra.length == 0 || contra2.length == 0 || nombre.length == 0 || apellido.length == 0 || rut.length == 0 || email.length == 0 || telefono.length == 0 || sexo.length == 0 || rol.length == 0) {
        return Swal.fire("Mensaje de Advertencia", "Por favor, complete todos los campos.", "warning");
    }

    if (contra !== contra2) {
        return Swal.fire("Mensaje de Advertencia", "Las contraseñas no coinciden.", "warning");
    }

    // 3. Realizar la llamada AJAX al controlador
    $.ajax({
        url: '../controllers/usuario/controlador_registrar_usuario.php',
        type: 'POST',
        data: {
            usuario: usuario,
            contra: contra,
            estado: estado,
            nombre: nombre,
            apellido: apellido,
            rut: rut,
            email: email,
            telefono: telefono,
            sexo: sexo,
            rol: rol
        }
    }).done(function(resp) {
        // 4. Interpretar la respuesta del servidor
        if (resp > 0) {
            if (resp == 1) { // Éxito
                $("#modal_registro").modal('hide'); // Ocultar el modal
                Swal.fire("Mensaje de Confirmación", "Nuevo usuario registrado exitosamente.", "success")
                    .then((value) => {
                        table.ajax.reload(); // Recargar la tabla de usuarios
                    });
            } else { // Manejar duplicados
                let mensaje = resp == 2 ? "El nombre de usuario ya existe." : (resp == 3 ? "El RUT ya existe." : "El email ya existe.");
                Swal.fire("Mensaje de Advertencia", mensaje, "warning");
            }
        } else {
            Swal.fire("Mensaje de Error", "No se pudo completar el registro.", "error");
        }
    });
}

$('#tabla_usuario').on('click', '.status', function () {
    var data = table.row($(this).parents('tr')).data();
    if (table.row(this).child.isShown()) {
        data = table.row(this).data();
    }

    if (data.estado == '1') {
        // Lógica para desactivar
        Swal.fire({
            title: '¿Está seguro de que desea desactivar al usuario?',
            text: "Una vez hecho esto, el usuario no tendrá acceso al sistema.",
            icon: 'warning',
            showCancelButton: true,
            confirmButtonColor: '#3085d6',
            cancelButtonColor: '#d33',
            confirmButtonText: 'Sí, desactivar'
        }).then((result) => {
            if (result.value) {
                Modificar_Estatus_Usuario(data.id_usuario, 'INACTIVO');
            }
        });
    } else {
        // Lógica para activar
        Swal.fire({
            title: '¿Está seguro de que desea activar al usuario?',
            text: "Una vez hecho esto, el usuario tendrá acceso al sistema.",
            icon: 'warning',
            showCancelButton: true,
            confirmButtonColor: '#3085d6',
            cancelButtonColor: '#d33',
            confirmButtonText: 'Sí, activar'
        }).then((result) => {
            if (result.value) {
                Modificar_Estatus_Usuario(data.id_usuario, 'ACTIVO');
            }
        });
    }
});

$('#tabla_usuario').on('click','.editar',function(){
    var data = table.row($(this).parents('tr')).data();
    if(table.row(this).child.isShown()){
        var data = table.row(this).data();
    }

    // Hacemos una llamada AJAX para traer los datos completos del usuario
    $.ajax({
        url: '../controllers/usuario/controlador_traerdatos_usuario.php',
        type: 'POST',
        data: {
            usu: data.nombre_usuario // Usamos el nombre de usuario para buscar
        },
        dataType: 'json'
    }).done(function(fullData) {
        if (fullData && fullData.id_usuario) {
            $("#modal_editar").modal({backdrop:'static',keyboard:false});
            $("#modal_editar").modal('show');
            // Limpiamos campos de contraseña
            $("#txt_con1_editar").val("");
            $("#txt_con2_editar").val("");

            // Llenamos el modal con los datos completos
            $("#txtidusuario").val(fullData.id_usuario);
            $("#txtusu_editar").val(fullData.nombre_usuario);
            $("#txt_rut_editar").val(fullData.rut);
            $("#txt_nombre_editar").val(fullData.nombres);
            $("#txt_apellido_editar").val(fullData.apellidos);
            $("#txt_email_editar").val(fullData.email);
            $("#txt_telefono_editar").val(fullData.telefono);
            $("#cbm_sexo_editar").val(fullData.sexo).trigger("change");
        } else {
            Swal.fire("Error", "No se pudieron cargar los datos del usuario.", "error");
        }
    }).fail(function() {
        Swal.fire("Error de Conexión", "No se pudo comunicar con el servidor para obtener los datos.", "error");
    });
});

// Solución: Limpiar modales al cerrarse
// Se escucha el evento 'hidden.bs.modal' que se dispara cuando un modal se ha cerrado.
$(document).ready(function() {
    $('#modal_registro').on('hidden.bs.modal', function () {
        $(this).find('form')[0].reset(); // Resetea el formulario dentro del modal de registro
    });

    $('#modal_editar').on('hidden.bs.modal', function () {
        $(this).find('form')[0].reset(); // Resetea el formulario dentro del modal de edición
    });
});

function Modificar_Usuario() {
    var id = $("#txtidusuario").val();
    var nombres = $("#txt_nombre_editar").val();
    var apellidos = $("#txt_apellido_editar").val();
    var email = $("#txt_email_editar").val();
    var telefono = $("#txt_telefono_editar").val();
    var sexo = $("#cbm_sexo_editar").val();
    var contra = $("#txt_con1_editar").val();
    var contra2 = $("#txt_con2_editar").val();

    if (nombres.length == 0 || apellidos.length == 0 || email.length == 0 || telefono.length == 0) {
        return Swal.fire("Mensaje de Advertencia", "Por favor, complete los campos obligatorios.", "warning");
    }
    if (contra !== contra2) {
        return Swal.fire("Mensaje de Advertencia", "Las contraseñas no coinciden.", "warning");
    }
    if ($("#validar_email_editar").val() === "incorrecto") {
        return Swal.fire("Mensaje de Advertencia", "El formato del email es incorrecto.", "warning");
    }

    $.ajax({
        url: '../controllers/usuario/controlador_modificar_usuario.php',
        type: 'POST',
        data: {
            id: id,
            nombres: nombres,
            apellidos: apellidos,
            email: email,
            telefono: telefono,
            sexo: sexo,
            contra: contra // Se envía vacía si no se modifica
        }
    }).done(function(resp) {
        if (resp > 0) {
            if (resp == 1) { // Éxito
                $("#modal_editar").modal('hide');
                Swal.fire("Mensaje de Confirmación", "Datos del usuario actualizados correctamente.", "success")
                    .then((value) => {
                        table.ajax.reload(); // Recargar la tabla
                    });
            } else { // Email duplicado
                Swal.fire("Mensaje de Advertencia", "El email ingresado ya pertenece a otro usuario.", "warning");
            }
        } else {
            Swal.fire("Mensaje de Error", "No se pudo completar la actualización.", "error");
        }
    });
}

function listar_combo_rol() {
    $.ajax({
        url: "../controllers/usuario/controlador_cmb_rol.php",
        type: 'POST',
        dataType: 'json' // 1. Le decimos a jQuery que espere un JSON.
    }).done(function (resp) {
        // 2. jQuery ya convierte la respuesta a un objeto/array, no necesitamos JSON.parse().
        var cadena = "";
        if(resp && resp.length > 0)
            {
                for (var i = 0; i < resp.length; i++) {
                    cadena += "<option value='" + resp[i].id_rol + "'>" + resp[i].nombre_rol + "</option>";
                }
                $("#cbm_rol").html(cadena);
                $("#cbm_rol_editar").html(cadena);
            }else{
                cadena+="<option value=''>NO SE ENCONTRARON REGISTROS</option>";
                $("#cbm_rol").html(cadena);
                $("#cbm_rol_editar").html(cadena);

            }
    }).fail(function(jqXHR, textStatus, errorThrown) {
        // 3. Si algo sale mal, veremos un error claro en la consola.
        console.error("Error al cargar roles: ", textStatus, errorThrown, jqXHR.responseText);
    })
}

function Modificar_Estatus_Usuario(idusuario, estado) {
    var mensaje = "";
    if(estado == 'ACTIVO') {
        mensaje="activó";
    } else {
        mensaje="desactivó";
    }

    $.ajax({
        url:"../controllers/usuario/controlador_estado_usuario.php",
        type:'POST',
        data:{
            id_usuario: idusuario,
            estado: estado
        }
    }).done(function(resp){
        if (resp > 0) {
            Swal.fire("Mensaje de Confirmación", "El estado del usuario se "+ mensaje +" con éxito", "success")
            .then((value) => {
                table.ajax.reload();
            });
        } else {
            Swal.fire("Mensaje de Advertencia", "No se pudo cambiar el estado del usuario", "warning");
        }
    })
}
