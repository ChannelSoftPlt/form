import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:my/fragment/user/user_order_record.dart';
import 'package:my/object/order.dart';
import 'package:my/object/user.dart';
import 'package:my/translation/AppLocalizations.dart';
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
      elevation: 3,
      child: InkWell(
        onTap: () => openUserOrderRecord(),
        child: Padding(
          padding: const EdgeInsets.all(10.0),
          child: Row(
            children: [
              Expanded(child: Icon(Icons.assignment_ind, color: Colors.lightBlue,)),
              Expanded(
                flex: 3,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.start,
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
                      style: TextStyle(color: Colors.blueGrey, fontSize: 14),
                      textAlign: TextAlign.left,
                    ),
                    Text(
                      widget.user.email,
                      style: TextStyle(color: Colors.blueGrey, fontSize: 12),
                      textAlign: TextAlign.left,
                    ),
                  ],
                ),
              ),
              Expanded(child: popUpMenu(context))
            ],
          ),
        ),
      ),
    );
  }

  Widget popUpMenu(context) {
    return new PopupMenuButton(
      icon: Icon(
        Icons.tune,
        color: Colors.grey,
      ),
      offset: Offset(0, 10),
      itemBuilder: (context) => [
        PopupMenuItem(
          value: 'detail',
          child:
              Text('${AppLocalizations.of(context).translate('view_detail')}'),
        ),
        PopupMenuItem(
          value: 'whatsapp',
          child:
              Text('${AppLocalizations.of(context).translate('whatsapp')}'),
        ),
        PopupMenuItem(
          value: 'call',
          child:
              Text('${AppLocalizations.of(context).translate('phone_call')}'),
        ),
        if (widget.user.email != '')
          PopupMenuItem(
            value: 'email',
            child:
                Text('${AppLocalizations.of(context).translate('email')}'),
          ),
      ],
      onCanceled: () {},
      onSelected: (value) {
        switch (value) {
          case 'detail':
            openUserOrderRecord();
            break;
          case 'whatsapp':
            User().openWhatsApp(
                '+${Order.getPhoneNumber(widget.user.phone)}', '', context);
            break;
          case 'email':
            openEmail();
            break;
          case 'call':
            launch(('tel://+${Order.getPhoneNumber(widget.user.phone)}'));
            break;
        }
      },
    );
  }

  openUserOrderRecord() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => UserOrderRecord(
          user: widget.user,
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
