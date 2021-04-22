import 'dart:async';
import 'dart:convert';
import 'package:connectivity/connectivity.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:http/http.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'url.dart';
import 'searchequipment.dart';
import 'basicAuth.dart';

class Dish {
  final String name;
  final String icon;
  Dish({this.name, this.icon});
}

class ComplaintHomePage extends StatefulWidget {
  final String arguments, userN;
  ComplaintHomePage({Key key, @required this.arguments, @required this.userN})
      : super(key: key);

  @override
  State<StatefulWidget> createState() => new StateHomePage();
}

class StateHomePage extends State<ComplaintHomePage> {
  String _id, rolename, defaulturl, seatId, agr, tit, menulength;
  bool isLoading = true;
  SharedPreferences prefs;
  Future _getMenuItems;

  // fetch Method of Menus from webservice   

  Future _getMainMenu() async {
    var connectivityResult = await (Connectivity().checkConnectivity());
    if (connectivityResult == ConnectivityResult.mobile ||
        connectivityResult == ConnectivityResult.wifi) {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      _id = (prefs.getString('username') ?? "");
      final formData = jsonEncode({
        "primaryKeys": ['$_id']
      });
      Response response =
          await ioClient.post(P_MENU_URL, headers: headers, body: formData);
      if (response.statusCode == 200) {
        Map<String, dynamic> list = json.decode(response.body);
        List<dynamic> userid = list["dataValue"];
        SharedPreferences prefs = await SharedPreferences.getInstance();
        prefs.setString("useridLength", userid.length.toString());
        print('object ${userid.length.toString()} $userid +++ ');
        return userid;
      } else {
        throw Exception('Failed to load Menu');
      }
    } else {
      return showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              backgroundColor: Color(0xffffffff),
              title: Text("Please Check your Internet Connection",
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 16, color: Color(0xff000000))),
            );
          });
    }
  }

  // Static menus of home page 

  List<Dish> _dishes = List<Dish>();
  void _populateDishes() {
    var list = <Dish>[
      Dish(
        name: 'Web Based Open Source Platform',
        icon: 'globe',
      ),
      Dish(name: 'Compliant to Health Standards', icon: 'hospital'),
      Dish(name: 'Payment Online/Offline', icon: 'rupee-sign'),
      Dish(name: 'Dashboard and Report', icon: 'chart-pie'),
      Dish(name: 'Alert Management', icon: 'bell'),
      Dish(name: 'Mobile Apps.', icon: 'mobile-alt'),
    ];
    setState(() {
      _dishes = list;
    });
  }

  // Method to change the hexadecimal color code via FontAwesomeIcons plugin

  IconData getIconForName(String iconName) {
    switch (iconName) {
      case 'globe':
        {
          return FontAwesomeIcons.globe;
        }
        break;
      case 'hospital':
        {
          return FontAwesomeIcons.hospital;
        }
        break;
      case 'rupee-sign':
        {
          return FontAwesomeIcons.rupeeSign;
        }
        break;
      case 'bell':
        {
          return FontAwesomeIcons.bell;
        }
        break;
      case 'chart-pie':
        {
          return FontAwesomeIcons.chartPie;
        }
        break;
      default:
        {
          return FontAwesomeIcons.mobileAlt;
        }
    }
  }

  @override
  void initState() {
    super.initState();
    setState(() {
      loadData();
    });
    _populateDishes();
    _getMenuItems = _getMainMenu();
  }

  // get the Stored value of user

  loadData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      rolename = (prefs.getString('uname') ?? "");
      _id = (prefs.getString('username') ?? "");
      defaulturl = (prefs.getString('defaultUrl') ?? "");
      menulength = (prefs.getString('useridLength') ?? "");
    });
  }

  final key = UniqueKey();

  @override

   // Main UI part of the screen
   
  Widget build(BuildContext context) {
    return MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'Welcome to EMMS',
        home: Scaffold(
          // AppBar
            appBar: AppBar(
              iconTheme: IconThemeData(color: Color(0xff2d0e3e)),
              backgroundColor: Color(0xffffffff),
              title: Row(
                children: [
                  Container(
                    height: 35.0,
                    width: 35.0,
                    margin: EdgeInsets.only(right: 5),
                    child: new Image(
                      image: AssetImage("assets/images/tnmsclogo.png"),
                      fit: BoxFit.contain,
                    ),
                  ),
                  RichText(
                    text: new TextSpan(
                      style: new TextStyle(
                        fontSize: 14.0,
                        color: Colors.black,
                      ),
                      children: <TextSpan>[
                        new TextSpan(
                            text: 'EMMS ',
                            style: new TextStyle(
                                fontSize: 19,
                                fontWeight: FontWeight.bold,
                                fontFamily: 'Open Sans',
                                color: Color(0xffC6426E))),
                        new TextSpan(
                            text: '| TNMSCL',
                            style: new TextStyle(
                                fontSize: 19,
                                fontWeight: FontWeight.bold,
                                fontFamily: 'Open Sans',
                                color: Color(0xff2d0e3e))),
                      ],
                    ),
                  ),
                ],
              ),
              actions: <Widget>[
              IconButton(
                  icon: Icon(Icons.exit_to_app),
                  onPressed: () async {
                    SharedPreferences prefs =
                        await SharedPreferences.getInstance();
                    prefs.remove("username");
                    prefs.remove("password");
                    Navigator.pushReplacementNamed(context, "/login");
                  },
                ),
              ],
            ),
          // Main Screen
          
            body: '$defaulturl' ==
                        'https://tnmscemms.prd.dcservices.in/eUpkaran/EUpkaranComplaintACTION?hmode=CallMasterPage&masterkey=complaintRaise&isGlobal=1&seatId=$_id'
                    ? 
                    // Has privilege to complaint Raise and other menus.
                    
                    Container(
                      child: SearchEquipment()   //Search Equipment screen 
                    )
                    : 
                    
                    //Static Menu screen for other username which has no privilege to complaint raise
                    
                    Center(
                        child: Container(
                            width: double.infinity,
                            height: MediaQuery.of(context).size.height -
                                0.1 * MediaQuery.of(context).size.height,
                            child: ListView(children: <Widget>[
                              SizedBox(
                                  height: 900,
                                  child: ListView.builder(
                                    physics: ClampingScrollPhysics(),
                                    itemCount: _dishes.length,
                                    itemBuilder: (context, index) {
                                      var item = _dishes[index];
                                      return Padding(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 12.0,
                                          vertical: 8.0,
                                        ),
                                        child: Card(
                                            color: Color(0xffeeeeee),
                                            elevation: 4.0,
                                            child: IntrinsicHeight(
                                                child: Row(
                                                    crossAxisAlignment:
                                                        CrossAxisAlignment
                                                            .start,
                                                    children: [
                                                  Expanded(
                                                    flex: 3,
                                                    child: Container(
                                                        margin: EdgeInsets.only(
                                                            top: 10,
                                                            bottom: 10),
                                                        child: Column(
                                                            children: [
                                                              IconButton(
                                                                  iconSize: 45,
                                                                  icon: Icon(
                                                                      getIconForName(item
                                                                          .icon),
                                                                      color: Color(
                                                                          0xffC6426E)),
                                                                  onPressed:
                                                                      () async {}),
                                                              Container(
                                                                  padding:
                                                                      const EdgeInsets
                                                                              .fromLTRB(
                                                                          20,
                                                                          5,
                                                                          10,
                                                                          5),
                                                                  child: Text(
                                                                    item.name,
                                                                    style: TextStyle(
                                                                        color: Color(
                                                                            0xff2c003e),
                                                                        fontFamily:
                                                                            'Open Sans',
                                                                        fontSize:
                                                                            18,
                                                                        fontWeight:
                                                                            FontWeight.w500),
                                                                  )),
                                                            ])),
                                                  ),
                                                ]))),
                                      );
                                    },
                                  )),
                            ])),
                      )));
  }
}
 
