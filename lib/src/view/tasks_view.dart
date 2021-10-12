import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:practica3_tareas/src/database/database_tasks.dart';
import 'package:practica3_tareas/src/model/tasks_model.dart';

class TasksView extends StatefulWidget {
  TasksModel? task;
  TasksView({Key? key, this.task}) : super(key: key);

  @override
  _TasksViewState createState() => _TasksViewState();
}

class _TasksViewState extends State<TasksView> {

  late DatabaseTasks _databaseTasks;

  TextEditingController _controllerNombre = TextEditingController();
  TextEditingController _controllerDescripcion = TextEditingController();
  DateTime? fecha;
  bool entregadasn=false;

  @override
  void initState() {
    // TODO: implement initState
    
    if ( widget.task != null ) {
      _controllerNombre.text = widget.task!.nomTarea!;
      _controllerDescripcion.text = widget.task!.dscTarea!;
      fecha = DateTime.parse(widget.task!.fechaEntrega!);
      widget.task!.entregada == 0 ? entregadasn=false : entregadasn = true;
    }

    _databaseTasks = DatabaseTasks();
  }

  @override
  Widget build(BuildContext context) {
    var formato = DateFormat('dd-MMM-yyyy');
    var formatosave = DateFormat('yyyy-MM-dd');
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.amber,
        title: widget.task == null ? Text('Agregar Tarea') : Text('Visualizar Tarea'),
      ),
      body: ListView(
        padding: EdgeInsets.all(10),
        children: [
          SizedBox(height: 10,),
          _crearTextFieldNombre(),
          SizedBox(height: 10,),
          _crearTextFieldDescripcion(),
          SizedBox(height: 10,),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text('Fecha de entrega: ', style: TextStyle(fontSize: 18),),
              Text(fecha==null ? formato.format(DateTime.now()) : formato.format(fecha!), style: TextStyle(fontSize: 18),),
              IconButton(
                onPressed: (){
                  showDatePicker(
                    context: context,
                    initialDate: fecha==null ? DateTime.now() : fecha!,
                    firstDate: DateTime(2007),
                    lastDate: DateTime(2099)
                  ).then(
                    (date){
                      setState(() {
                        fecha=date;
                      });
                    }
                  );
                },
                icon: Icon(Icons.calendar_today)
              ),
            ],
          ),
          widget.task != null ? Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text('Entregar Tarea', style: TextStyle(fontSize: 18),),
              Checkbox(
                value: entregadasn,
                onChanged: (bool? value){
                  //print('xd');
                  showDialog(
                    context: context,
                    builder: (context){
                      return AlertDialog(
                        title: entregadasn ? Text('Confirmación para desmarcar') : Text('Confirmación de entrega'),
                        content: entregadasn ? Text('¿Quieres quitar tu tarea entregada?') : Text('¿Estas seguro que quieres marcar tu tarea como entregada?'),
                        actions: [
                          TextButton(
                            onPressed: (){
                              Navigator.pop(context);
                              setState(() {
                                entregadasn = value!;
                              });
                            }, 
                            child: Text('Si')
                          ),
                          TextButton(
                            onPressed: (){
                              Navigator.pop(context);
                            },
                            child: Text('Cancelar')
                          )
                        ],
                      );
                    }
                  );
                } ,
              ),
            ],
          ) : Text(''),
          ElevatedButton(
            onPressed: (){
              if (_controllerNombre.text==''||_controllerDescripcion.text=='') {
                showDialog(
                  context: context,
                  builder: (BuildContext context) => AlertDialog(
                    title: Text('Error'),
                    content: Text(
                      'Porfavor llene todos los campos.',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.pop(context),
                        child: const Text('Ok',style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),),
                      )
                    ],
                  )
                );
              }else{
                if (widget.task == null) {
                  TasksModel task = TasksModel(
                    nomTarea: _controllerNombre.text,
                    dscTarea: _controllerDescripcion.text,
                    fechaEntrega: fecha==null ? formatosave.format(DateTime.now()) : formatosave.format(fecha!),
                    entregada: 0
                  );
                  _databaseTasks.insert(task.toMap()).then(
                    (value){
                      if (value>0) {
                        Navigator.pop(context);
                      }else{
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('La solicitud no se completo'))
                        );
                      }
                    }
                  );
                }else{
                  TasksModel task = TasksModel(
                    idTarea: widget.task!.idTarea,
                    nomTarea: _controllerNombre.text,
                    dscTarea: _controllerDescripcion.text,
                    fechaEntrega: formatosave.format(fecha!),
                    entregada: entregadasn ? 1 : 0
                  );
                  _databaseTasks.update(task.toMap()).then(
                    (value){
                      if (value > 0) {
                        Navigator.pop(context);
                      }else{
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('La solicitud no se completo'))
                        );
                      }
                    }
                  );
                }
              }
            },
            child: Text('Guardar Tarea'),
          )
        ],
      ),
    );
  }

  Widget _crearTextFieldNombre(){
    return TextField(
      controller: _controllerNombre,
      keyboardType: TextInputType.text,
      decoration: InputDecoration(
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10)
        ),
        labelText: "Titulo de la tarea",
      ),
      onChanged: (value){

      },
    );
  }

  Widget _crearTextFieldDescripcion(){
    return TextField(
      controller: _controllerDescripcion,
      keyboardType: TextInputType.text,
      maxLines: 8,
      decoration: InputDecoration(
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10)
        ),
        labelText: "Descripcion de la tarea",
      ),
      onChanged: (value){

      },
    );
  }
}