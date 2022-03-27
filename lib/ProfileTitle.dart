import 'package:flutter/material.dart';
import 'globals.dart' as globals;

class ProfileTitle extends StatefulWidget {
  const ProfileTitle(
      {Key? key, required this.title, required this.param, required this.func})
      : super(key: key);

  final String title;
  final String param;
  final VoidCallback func;

  @override
  State<ProfileTitle> createState() => _ProfileTitleState();
}

class _ProfileTitleState extends State<ProfileTitle> {
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: widget.func,
      child: Container(
        margin: EdgeInsets.only(left: 10, right: 10, bottom: 10),
        width: double.infinity,
        child: Padding(
          padding: EdgeInsets.only(left: 10, right: 10, bottom: 10),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Divider(
                height: 10,
                color: Colors.black,
                thickness: 0.7,
              ),
              Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(5),
                  //color: Color.fromARGB(255, 255, 173, 79),
                ),
                width: double.infinity,
                alignment: Alignment.centerLeft,
                //color: Color.fromARGB(255, 108, 213, 245),
                child: Text(
                  widget.title,
                  style: TextStyle(
                      fontWeight: FontWeight.w500,
                      color: globals.primaryColor!.shade300,
                      fontSize: 15,
                      fontStyle: FontStyle.italic,
                      fontFamily: 'Calibri'),
                ),
              ),
              Padding(padding: EdgeInsets.only(bottom: 5)),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          widget.param,
                          style: TextStyle(fontSize: 17),
                        ),
                      ],
                    ),
                  ),
                  // Container(
                  //   margin: EdgeInsets.only(left: 10, right: 10),
                  //   //width: 200,
                  //   alignment: Alignment.centerRight,
                  //   child: ElevatedButton(
                  //     onPressed: widget.func,
                  //     child: Text(
                  //       'change',
                  //       style: TextStyle(color: Colors.white),
                  //     ),
                  //   ),
                  // )
                ],
              )
            ],
          ),
        ),
      ),
    );
  }
}
