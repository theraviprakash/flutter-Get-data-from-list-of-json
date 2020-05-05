import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:pull_to_refresh/pull_to_refresh.dart';
class TestPsPage extends StatefulWidget {
  @override
  _TestPsPageState createState() => _TestPsPageState();
}

class _TestPsPageState extends State<TestPsPage> {
  RefreshController _refreshController =
      RefreshController(initialRefresh: false);
  Future<List<Post>> fetchPosts() async {
  http.Response response = await http.get(
      'http://ws1.metcheck.com/ENGINE/v9_0/json.asp?lat=28&lon=-15.6&lid=62228&Fc=No');
  var responseJson = json.decode(response.body);
  print(responseJson['metcheckData']['forecastLocation']['forecast'][0]['rain']);
  return (responseJson['metcheckData']['forecastLocation']['forecast'] as List)
      .map((p) => Post.fromJson(p))
      .toList();
}

  void _onRefresh() async{
    // monitor network fetch
    await Future.delayed(Duration(milliseconds: 1000));
    // if failed,use refreshFailed()
    _refreshController.refreshCompleted();
  }
  @override
   Widget build(BuildContext context) {
    return Scaffold(
      body: SmartRefresher(
        enablePullDown: true,
        enablePullUp: true,
        header: WaterDropHeader(),
        footer: CustomFooter(
          builder: (BuildContext context,LoadStatus mode){
            Widget body ;
            if(mode==LoadStatus.idle){
              body =  Text("pull up load");
            }
            else if(mode==LoadStatus.loading){
              body =  Text("Loading..!");
            }
            else if(mode == LoadStatus.failed){
              body = Text("Load Failed!Click retry!");
            }
            else if(mode == LoadStatus.canLoading){
                body = Text("release to load more");
            }
            else{
              body = Text("No more Data");
            }
            return Container(
              height: 55.0,
              child: Center(child:body),
            );
          },
        ),
        controller: _refreshController,
        onRefresh: _onRefresh,
        // onLoading: _onLoading,
        child: ListView(
              children: <Widget>[
                new FutureBuilder<List<Post>>(
                  future: fetchPosts(),
                  builder: (context, snapshot) {
                    if (snapshot.hasData){
                      List<Post> posts = snapshot.data;
                      return new Column(
                          children: posts.map((post) => new Column(
                            children: <Widget>[
                              new Text(post.updateDate),
                            ],
                          )).toList()
                      );
                    }
                    else if(snapshot.hasError)
                    {
                      return snapshot.error;
                    }
                    return new Center(
                      child: new Column(
                        children: <Widget>[
                          new Padding(padding: new EdgeInsets.all(50.0)),
                          new CircularProgressIndicator(),
                        ],
                      ),
                    );
                  },
                ),

              ],
            ),
      ),
    );
  }
}


class Post {
  final String temperature, rain, humidity, sunrise, sunset, updateDate;

  Post({
    this.temperature,
    this.rain,
    this.humidity,
    this.sunrise,
    this.sunset,
    this.updateDate,
  });

  factory Post.fromJson(Map<String, dynamic> json) {
    return new Post(
      temperature: json['temperature'].toString(),
      rain: json['rain'].toString(),
      humidity: json['humidity'].toString(),
      sunrise: json['sunrise'].toString(),
      sunset: json['sunset'].toString(),
      updateDate: json['utcTime'].toString(),
    );
  }
}