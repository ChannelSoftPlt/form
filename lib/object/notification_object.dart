import 'package:flutter/material.dart';

@immutable
class NotificationMessage{
  final String title, body;

  const NotificationMessage({
    @required this.title,
    @required this.body
  });
}
