import 'package:flutter/material.dart';

import '../main_page/profile_screen.dart';

class CommentWidget extends StatefulWidget {

  final String commentID;
  final String commenterID;
  final String commenterName;
  final String commenterImageURL;
  final String commentBody;

  const CommentWidget({super.key,
    required this.commentID,
    required this.commenterID,
    required this.commenterName,
    required this.commenterImageURL,
    required this.commentBody,
});

  @override
  State<CommentWidget> createState() => _CommentWidgetState();
}

class _CommentWidgetState extends State<CommentWidget> {

  final List<Color> _colors = [
    Colors.amber,
    Colors.orange,
    Colors.pink.shade500,
    Colors.brown,
    Colors.cyan,
    Colors.blueAccent,
    Colors.deepOrange,
  ];

  @override
  Widget build(BuildContext context) {
    _colors.shuffle();
    return InkWell(
      onTap: (){
        Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => Profile(userID: widget.commenterID)));
      },
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          Flexible(
            flex: 1,
            child: Container(
              height: 40,
              width: 40,
              decoration: BoxDecoration(
                border: Border.all(
                  width: 2,
                  color: _colors[1],
                ),
                shape: BoxShape.circle,
                image: DecorationImage(
                  image: NetworkImage(widget.commenterImageURL),
                  fit: BoxFit.fill,
                ),
              ),
            ),
          ),
          const SizedBox(width: 6,),
          Flexible(
            flex: 5,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.commenterName,
                  style: const TextStyle(
                    color: Colors.grey,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    fontStyle: FontStyle.normal,
                  ),
                ),
                Text(
                  widget.commentBody,
                  maxLines: 5,
                  style: const TextStyle(
                    color: Colors.grey,
                    fontSize: 14,
                    fontWeight: FontWeight.normal,
                    fontStyle: FontStyle.italic,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
