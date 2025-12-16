var tablemec;
function listar_mecanico(){
    tablemec=$("#tabla_m").DataTable({
        "ordering":false,
        "bLengthChange":false,
        "searching": { "regex": false },
        "lengthMenu": [ [10, 25, 50, 100, -1], [10, 25, 50, 100, "All"] ],
        "pageLength": 10,
        "destroy":true,
        "processing": true, // Es "processing", no "proccesing"
        "ajax":{
            "url":"../controllers/mecanico/controlador_mecanico_listar.php",
            type:'POST'
        },
        "order":[[1,'asc']],
        "columns":[
            {"data":null},
            {"data":"rut"},
            {"data":"nombre_usuario"},
            {"data":"nombre_completo"},
            {"data":"especialidad"},
            {
                "data":"estado",
                render: function (data, type, row){
                    if(data=='1'){
                        return "<span class='label label-success'>ACTIVO</span>";
                    }else{
                        return "<span class='label label-danger'>INACTIVO</span>";
                    }
                    
                }
            },
            {"defaultContent":"",
                render: function (data, type, row){
                    let status_button; // La variable a evaluar es row.estado
                    if(row.estado=='1'){
                        status_button="<button style='font-size:13px;' type='button' class='status btn btn-danger'><i class='fa fa-times'></i></button>";
                    }else{
                        status_button="<button style='font-size:13px;' type='button' class='status btn btn-success'><i class='fa fa-check'></i></button>";
                    }
                    return "<button style='font-size:13px;' type='button' class='editar btn btn-primary'><i class='fa fa-edit'></i></button>&nbsp;" + status_button;
                }
            }
        ],
        "language":idioma_espanol,
        select: true
    });

    // Usamos jQuery para ocultar el filtro, es más seguro y consistente.
    // El ID correcto es "#tabla_m_filter"
    $("#tabla_m_filter").hide();
    $('input.global_filter').on( 'keyup click', function () {
        filterGlobal();
    } );
    $('input.column_filter').on( 'keyup click', function () {
        filterColumn( $(this).parents('tr').attr('data-column') );
    });
    // La variable de la tabla es tablemec, no table
    tablemec.on('draw.dt', function () {
        var PageInfo = $('#tabla_m').DataTable().page.info();
        tablemec.column(0, { page: 'current' }).nodes().each(function (cell, i) {
            cell.innerHTML = i + 1 + PageInfo.start;
        });
    });
}
    function filterGlobal() {
        $('#tabla_m').DataTable().search(
            $('#global_filter').val(),
        ).draw();
    }
    
    function AbrirModalRegistro(){
        $("#modal_registro").modal({backdrop:'static',keyboard:false})
        $("#modal_registro").modal('show');
        $("#txt_usu").val("");
        $("#txt_rut").val("");
    }
    
function listar_combo_taller(){
    $.ajax({
        url: "../controllers/taller/controlador_listar_taller.php",
        type: 'POST',
        dataType: 'json'
    }).done(function (resp) {
        var cadena = "";
        if(resp && resp.length > 0){
            for (var i = 0; i < resp.length; i++){
                cadena += "<option value='" + resp[i].id_taller + "'>" + resp[i].nombre_taller + "</option>";
            }
            $("#cmb_taller").html(cadena);
            $("#cbm_taller_editar").html(cadena);
        }else{
            cadena+="<option value=''>NO SE ENCONTRARON REGISTROS</option>";
            $("#cmb_taller").html(cadena);
            $("#cbm_taller_editar").html(cadena);
        }
    }).fail(function(jqXHR, textStatus, errorThrown){
        console.error("Error al cargar talleres: ", textStatus, errorThrown, jqXHR.responseText);
    })
}
