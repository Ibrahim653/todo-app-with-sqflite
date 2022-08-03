import 'package:conditional_builder_null_safety/conditional_builder_null_safety.dart';
import 'package:flutter/material.dart';
import 'package:todo_app/shared/cubit/cubit.dart';

Widget defaultFormField({
  required TextEditingController controller,
  required TextInputType keyboardType,
  required FormFieldValidator validate,
  void Function(String)? onChanged,
  void Function(String)? onSubmit,
  void Function()? onTap,
  required String label,
  required IconData prefix,
}) {
  return TextFormField(
    controller: controller,
    keyboardType: keyboardType,
    validator: validate,
    onFieldSubmitted: onSubmit,
    onChanged: onChanged,
    onTap: onTap,
    decoration: InputDecoration(
      labelText: label,
      prefixIcon: Icon(prefix),
      border:const OutlineInputBorder(),
    ),
  );
}

Widget buildTaskItem(Map model,context) {
  return Dismissible(
    onDismissed: (dismissible){
    AppCubit.get(context).deleteData(id: model['id']);
    },
    key:Key(model['id'].toString()) ,
    child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Row(
          children: [
            CircleAvatar(
              radius: 40,
              child: Text(model['time']),
            ),
            const   SizedBox(width: 20),
            Expanded(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    model['title'],
                    style:const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                    ),
                  ),
                  Text(
                    model['date'],
                    style:const TextStyle(color: Colors.grey),
                  ),
                ],
              ),
            ),
            const   SizedBox(width: 20),
            IconButton(
                onPressed: () {
                  AppCubit.get(context).updateData(status: 'Done', id: model['id']);
                },
                icon:const Icon(
                  Icons.check_box_outlined,
                  color: Colors.green,
                )),
            IconButton(
                onPressed: () {
                  AppCubit.get(context).updateData(status: 'Archived', id: model['id']);
                },
                icon:const Icon(
                  Icons.archive,
                  color: Colors.black54,
                )),
          ],
        ),
      ),
  );
}
Widget buildTasks({required List<Map> tasks}){
  return ConditionalBuilder(
    condition: tasks.isNotEmpty,
    builder: (context) =>
        ListView.separated(
          itemBuilder: (context, index) {
            return buildTaskItem(tasks[index], context);
          },
          itemCount: tasks.length,
          separatorBuilder: (context, index) {
            return Container(
              color: Colors.grey[300],
              width: double.infinity,
              height: 1,
            );
          },
        ),
    fallback: (context) =>
        Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.menu, color: Colors.grey, size: 100,),
              Text("No Tasks Yet, please add tasks",
                style: TextStyle(fontSize: MediaQuery.of(context).textScaleFactor*14),)
            ],
          ),
        ),
  );
}
