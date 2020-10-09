import 'package:flutter/material.dart';
import 'package:my/fragment/group/edit_group_name_dialog.dart';
import 'package:my/object/order_group.dart';
import 'package:my/shareWidget/snack_bar.dart';
import 'package:my/translation/AppLocalizations.dart';
import 'package:my/utils/domain.dart';

import 'detail/group_detail.dart';

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
                  getGroupName(),
                  style: TextStyle(color: Colors.black87, fontSize: 13),
                  textAlign: TextAlign.left,
                ),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: <Widget>[
                  Text(
                    '${AppLocalizations.of(context).translate('number_order')} ${widget.orderGroup.totalOrder.toString()}',
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

  String getGroupName() {
    try {
      return widget.orderGroup.groupName.split('\-')[1];
    } catch (e) {
      return widget.orderGroup.groupName;
    }
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
          child:
              Text("${AppLocalizations.of(context).translate('view_detail')}"),
        ),
        PopupMenuItem(
          value: 'edit',
          child: Text("${AppLocalizations.of(context).translate('edit_name')}"),
        ),
      ],
      onCanceled: () {},
      onSelected: (value) {
        switch (value) {
          case 'detail':
            openGroupDetail();
            break;
          case 'edit':
            showEditGroupNameDialog(context);
            break;
        }
      },
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

  /*
  * edit product dialog
  * */
  showEditGroupNameDialog(mainContext) {
    // flutter defined function
    showDialog(
      context: mainContext,
      builder: (BuildContext context) {
        // return alert dialog object
        return EditGroupNameDialog(
            orderGroup: widget.orderGroup,
            onClick: (OrderGroup orderGroup) async {
              await Future.delayed(Duration(milliseconds: 300));
              Navigator.pop(mainContext);

              Map data = await Domain().updateGroupName(orderGroup);
              print(data);
              if (data['status'] == '1') {
                CustomSnackBar.show(mainContext,
                    '${AppLocalizations.of(context).translate('update_success')}');
                setState(() {});
              } else
                CustomSnackBar.show(mainContext,
                    '${AppLocalizations.of(context).translate('something_went_wrong')}');
            });
      },
    );
  }
}
