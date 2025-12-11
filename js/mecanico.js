var tablemec;
function listar_mecanico(){
    tablemec=$("tabla_m").DataTable({
        "ordering":false,
        "bLengthChange":false,
        "searching": { "regex": false },
        "lengthMenu": [ [10, 25, 50, 100, -1], [10, 25, 50, 100, "All"] ],
        "pageLength": 10,
        "destroy":true,
        "processing": true,
        "ajax":{
            "url":"../controlers/mecanico/controlador_mecanico_listar.php",
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
                    let status_button;
                    if(status_button=='1'){
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

    document.getElementById("tabla_m_filter").style.display="none";
    $("tabla_m_filter").hide();
    $('input.global_filter').on( 'keyup click', function () {
        filterGlobal();
    } );
    $('input.column_filter').on( 'keyup click', function () {
        filterColumn( $(this).parents('tr').attr('data-column') );
    });

    table.on('draw.dt', function () {
        var PageInfo = $('#tabla_m').DataTable().page.info();
        table.column(0, { page: 'current' }).nodes().each(function (cell, i) {
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