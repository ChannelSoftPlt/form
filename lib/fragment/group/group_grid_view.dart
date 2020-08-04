import 'package:flutter/material.dart';
import 'package:my/object/order_group.dart';

import 'detail/final_group_detail.dart';


class GroupGridView extends StatefulWidget {
  final OrderGroup orderGroup;

  GroupGridView({this.orderGroup});

  @override
  _GroupGridViewState createState() => _GroupGridViewState();
}

class _GroupGridViewState extends State<GroupGridView> {
  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.all(10.0),
      child: InkWell(
        onTap: () => openGroupDetail(),
        child: Padding(
          padding: const EdgeInsets.all(5.0),
          child: Column(
            children: <Widget>[
              Icon(
                Icons.folder,
                size: 100,
                color: Colors.grey,
              ),
              Expanded(
                child: Text(
                  widget.orderGroup.groupName,
                  style: TextStyle(color: Colors.black87, fontSize: 13),
                  textAlign: TextAlign.left,
                ),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: <Widget>[
                  Text(
                    'No Order: ${widget.orderGroup.totalOrder.toString()}',
                    style: TextStyle(
                        color: Colors.black87,
                        fontSize: 12,
                        fontWeight: FontWeight.bold),
                  ),
                  popUpMenu(widget.orderGroup.orderGroupId, context)
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  openGroupDetail() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => GroupDetail(
          orderGroup: widget.orderGroup,
        ),
      ),
    );
  }

  Widget popUpMenu(id, context) {
    return new PopupMenuButton(
      icon: Icon(
        Icons.more_vert,
        color: Colors.black87,
      ),
      offset: Offset(0, 10),
      itemBuilder: (context) => [
        PopupMenuItem(
          value: 'detail',
          child: Text("View Details"),
        ),
        PopupMenuItem(
          value: 'whatsapp',
          child: Text("WhatsApp"),
        ),
      ],
      onCanceled: () {},
      onSelected: (value) {},
    );
  }
}
