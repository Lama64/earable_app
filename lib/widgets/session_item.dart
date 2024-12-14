import 'package:earable_app/models/session.dart';
import 'package:earable_app/widgets/delete_dialog.dart';
import 'package:flutter/material.dart';

class SessionItem extends StatefulWidget {
  const SessionItem({required this.session, required this.onDelete, super.key});

  final Session session;
  final VoidCallback onDelete;

  @override
  State<SessionItem> createState() => _SessionItemState();
}

class _SessionItemState extends State<SessionItem> {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      child: Container(
        height: 125,
        decoration: BoxDecoration(
          color: Colors.cyan,
          borderRadius: BorderRadius.circular(24),
        ),
        child: Stack(
          children: [
            // Text at top left
            Positioned(
                top: 5,
                left: 12,
                child: ConstrainedBox(
                    constraints: BoxConstraints(
                      maxWidth: MediaQuery.of(context).size.width - 100,
                    ),
                    child: Text(widget.session.name,
                        overflow: TextOverflow.fade,
                        maxLines: 1,
                        softWrap: false,
                        style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Colors.white)))),
            // Text at bottom left
            Positioned(
              bottom: 5,
              left: 12,
              child: Text(
                widget.session.id.toString(),
                style: TextStyle(fontSize: 16, color: Colors.white),
              ),
            ),
            // close button
            Positioned(
                top: 10,
                right: 10,
                child: GestureDetector(
                    onTap: () {
                      showDialog(
                          context: context,
                          builder: (context) => DeleteDialog(
                                onDeletePressed: widget.onDelete,
                                sessionName: widget.session.name,
                              ));
                    },
                    child: Icon(
                      Icons.close,
                      color: Colors.white,
                    )))
          ],
        ),
      ),
    );
  }
}
