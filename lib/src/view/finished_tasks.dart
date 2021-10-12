import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:practica3_tareas/src/database/database_tasks.dart';
import 'package:practica3_tareas/src/model/tasks_model.dart';
import 'package:practica3_tareas/src/view/tasks_view.dart';

class FinishedTasks extends StatefulWidget {
  FinishedTasks({Key? key}) : super(key: key);

  @override
  _FinishedTasksState createState() => _FinishedTasksState();
}

class _FinishedTasksState extends State<FinishedTasks> {

  late DatabaseTasks _databaseTasks;

  @override
  void initState() {
    super.initState();
    _databaseTasks = DatabaseTasks();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.green,
        title: Text('Tareas Terminadas'),
      ),
      body: FutureBuilder(
        future: _databaseTasks.getAll(),
        builder: (BuildContext context, AsyncSnapshot<List<TasksModel>> snapshot){
          if (snapshot.hasError) {
            return Center(child: Text('Ocurrio un error en la peticion'),);
          }else{
            if (snapshot.connectionState==ConnectionState.done) {
              return _homeloka(snapshot.data!);
            }else{
              return Center(child: CircularProgressIndicator(),);
            }
          }
        }
      ),
    );
  }

  Widget _homeloka(List<TasksModel> tareas){
    var formatodisp = DateFormat('dd-MMM-yyyy');
    return RefreshIndicator(
      onRefresh: (){
        return Future.delayed(
          Duration(seconds: 1),
          (){setState((){});}
        );
      },
      child: ListView.builder(
        itemBuilder: (BuildContext context,index){
          TasksModel tarea = tareas[index];
          if (tarea.entregada==0) {
            return Card();
          }else{
          return Card(
            child: Container(
              padding: EdgeInsets.all(8),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      SizedBox(width: 10, height: 50,),
                      Flexible(
                        child: Text(
                          tarea.nomTarea!,
                          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 25),
                          overflow: TextOverflow.ellipsis,
                        )
                      ),
                    ],
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      SizedBox(width: 10, height: 10,),
                      Flexible(
                        child: Text(
                          tarea.dscTarea!,
                          style: TextStyle(fontSize: 20), 
                          overflow: TextOverflow.ellipsis,
                        )
                      ),
                    ],
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      SizedBox(width: 10, height: 30,),
                      Text('Entrega: ${formatodisp.format(DateTime.parse(tarea.fechaEntrega!))}',style: TextStyle(fontSize: 18)),
                    ],
                  ),
                  Container(
                    padding: EdgeInsets.only(right: 10),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        IconButton(
                          onPressed: (){
                            showDialog(
                              context: context,
                              builder: (context){
                                return AlertDialog(
                                  title: Text('Confirmación de borrado'),
                                  content: Text('¿Estas seguro?'),
                                  actions: [
                                    TextButton(
                                      onPressed: (){
                                        Navigator.pop(context);
                                        _databaseTasks.delete(tarea.idTarea!).then(
                                          (noRows){
                                            if (noRows>0) {
                                              ScaffoldMessenger.of(context).showSnackBar(
                                                SnackBar(content: Text('La tarea se ha eliminado'))
                                              );
                                              setState(() {});
                                            }
                                          }
                                        );
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
                          },
                          icon: Icon(Icons.delete_forever),
                          iconSize: 30,
                          color: Colors.red,
                        ),
                        ElevatedButton(
                          onPressed: (){
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => TasksView(task: tarea,)
                              )
                            ).then((_){setState((){});});
                          },
                          child: Row(
                            children: [
                              Icon(Icons.remove_red_eye),
                              Text(' Abrir Tarea')
                            ],
                          ),
                        ),
                      ],
                    ),
                  )
                ],
              ),
            ),
          );
          }
        },
        itemCount: tareas.length,
      ),
    );
  }
}