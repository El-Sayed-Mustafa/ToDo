import 'package:flutter/material.dart';

Widget defaultFormField({
  required TextEditingController controller,
  required TextInputType type,
  Function? onSubmit,
  Function? onChange,
  Function? onTap,
  bool isPassword = false,
  required Function validate,
  required String label,
  required IconData prefix,
  IconData? suffix,
  Function? suffixPressed,
  bool isClickable = true,
}) =>
    TextFormField(
      controller: controller,
      keyboardType: type,
      obscureText: isPassword,
      enabled: isClickable,
      onFieldSubmitted: (value) {},
      onChanged: (value) {},
      onTap: () {
        onTap!();
      },
      validator: (value) {
        return validate(value);
      },
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(
          prefix,
        ),
        suffixIcon: suffix != null
            ? IconButton(
                onPressed: () {},
                icon: Icon(
                  suffix,
                ),
              )
            : null,
        border: OutlineInputBorder(),
      ),
    );

Widget buildTaskItem(Map model)=> Padding(
  padding: const EdgeInsets.all(10.0),
  child: Row(
    children: [
      CircleAvatar(
        radius: 40,
        child: Text('${model['date']}'),
      ),
      SizedBox(width: 20,),
      Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            '${model['title']}',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          Text(
            '${model['time']}',
            style: TextStyle(color: Colors.grey[600], fontSize: 12, fontWeight: FontWeight.bold),
          ),
        ],
      )
    ],
  ),
);
