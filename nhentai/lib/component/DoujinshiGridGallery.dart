import 'package:flutter/material.dart';
import 'package:nhentai/bloc/DoujinshiListBloc.dart';
import 'package:nhentai/domain/entity/Doujinshi.dart';

class DoujinshiGridGallery extends StatefulWidget {
  final DoujinshiListBloc doujinshiListBloc;

  const DoujinshiGridGallery({Key? key, required this.doujinshiListBloc})
      : super(key: key);

  @override
  _DoujinshiGridGalleryState createState() => _DoujinshiGridGalleryState();
}

class _DoujinshiGridGalleryState extends State<DoujinshiGridGallery> {
  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
        stream: widget.doujinshiListBloc.output,
        initialData: <Doujinshi>[],
        builder: (BuildContext context, AsyncSnapshot snapshot) {
          List<Doujinshi> _doujinshiList = snapshot.data;
          return GridView.builder(
            physics: NeverScrollableScrollPhysics(),
            itemCount: _doujinshiList.length,
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 10,
                mainAxisSpacing: 0,
                childAspectRatio: 2 / 3),
            padding: EdgeInsets.all(0),
            shrinkWrap: true,
            itemBuilder: (BuildContext context, int index) {
              EdgeInsets margins = index % 2 != 0
                  ? EdgeInsets.fromLTRB(0, 10, 10, 0)
                  : EdgeInsets.fromLTRB(10, 10, 0, 0);
              Doujinshi doujinshi = _doujinshiList[index];
              List<InlineSpan> spans = [];
              if (doujinshi.languageIcon.isNotEmpty) {
                spans.add(WidgetSpan(
                    child: SizedBox(
                  child: Container(
                    child: Image.asset(doujinshi.languageIcon),
                    margin: EdgeInsets.fromLTRB(0, 0, 3, 0),
                  ),
                  width: 30,
                  height: 15,
                )));
              }
              spans.add(TextSpan(text: doujinshi.title.english));
              return Card(
                  child: Padding(
                    padding: EdgeInsets.all(3),
                    child: Container(
                      child: Stack(
                        alignment: AlignmentDirectional.bottomCenter,
                        children: [
                          Image.network(
                            doujinshi.bookThumbnail,
                            height: double.infinity,
                            width: double.infinity,
                            fit: BoxFit.cover,
                          ),
                          Container(
                            height: 60,
                            color: Colors.grey.withOpacity(0.9),
                            padding: EdgeInsets.symmetric(horizontal: 5),
                            child: Center(
                              child: RichText(
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                                text: TextSpan(
                                    style: TextStyle(
                                        fontFamily: 'NunitoRegular',
                                        fontSize: 14,
                                        color: Colors.white),
                                    children: spans),
                              ),
                            ),
                          )
                        ],
                      ),
                    ),
                  ),
                  margin: margins,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(5.0),
                  ));
            },
          );
        });
  }
}
