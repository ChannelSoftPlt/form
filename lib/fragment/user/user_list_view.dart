import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:my/object/order.dart';
import 'package:my/object/user.dart';
import 'package:url_launcher/url_launcher.dart';

class UserListView extends StatefulWidget {
  final User user;

  UserListView({this.user});

  @override
  _UserListViewState createState() => _UserListViewState();
}

class _UserListViewState extends State<UserListView> {
  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.all(10.0),
      child: InkWell(
        onTap: () => null,
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Text(
                widget.user.name,
                style: TextStyle(
                    color: Colors.black87,
                    fontSize: 16,
                    fontWeight: FontWeight.bold),
                textAlign: TextAlign.left,
              ),
              SizedBox(
                height: 5,
              ),
              Text(
                '+' + Order.getPhoneNumber(widget.user.phone),
                style: TextStyle(color: Colors.black87, fontSize: 14),
                textAlign: TextAlign.left,
              ),
              Text(
                widget.user.email,
                style: TextStyle(color: Colors.black87, fontSize: 14),
                textAlign: TextAlign.left,
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: <Widget>[
                  IconButton(
                    icon: Image.asset('drawable/whatsapp.png'),
                    color: Colors.green,
                    onPressed: () => User().openWhatsApp(
                        '+${Order.getPhoneNumber(widget.user.phone)}',
                        '',
                        context),
                  ),
                  Visibility(
                    visible: widget.user.email != '',
                    child: IconButton(
                      icon: Icon(
                        Icons.email,
                        color: Colors.red,
                      ),
                      onPressed: () => launch(openEmail().toString()),
                    ),
                  ),
                  IconButton(
                    icon: Icon(
                      Icons.call,
                      color: Colors.blue,
                    ),
                    onPressed: () => launch(
                        ('tel://+${Order.getPhoneNumber(widget.user.phone)}')),
                  ),
                ],
              )
            ],
          ),
        ),
      ),
    );
  }

  Uri openEmail() {
    return Uri(
        scheme: 'mailto',
        path: widget.user.email,
        queryParameters: {'subject': ''});
  }

}
