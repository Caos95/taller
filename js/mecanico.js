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
                        status_button="<button style='font-size:13px;' type='button' class='status btn btn-success'><i class='fa fa-check'>"
                    }
                }
            }
        ]
    })
}