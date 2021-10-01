import 'package:flutter/material.dart';
import 'package:nhentai/Constant.dart';
import 'package:nhentai/bloc/IntegerBloc.dart';

class ReaderThumbnail extends StatefulWidget {
  final String thumbnailUrl;
  final double width;
  final double height;
  final int thumbnailIndex;
  final Function(int) onThumbnailSelected;
  final IntegerBloc selectedIndexBloc;

  const ReaderThumbnail(
      {Key? key,
      required this.thumbnailUrl,
      required this.width,
      required this.height,
      required this.thumbnailIndex,
      required this.onThumbnailSelected,
      required this.selectedIndexBloc})
      : super(key: key);

  @override
  _ReaderThumbnailState createState() => _ReaderThumbnailState();
}

class _ReaderThumbnailState extends State<ReaderThumbnail> {
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      child: StreamBuilder(
        stream: widget.selectedIndexBloc.output,
        initialData: 0,
        builder: (BuildContext context, AsyncSnapshot snapshot) {
          int selectedIndex = snapshot.data;
          return Card(
            child: Padding(
              padding: EdgeInsets.all(3),
              child: Container(
                width: widget.width,
                height: widget.height,
                child: Stack(
                  alignment: AlignmentDirectional.bottomCenter,
                  children: [
                    Image.network(
                      widget.thumbnailUrl,
                      width: double.infinity,
                      height: double.infinity,
                      fit: BoxFit.cover,
                      errorBuilder: (BuildContext context, Object error,
                          StackTrace? stackTrace) {
                        return Container(
                          color: Constant.getNothingColor(),
                          padding: EdgeInsets.all(5),
                          child: Image.asset(
                            Constant.IMAGE_NOTHING,
                            width: double.infinity,
                            height: double.infinity,
                            fit: BoxFit.fitWidth,
                          ),
                        );
                      },
                    ),
                    Container(
                      color: Constant.black96000000,
                      padding: EdgeInsets.symmetric(vertical: 2, horizontal: 5),
                      child: Center(
                        child: Text(
                          '${widget.thumbnailIndex + 1}',
                          style: TextStyle(
                              fontFamily: Constant.NUNITO_REGULAR,
                              fontSize: 10,
                              color: Colors.white),
                        ),
                      ),
                      width: double.infinity,
                      height: 20,
                    )
                  ],
                ),
              ),
            ),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(5.0),
            ),
            color: (widget.thumbnailIndex == selectedIndex)
                ? Constant.mainColor
                : Colors.white,
          );
        },
      ),
      onTap: () {
        widget.onThumbnailSelected(widget.thumbnailIndex);
      },
    );
  }
}
