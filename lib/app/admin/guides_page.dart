import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:mirai/mirai.dart';

import 'package:supabase_flutter/supabase_flutter.dart';
import '../../main.dart';

class GuidesPage extends StatefulWidget {
  const GuidesPage({super.key});

  @override
  _GuidesPageState createState() => _GuidesPageState();
}

class _GuidesPageState extends State<GuidesPage> with TickerProviderStateMixin {
  late AnimationController _controller;
  late AnimationController _controller2;
  late Animation<double> _animation;
  late Animation<double> _animation2;

  @override
  void initState() {
    super.initState();

    _controller2 = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    );

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 1),
    );

    _animation = Tween<double>(begin: 0, end: 1)
        .animate(CurvedAnimation(parent: _controller, curve: Curves.easeOut))
      ..addListener(() {
        setState(() {});
      });

    _animation2 = Tween<double>(begin: 0, end: -50).animate(CurvedAnimation(
        parent: _controller2, curve: Curves.fastLinearToSlowEaseIn));

    _controller.forward();
    _controller2.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    _controller2.dispose();
    super.dispose();
  }



  @override
  Widget build(BuildContext context) {
    double w = MediaQuery.of(context).size.width;
    return Scaffold(
      extendBodyBehindAppBar: true,
      body: Stack(
        children: [
          // background color
          //const backgroundColor(),
          FutureBuilder(
            future: supabaseHelper.fetchData('Guides'),
            builder: (BuildContext context, AsyncSnapshot<dynamic> snapshot) {
              print('snapshot: $snapshot');
              if (snapshot.connectionState == ConnectionState.waiting) {
                return Center(child: CircularProgressIndicator());
              } else if (snapshot.hasError) {
                print('error: ${snapshot.error}');
                return Text('Error: ${snapshot.error}');
              } else {
                print('data: ${snapshot.data}');
                return ListView.builder(
                  itemCount: snapshot.data.length + 1, // Add 1 to the itemCount
                  itemBuilder: (BuildContext context, int index) {
                    if (index == 0) {
                      return SizedBox(height: w / 5.5); // Add SizedBox at the top
                    } else {
                      print('index: ${index - 1}'); // Adjust the index
                      print('data[index]: ${snapshot.data[index - 1]}'); // Adjust the index
                      return Column(
                        children: [
                          card(1, snapshot.data[index - 1]['name'], snapshot.data[index - 1]['description'], snapshot.data[index - 1]['preview_img'],
                            RouteWhereYouGo(index - 1), // Adjust the index
                          ),
                        ],
                      );
                    }
                  },
                );
              }
            },
          ),
        ],
      ),
    );
  }


  Widget card(int id, String title, String subtitle, String icon, Widget route) {
    double w = MediaQuery.of(context).size.width;
    return Opacity(
      opacity: _animation.value,
      child: Transform.translate(
        offset: Offset(0, _animation2.value),
        child: Container(
          height: w / 2.3,
          width: w,
          padding: EdgeInsets.fromLTRB(w / 20, 0, w / 20, w / 20),
          child: InkWell(
            highlightColor: Colors.transparent,
            splashColor: Colors.transparent,
            onTap: () {
              HapticFeedback.lightImpact();
              Navigator.push(
                  context, MaterialPageRoute(builder: (context) => route));
            },
            child: Container(
              decoration: BoxDecoration(
                  color: Colors.white.withOpacity(.2),
                  borderRadius: const BorderRadius.all(Radius.circular(30)),
                  border: Border.all(
                      color: Colors.white.withOpacity(.1), width: 1)),
              child: Padding(
                padding: EdgeInsets.all(w / 50),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    Container(
                      height: w / 3,
                      width: w / 3,
                      decoration: BoxDecoration(
                          color: Colors.white.withOpacity(.2),
                          borderRadius: BorderRadius.circular(20)),
                      child: Image.network(icon),
                    ),
                    SizedBox(width: w / 40),
                    SizedBox(
                      width: w / 2.05,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            title,
                            maxLines: 2,
                            softWrap: true,
                            overflow: TextOverflow.ellipsis,
                            textAlign: TextAlign.start,
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: w / 20,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 1,
                              wordSpacing: 1,
                            ),
                          ),
                          Text(
                            subtitle,
                            maxLines: 1,
                            softWrap: true,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              color: Colors.white.withOpacity(1),
                              fontSize: w / 25,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          Text(
                            'Tap to know more',
                            maxLines: 1,
                            softWrap: true,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: w / 30,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class backgroundColor extends StatelessWidget {
  const backgroundColor({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Color(0xff7dff97),
            Color(0xff9effc8),
            Color(0xff7fca7f),
            Color(0xffb1f9c2),
            Color(0xffbee8b8),
          ],
          begin: Alignment.topRight,
          end: Alignment.bottomLeft,
        ),
      ),
    );
  }
}

class RouteWhereYouGo extends StatelessWidget {
  final int index;
  const RouteWhereYouGo(this.index, {super.key});

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
        future: supabaseHelper.fetchData('Guides'),
        builder: (BuildContext context, AsyncSnapshot<dynamic> snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Text('Error: ${snapshot.error}');
          } else {
            print('data: ${snapshot.data}');
            return Scaffold(
                appBar: AppBar(
                  elevation: 50,
                  centerTitle: true,
                  shadowColor: Colors.black.withOpacity(.5),
                  title: Text(
                    snapshot.data[this.index]['name'],
                  ),
                  systemOverlayStyle: SystemUiOverlayStyle.light,
                  ),
                  body:Center(child:  MiraiApp(homeBuilder: (context) => Mirai.fromJson(snapshot.data[this.index]['json'], context),),),
            );
          }
        },
    );
  }
}