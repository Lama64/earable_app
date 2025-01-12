import 'package:earable_app/models/session.dart';
import 'package:earable_app/pages/session_page.dart';
import 'package:earable_app/widgets/delete_dialog.dart';
import 'package:flutter/material.dart';

/// Widget to display a session on the home page.
class SessionItem extends StatefulWidget {
  const SessionItem({required this.session, required this.onDelete, super.key});

  /// Session to display.
  final Session session;

  /// Function called when the delete button is pressed.
  final VoidCallback onDelete;

  @override
  State<SessionItem> createState() => _SessionItemState();
}

class _SessionItemState extends State<SessionItem> {
  @override
  Widget build(BuildContext context) {
    return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),

        /// Move to session page when tapped
        child: GestureDetector(
          onTap: () => Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (context) => SessionPage(session: widget.session))),
          child: Container(
            height: 125,
            decoration: BoxDecoration(
                color: widget.session.backgroundColor,
                borderRadius: BorderRadius.circular(24),

                /// Use the logo from Steam if available.
                image: widget.session.logoUrl != null
                    ? DecorationImage(
                        image: NetworkImage(widget.session.logoUrl!),
                        fit: BoxFit.cover)
                    : null),
            child: Stack(
              children: [
                /// Text at top left.
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

                              /// White text if logo is available as most logos are dark.
                              color: widget.session.logoUrl != null
                                  ? Colors.white
                                  : Colors.black,
                            )))),

                /// Text at bottom left
                Positioned(
                  bottom: 5,
                  left: 12,
                  child: Text(
                    widget.session.dateCreated,
                    style: TextStyle(
                      fontSize: 16,

                      /// White text if logo is available as most logos are dark.
                      color: widget.session.logoUrl != null
                          ? Colors.white
                          : Colors.black,
                    ),
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

                          /// White icon if logo is available as most logos are dark.
                          color: widget.session.logoUrl != null
                              ? Colors.white
                              : Colors.black,
                        )))
              ],
            ),
          ),
        ));
  }
}
