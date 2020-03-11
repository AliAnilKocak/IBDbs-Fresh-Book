import 'dart:convert';
import 'package:flutter/services.dart';
import 'package:flutter_icons/feather.dart';
import 'package:flutter_icons/font_awesome.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;

import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';

const url =
    'https://www.googleapis.com/books/v1/volumes?q=rings+inauthor:tolkien';

class BookFinderPage extends StatelessWidget {
  final List<String> imgList = [
    'https://images.unsplash.com/photo-1459623837994-06d03aa27b9b?ixlib=rb-1.2.1&ixid=eyJhcHBfaWQiOjEyMDd9&auto=format&fit=crop&w=1789&q=80',
    'https://images.unsplash.com/photo-1507842217343-583bb7270b66?ixlib=rb-1.2.1&auto=format&fit=crop&w=1753&q=80',
    'https://images.unsplash.com/photo-1503543791519-1694c6b20779?ixlib=rb-1.2.1&auto=format&fit=crop&w=1650&q=80',
    'https://images.unsplash.com/photo-1509291985095-788b32582a81?ixlib=rb-1.2.1&ixid=eyJhcHBfaWQiOjEyMDd9&auto=format&fit=crop&w=668&q=80',
    'https://images.unsplash.com/photo-1517187654069-ba29110a1d9e?ixlib=rb-1.2.1&ixid=eyJhcHBfaWQiOjEyMDd9&auto=format&fit=crop&w=1652&q=80',
    'https://images.unsplash.com/photo-1508786728476-bf323753efaa?ixlib=rb-1.2.1&auto=format&fit=crop&w=800&q=80'
  ];

  CarouselSlider buildCarouselSlider() {
    return CarouselSlider(
      height: 150,
      viewportFraction: 0.9,
      aspectRatio: 16 / 9,
      autoPlay: true,
      enlargeCenterPage: true,
      items: imgList.map(
        (url) {
          return Stack(
            children: <Widget>[
              Container(
                margin: EdgeInsets.all(5.0),
                child: ClipRRect(
                  borderRadius: BorderRadius.all(Radius.circular(5.0)),
                  child: Image.network(
                    url,
                    fit: BoxFit.cover,
                    width: 1000.0,
                  ),
                ),
              ),
            ],
          );
        },
      ).toList(),
    );
  }

  @override
  Widget build(BuildContext context) {
    List<Color> colors = [
      Color(0xFFcc0e74),
      Color(0xFF5b8c5a),
      Color(0xFF56D4F9),
      Color(0xFFF65187),
      Color(0xFFfeb72b),
    ];
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle(
        statusBarColor: Colors.white,
        statusBarIconBrightness: Brightness.dark,
      ),
      child: Scaffold(
          backgroundColor: Colors.white,
          body: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                buildTitle(),
                buildSearchBar(),
                buildCarouselSlider(),
                SizedBox(
                  height: 84,
                  child: ListView(
                    scrollDirection: Axis.horizontal,
                    children: <Widget>[
                      buildIcon(
                          Icon(Feather.getIconData("heart"), color: colors [0]), "Favorite Books"),
                      buildIcon(Icon(Feather.getIconData("book-open"),color: colors [1]), "  Book List  "),
                      buildIcon(Icon(Feather.getIconData("trending-up"),color: colors [2]), "Trending Up   "),
                      buildIcon(Icon(Feather.getIconData("trending-down"),color: colors [3]), "Trending Down"),
                      buildIcon(Icon(Feather.getIconData("star"),color: colors [4]), "Marked Books"),
                    ],
                  ),
                ),
                FutureBuilder(
                    future: _fetchPotterBooks(),
                    builder: (context, AsyncSnapshot<List<Book>> snapshot) {
                      if (snapshot.connectionState == ConnectionState.done) {
                        if (snapshot.hasError) {
                          return Center(
                              child: Text('Error: ${snapshot.error}'));
                        } else {
                          return Stack(
                            children: <Widget>[
                              Center(
                                  child: Column(
                                children: <Widget>[
                                  Text(
                                    "Recommended Books",
                                    style: GoogleFonts.lato(
                                        fontStyle: FontStyle.italic,
                                        fontSize: 22,
                                        color: Colors.indigo),
                                  ),
                                  Divider(
                                    color: Colors.indigo.withOpacity(0.5),
                                  )
                                ],
                              )),
                              ListView(
                                  shrinkWrap: true,
                                  physics: NeverScrollableScrollPhysics(),
                                  children: snapshot.data
                                      .map((b) => BookTile(b))
                                      .toList())
                            ],
                          );
                        }
                      } else {
                        return Center(child: SpinKitWanderingCubes(
                          itemBuilder: (BuildContext context, int index) {
                            return DecoratedBox(
                              decoration: BoxDecoration(
                                color: index.isEven
                                    ? Colors.indigo
                                    : Colors.deepPurpleAccent,
                              ),
                            );
                          },
                        ));
                      }
                    }),
              ],
            ),
          )),
    );
  }

  Container buildIcon(Icon icon, String title) {
    return Container(
      width: 88,
      child: Column(
        children: <Widget>[
          icon,
          Padding(
            padding: const EdgeInsets.only(top: 4.0),
            child: Text(
              title,
              style: GoogleFonts.lato(fontSize: 13),
            ),
          ),
        ],
      ),
      margin: EdgeInsets.all(12),
    );
  }

  Container buildSearchBar() {
    return Container(
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: <Widget>[
          Expanded(
            child: Container(
              margin: EdgeInsets.only(left: 12, top: 4, bottom: 2),
              child: TextField(
                decoration: InputDecoration(
                    enabledBorder: UnderlineInputBorder(
                      borderSide: BorderSide(color: Colors.transparent),
                    ),
                    focusedBorder: UnderlineInputBorder(
                      borderSide: BorderSide(color: Colors.transparent),
                    ),
                    hintText: "Search for books...",
                    hintStyle: TextStyle(color: Colors.grey, fontSize: 14)),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(right: 8.0),
            child: Icon(
              Icons.search,
              color: Colors.grey,
            ),
          )
        ],
      ),
      margin: EdgeInsets.all(16),
      height: 32,
      decoration: BoxDecoration(
          color: Color(0xFFf7f7f7), borderRadius: BorderRadius.circular(16)),
    );
  }

  Padding buildTitle() {
    return Padding(
      padding: const EdgeInsets.only(top: 32, left: 16),
      child: Text("FRESH BOOK",
          style: GoogleFonts.lato(
              textStyle: TextStyle(
                  fontWeight: FontWeight.w600,
                  fontStyle: FontStyle.italic,
                  color: Colors.indigo),
              fontSize: 18)),
    );
  }
}

class BookTile extends StatelessWidget {
  final Book book;

  BookTile(this.book);

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(top: 16),
      child: Stack(
        children: <Widget>[
          Container(
            decoration: BoxDecoration(boxShadow: [
              BoxShadow(
                color: Colors.grey.withOpacity(0.25),
                blurRadius: 25.0, // has the effect of softening the shadow
                spreadRadius: 0.2, // has the effect of extending the shadow
              )
            ], color: Colors.white, borderRadius: BorderRadius.circular(24)),
            margin: EdgeInsets.all(16),
            height: 160,
          ),
          Positioned(
            left: 32,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(8.0),
              child: Image.network(
                book.thumbnailUrl,
                height: 160,
              ),
            ),
          ),
          Positioned(
            top: 32,
            left: MediaQuery.of(context).size.width * 0.4,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  book.title,
                  style: GoogleFonts.lato(
                      fontWeight: FontWeight.bold, fontSize: 16),
                ),
                SizedBox(
                  height: 8,
                ),
                Text(
                  book.author,
                  style: GoogleFonts.openSans(),
                ),
                Container(
                    margin: EdgeInsets.only(top: 4),
                    child: Text(
                      book.description.substring(0, 25) + "...",
                      style: GoogleFonts.openSans(
                          color: Colors.black.withOpacity(0.5)),
                    )),
              ],
            ),
          ),
          Positioned(
            left: MediaQuery.of(context).size.width * 0.4,
            bottom: 32,
            child: Text("sdf"),
          )
        ],
      ),
    );
//    return ListTile(
//      leading: CircleAvatar(
//        backgroundImage: NetworkImage(book.thumbnailUrl),
//      ),
//      title: Text(
//        book.title,
//        style: GoogleFonts.openSans(),
//      ),
//      subtitle: Text(
//        book.author,
//        style: GoogleFonts.openSans(),
//      ),
//      onTap: () => _navigateToDetailsPage(book, context),
//    );
  }
}

List<Book> _fetchBooks() {
  return List.generate(100, (i) => Book(title: 'Book $i', author: 'Author $i'));
}

Future<List<Book>> _fetchPotterBooks() async {
  final res = await http.get(url);
  if (res.statusCode == 200) {
    return _parseBookJson(res.body);
  } else {
    throw Exception('Error: ${res.statusCode}');
  }
}

List<Book> _parseBookJson(String jsonStr) {
  final jsonMap = json.decode(jsonStr);
  final jsonList = (jsonMap['items'] as List);
  return jsonList
      .map((jsonBook) => Book(
          title: jsonBook['volumeInfo']['title'],
          author: (jsonBook['volumeInfo']['authors'] as List).join(', '),
          thumbnailUrl: jsonBook['volumeInfo']['imageLinks']['smallThumbnail'],
          description: jsonBook['volumeInfo']['description']))
      .toList();
}

class Book {
  final String title;
  final String author;
  final String thumbnailUrl;
  final String description;

  Book(
      {@required this.title,
      @required this.author,
      this.thumbnailUrl,
      this.description})
      : assert(title != null),
        assert(author != null);
}

void _navigateToDetailsPage(Book book, BuildContext context) {
  Navigator.of(context).push(MaterialPageRoute(
    builder: (context) => BookDetailsPage(book),
  ));
}

class BookDetailsPage extends StatelessWidget {
  final Book book;

  BookDetailsPage(this.book);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(15.0),
        child: BookDetails(book),
      ),
    );
  }
}

class BookDetails extends StatelessWidget {
  final Book book;

  BookDetails(this.book);

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          Image.network(book.thumbnailUrl),
          SizedBox(height: 10.0),
          Text(book.title),
          Padding(
            padding: const EdgeInsets.only(top: 10.0),
            child: Text(book.author,
                style: TextStyle(fontWeight: FontWeight.w700)),
          ),
        ],
      ),
    );
  }
}
