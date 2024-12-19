import 'package:earable_app/models/session.dart';
import 'package:earable_app/widgets/heart_rate_graph.dart';
import 'package:flutter/material.dart';

class SessionPage extends StatefulWidget {
  const SessionPage({super.key, required this.session});

  final Session session;

  @override
  State<SessionPage> createState() => _SessionPageState();
}

class _SessionPageState extends State<SessionPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(title: Text(widget.session.name)),
        body: Center(
          child: SizedBox(
            height: 300,
            child:
                Padding(padding: EdgeInsets.all(16), child: HeartRateGraph()),
          ),
        ));
  }
}
