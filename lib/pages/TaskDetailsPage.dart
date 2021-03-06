import 'package:cerf_mobile/components/DetailsCategory.dart';
import 'package:cerf_mobile/components/DetailsButton.dart';
import 'package:cerf_mobile/components/DetailsItem.dart';
import 'package:cerf_mobile/constants/secret.dart';
import 'package:cerf_mobile/model/Task.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:url_launcher/url_launcher.dart';

class TaskDetailsPage extends StatefulWidget {
  const TaskDetailsPage({this.task});

  final Task task;

  @override
  TaskDetailsPageState createState() => TaskDetailsPageState();
}

class TaskDetailsPageState extends State<TaskDetailsPage> {
  static final GlobalKey<ScaffoldState> _scaffoldKey =
      GlobalKey<ScaffoldState>();
  final double _appBarHeight = 256.0;

  Uri staticMapUri;

  @override
  initState() {
    super.initState();
    double lat = 43.006047;
    double lng = -81.260782;
    if (widget.task.lat != null && widget.task.lng != null) {
      lat = widget.task.lat;
      lng = widget.task.lng;
    }
    staticMapUri = Uri(
        scheme: "https",
        host: "maps.googleapis.com",
        path: "/maps/api/staticmap",
        queryParameters: {
          // Offsets slightly low because of gradient
          "center": "${lat + 0.0003},$lng",
          "key": Secret.gMapsAPI,
          "size": "400x900", // May not want to be static
          "zoom": "17", // Static for now
          "markers": "size:mid|color:0x2CA579|label:T|$lat,$lng"
        });
  }

  @override
  Widget build(BuildContext context) {
    Task task = widget.task;
    final ThemeData theme = Theme.of(context);
    final bool isDark = theme.brightness == Brightness.dark;
    final bool hasEmail = task.email != null && task.email.isNotEmpty;
    final bool hasPhone = task.phone != null && task.phone.isNotEmpty;

    return Scaffold(
      key: _scaffoldKey,
      body: CustomScrollView(
        slivers: <Widget>[
          SliverAppBar(
            expandedHeight: _appBarHeight,
            pinned: true,
            backgroundColor: isDark ? Colors.grey[900] : null,
            actions: <Widget>[
              IconButton(
                icon: Icon(Icons.create),
                tooltip: 'Edit',
                onPressed: () {
                  _scaffoldKey.currentState.showSnackBar(SnackBar(
                      content:
                          Text("Editing isn't supported in this screen.")));
                },
              ),
            ],
            flexibleSpace: FlexibleSpaceBar(
              background: Stack(
                fit: StackFit.expand,
                children: <Widget>[
                  Image.network(
                    staticMapUri.toString(),
                    fit: BoxFit.cover,
                    height: _appBarHeight,
                  ),

                  // This gradient ensures that the toolbar icons are distinct
                  // against the background image.
                  DecoratedBox(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment(0.0, -1.0),
                        end: Alignment(0.0, -0.4),
                        colors: <Color>[Color(0x60000000), Color(0x00000000)],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          SliverList(
            delegate: SliverChildListDelegate(<Widget>[
              DetailsCategory(
                children: <Widget>[
                  DetailsItem(
                    leftIcon: Icons.location_on,
                    icon: Icons.directions,
                    tooltip: 'Get Directions',
                    onPressed: () async {
                      Uri launchUri = Uri(
                          scheme: "https",
                          host: "www.google.com",
                          path: "/maps/search/",
                          queryParameters: {
                            "api": "1",
                            "query":
                                "${task.address}, ${task.city}, ${task.province}"
                          });
                      String url = launchUri.toString();

                      if (await canLaunch(url)) {
                        await launch(url);
                      } else {
                        throw 'Could not launch $url';
                      }
                    },
                    lines: <String>[
                      task.addressFormat(),
                      'Address',
                    ],
                  ),
                ],
              ),
              DetailsCategory(
                children: <Widget>[
                  DetailsItem(
                    leftIcon: Icons.calendar_today,
                    lines: <String>[
                      task.taskDateFormat(),
                      task.timeOfDayFormat(),
                      'Estimated time: ',
                    ],
                  ),
                  DetailsItem(
                    lines: <String>[
                      task.statusFormat(),
                      'Status',
                    ],
                  ),
                ],
              ),
              hasPhone || hasEmail
                  ? DetailsCategory(
                      children: <Widget>[
                        hasEmail
                            ? DetailsItem(
                                leftIcon: Icons.email,
                                lines: <String>[
                                  task.email,
                                  'Email',
                                ],
                              )
                            : Container(),
                        hasPhone
                            ? DetailsItem(
                                leftIcon: Icons.phone,
                                lines: <String>[
                                  task.phone,
                                  'Phone Number',
                                ],
                              )
                            : Container(),
                      ],
                    )
                  : Container(),
              task.notes != ""
                  ? Container(
                      decoration: BoxDecoration(
                          border: Border(
                              bottom: BorderSide(
                                  color: Theme.of(context).dividerColor))),
                      child: Padding(
                        padding: EdgeInsets.all(24.0),
                        child: Text(task.notes,
                            style: Theme.of(context).textTheme.caption),
                      ),
                    )
                  : Container(),
              Container(
                decoration: BoxDecoration(
                    border: Border(
                        bottom:
                            BorderSide(color: Theme.of(context).dividerColor))),
                child: Padding(
                  padding: EdgeInsets.all(24.0),
                  child: Column(
                    children: <Widget>[
                      // reword this maybe
                      Text("Share progress with the client:"),
                      Row(
                        children: <Widget>[
                          DetailsButton(
                            text: "Email",
                            icon: Icons.email,
                            onPressed:
                                task.email != null && task.email.isNotEmpty
                                    ? () {}
                                    : null,
                          ),
                          DetailsButton(
                            text: "Copy Link",
                            icon: Icons.link,
                            onPressed: () {},
                          ),
                          DetailsButton(
                            text: "Other",
                            icon: Icons.more_horiz,
                            onPressed: () {},
                          ),
                        ],
                      )
                    ],
                  ),
                ),
              ),
            ]),
          ),
        ],
      ),
    );
  }
}
