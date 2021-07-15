import 'dart:io';

import 'package:audioplayers/audio_cache.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:background_fetch/background_fetch.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:in_app_review/in_app_review.dart';
import 'package:islamic_prayer_times/main.dart';
import 'package:islamic_prayer_times/map.dart';
import 'package:islamic_prayer_times/provider/settings_provider.dart';
import 'package:islamic_prayer_times/service/Utils.dart';
import 'package:provider/provider.dart';
import 'package:share_plus/share_plus.dart';

enum Availability { LOADING, AVAILABLE, UNAVAILABLE }

extension on Availability {
  String stringify() => this.toString().split('.').last;
}

class Settings extends StatefulWidget {
  @override
  _SettingsState createState() => _SettingsState();
}

class _SettingsState extends State<Settings> {
  // AudioPlayer audioPlayer;
  // final audioCache = AudioCache(fixedPlayer: AudioPlayer(mode: PlayerMode.LOW_LATENCY,playerId: "playerID"),);
  final audioCache = AudioCache(
    fixedPlayer: AudioPlayer(),
  );

  final InAppReview _inAppReview = InAppReview.instance;
  String _appStoreId = '';
  String _microsoftStoreId = '';
  Availability _availability = Availability.LOADING;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      try {
        final isAvailable = await _inAppReview.isAvailable();

        setState(() {
          _availability = isAvailable && Platform.isAndroid
              ? Availability.AVAILABLE
              : Availability.UNAVAILABLE;
        });
      } catch (e) {
        setState(() => _availability = Availability.UNAVAILABLE);
      }
    });
  }

  Future<void> _openStoreListing() => _inAppReview.openStoreListing(
        appStoreId: _appStoreId,
        microsoftStoreId: _microsoftStoreId,
      );

  @override
  Widget build(BuildContext context) {
    var state = Provider.of<SettingsProvider>(context, listen: true);

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        title: Text(
          "Settings",
          style: TextStyle(color: Colors.black),
        ),
        iconTheme: IconThemeData(color: Colors.black45),
        brightness: Brightness.dark,
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            InkWell(
              onTap: () => {showHijriDateAdjustmentAlertDialog(context)},
              child: ListTile(
                title: Text("Hijri Date Adjustment"),
                leading: Wrap(
                  children: <Widget>[
                    Icon(Icons.date_range),
                  ],
                ),
              ),
            ),
            Divider(
              height: 0,
            ),
            InkWell(
              onTap: () => showPreferredCalculationMethodAlertDialog(context),
              child: ListTile(
                title: Text("Preferred calculation method"),
                leading: Wrap(
                  children: <Widget>[
                    Icon(Icons.call_to_action_outlined),
                  ],
                ),
              ),
            ),
            Divider(
              height: 0,
            ),
            InkWell(
              onTap: () => showMidnghtModeAlertDialog(context),
              child: ListTile(
                title: Text("Midnight mode"),
                leading: Wrap(
                  children: <Widget>[
                    Icon(Icons.nights_stay_outlined),
                  ],
                ),
              ),
            ),
            Divider(
              height: 0,
            ),
            InkWell(
              onTap: () => state.setUse24Hour(!state.use24Hour),
              child: ListTile(
                title: Text("Use 24 hour time"),
                leading: Wrap(
                  children: <Widget>[
                    Icon(Icons.access_time_outlined),
                  ],
                ),
                trailing: Wrap(
                  children: [
                    Switch(
                      value: state.use24Hour,
                      onChanged: (bool value) {
                        state.setUse24Hour(value);
                      },
                    )
                  ],
                ),
              ),
            ),
            Divider(
              height: 0,
            ),
            InkWell(
              onTap: () => showNotificationModeAlertDialog(context),
              /*onTap: () async {
                NotificationManager manager = NotificationManager();
                await manager.initNotificationManager();
                await flutterLocalNotificationsPlugin.schedule(
                  0,
                  'Prayer notification',
                  "Testing",
                  DateTime.now().add(Duration(seconds: 10)),
                  // platform,
                  manager.salahChannel(),
                );
              },*/
              child: ListTile(
                title: Text("Adhan Notification"),
                subtitle: RichText(
                  text: new TextSpan(
                    style: new TextStyle(
                      fontSize: 14.0,
                      color: Colors.black54,
                    ),
                    children: <TextSpan>[
                      new TextSpan(text: 'Set to '),
                      new TextSpan(
                          text:
                              '${notificationModeList[state.notificationMode].title}',
                          style: new TextStyle(fontWeight: FontWeight.w300)),
                    ],
                  ),
                ),
                leading: Wrap(
                  children: <Widget>[
                    Icon(Icons.notifications_none_outlined),
                  ],
                ),
                trailing: Wrap(
                  children: [
                    Switch(
                      value: state.enableNotifications,
                      onChanged: (bool value) async {
                        state.setEnableNotifications(value);

                        if (value) {
                          BackgroundFetch.start();
                        } else {
                          BackgroundFetch.stop();
                          await flutterLocalNotificationsPlugin.cancelAll();
                        }
                      },
                    )
                  ],
                ),
              ),
            ),
            Divider(
              height: 0,
            ),
            InkWell(
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => MapScreen()),
              ),
              child: ListTile(
                title: Text("Location"),
                subtitle: Visibility(
                    visible: state.address.trim().isNotEmpty,
                    child: Text(state.address)),
                leading: Wrap(
                  children: <Widget>[
                    Icon(Icons.location_on_outlined),
                  ],
                ),
              ),
            ),
            Divider(
              height: 0,
            ),
            InkWell(
              onTap: () => showMadhabAlertDialog(context),
              child: ListTile(
                title: Text("Madhab"),
                leading: Wrap(
                  children: <Widget>[
                    Icon(
                      Icons.book_outlined,
                      color: Colors.black45,
                    ),
                  ],
                ),
              ),
            ),
            Divider(
              height: 0,
            ),
            InkWell(
              onTap: () => _openStoreListing(),
              child: ListTile(
                title: Text("Rate app"),
                leading: Wrap(
                  children: <Widget>[
                    Icon(
                      Icons.star_border_outlined,
                      color: Colors.black45,
                    ),
                  ],
                ),
              ),
            ),
            Divider(
              height: 0,
            ),
            InkWell(
              onTap: () => _onShare(context),
              child: ListTile(
                title: Text("Share Prayer Times App"),
                leading: Wrap(
                  children: <Widget>[
                    Icon(
                      Icons.share_outlined,
                      color: Colors.black45,
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _onShare(BuildContext context) async {
    String appLink = Platform.isAndroid
        ? "https://play.google.com/store/apps/details?id=com.umratech.islamic_prayer_times"
        : "https://apps.apple.com/us/app/salaah-times/id1546578729";
    String subject =
        "Assalaamu Alaikum, checkout this prayer times app. It's ads free and privacy focused";
    final box = context.findRenderObject() as RenderBox;

    await Share.share(appLink,
        subject: subject,
        sharePositionOrigin: box.localToGlobal(Offset.zero) & box.size);
  }

  showHijriDateAdjustmentAlertDialog(BuildContext context) {
    var state = Provider.of<SettingsProvider>(context, listen: false);

    List<String> list = Utils().list;

    showDialog<void>(
      context: context,
      builder: (BuildContext context) {
        int selectedRadio = state.hijriDateAdjustment;
        return AlertDialog(
          title: Text("Hijri Date Adjustment"),
          actions: [
            FlatButton(
              child: Text("OK"),
              onPressed: () {
                state.setHijriDate(selectedRadio);
                Navigator.pop(context);
              },
            )
          ],
          content: StatefulBuilder(
            builder: (BuildContext context, StateSetter setState) {
              return Container(
                width: MediaQuery.of(context).size.width,
                child: ListView(
                  shrinkWrap: true,
                  children: List<Widget>.generate(list.length, (int index) {
                    return InkWell(
                      onTap: () {
                        setState(() => {selectedRadio = index});
                      },
                      child: Row(
                        children: [
                          Radio<int>(
                            value: index,
                            groupValue: selectedRadio,
                            onChanged: (value) => {
                              setState(() => {selectedRadio = value})
                            },
                          ),
                          Expanded(child: Text("${list[index].toString()}"))
                        ],
                      ),
                    );
                  }),
                ),
              );
            },
          ),
        );
      },
    );
  }

  showPreferredCalculationMethodAlertDialog(BuildContext context) {
    List<String> list = [
      "Shia Ithna-Ansari",
      "University of Islamic Sciences, Karachi",
      "Islamic Society of North America",
      "Muslim World League",
      "Umm Al-Qura University, Makkah",
      "Egyptian General Authority of Survey",
      "Institute of Geophysics, University of Tehran",
      "Gulf Region",
      "Kuwait",
      "Qatar",
      "Majlis Ugama Islam Singapura, Singapore",
      "Union Organization islamic de France",
      "Diyanet İşleri Başkanlığı, Turkey",
      "Spiritual Administration of Muslims of Russia",
    ];

    var state = Provider.of<SettingsProvider>(context, listen: false);

    showDialog<void>(
      context: context,
      builder: (BuildContext context) {
        int selectedRadio = state.preferredCalculationMethod;
        return AlertDialog(
          title: Text("Select method"),
          actions: [
            FlatButton(
              child: Text("OK"),
              onPressed: () {
                state.setPreferredCalculationMethod(selectedRadio);
                Navigator.pop(context);
              },
            )
          ],
          content: StatefulBuilder(
            builder: (BuildContext context, StateSetter setState) {
              return Container(
                width: MediaQuery.of(context).size.width,
                child: ListView(
                  shrinkWrap: true,
                  children: List<Widget>.generate(list.length, (int index) {
                    return InkWell(
                      onTap: () {
                        setState(() => {selectedRadio = index});
                      },
                      child: Row(
                        children: [
                          Radio<int>(
                            value: index,
                            groupValue: selectedRadio,
                            onChanged: (value) => {
                              setState(() => {selectedRadio = value})
                            },
                          ),
                          Expanded(child: Text("${list[index].toString()}"))
                        ],
                      ),
                    );
                  }),
                ),
              );
            },
          ),
        );
      },
    );
  }

  showMidnghtModeAlertDialog(BuildContext context) {
    List<String> list = [
      "Standard",
      "Jafari",
    ];

    var state = Provider.of<SettingsProvider>(context, listen: false);

    showDialog<void>(
      context: context,
      builder: (BuildContext context) {
        int selectedRadio = state.midNightMode;
        return AlertDialog(
          title: Text("Select Midnight Mode"),
          actions: [
            FlatButton(
              child: Text("OK"),
              onPressed: () {
                state.setMidNightMode(selectedRadio);
                Navigator.pop(context);
              },
            )
          ],
          content: StatefulBuilder(
            builder: (BuildContext context, StateSetter setState) {
              return Container(
                width: MediaQuery.of(context).size.width,
                child: ListView(
                  shrinkWrap: true,
                  children: List<Widget>.generate(list.length, (int index) {
                    return InkWell(
                      onTap: () {
                        setState(() => {selectedRadio = index});
                      },
                      child: Row(
                        children: [
                          Radio<int>(
                            value: index,
                            groupValue: selectedRadio,
                            onChanged: (value) => {
                              setState(() => {selectedRadio = value})
                            },
                          ),
                          Expanded(child: Text("${list[index].toString()}"))
                        ],
                      ),
                    );
                  }),
                ),
              );
            },
          ),
        );
      },
    );
  }

  showNotificationModeAlertDialog(BuildContext context) {
    var state = Provider.of<SettingsProvider>(context, listen: false);

    int result;

    showDialog<void>(
      context: context,
      builder: (BuildContext context) {
        int selectedRadio = state.notificationMode;
        return AlertDialog(
          title: Text("Select Notification Mode"),
          actions: [
            FlatButton(
              child: Text("OK"),
              onPressed: () async {
                state.setNotificationMode(selectedRadio);
                Navigator.pop(context);

                if (audioCache.fixedPlayer != null) {
                  await audioCache.fixedPlayer.stop(); //audio srope
                }

                setState(() {
                  for (int i = 0; i < notificationModeList.length; i++) {
                    notificationModeList[i].playingStatus = 0;
                  }
                });
              },
            )
          ],
          content: StatefulBuilder(
            builder: (BuildContext context, StateSetter setState) {
              return Container(
                width: MediaQuery.of(context).size.width,
                child: ListView(
                  shrinkWrap: true,
                  children: List<Widget>.generate(notificationModeList.length,
                      (int index) {
                    return InkWell(
                      onTap: () async {
                        setState(() {
                          selectedRadio = index;
                        });
                      },
                      child: Row(
                        children: [
                          Radio<int>(
                            value: index,
                            groupValue: selectedRadio,
                            onChanged: (value) => {
                              setState(() => {selectedRadio = value})
                            },
                          ),
                          Expanded(
                              child:
                                  Text("${notificationModeList[index].title}")),
                          Visibility(
                              visible: notificationModeList[index].playable,
                              child: InkWell(
                                  onTap: () async {
                                    if (notificationModeList[index]
                                            .playingStatus ==
                                        0) {
                                      await audioCache.play(
                                        notificationModeList[index].url,
                                      );
                                      setState(() {
                                        for (int i = 0;
                                            i < notificationModeList.length;
                                            i++) {
                                          notificationModeList[i]
                                              .playingStatus = 0;
                                        }
                                        notificationModeList[index]
                                            .playingStatus = 1;
                                      });
                                    } else if (notificationModeList[index]
                                            .playingStatus ==
                                        1) {
                                      if (audioCache.fixedPlayer != null) {
                                        await audioCache.fixedPlayer.stop();
                                      }
                                      setState(() {
                                        for (int i = 0;
                                            i < notificationModeList.length;
                                            i++) {
                                          notificationModeList[i]
                                              .playingStatus = 0;
                                        }
                                      });
                                    }
                                  },
                                  child: Icon(notificationModeList[index]
                                              .playingStatus ==
                                          0
                                      ? Icons.play_arrow_rounded
                                      : Icons.stop)))
                        ],
                      ),
                    );
                  }),
                ),
              );
            },
          ),
        );
      },
    );
  }

  showMadhabAlertDialog(BuildContext context) {
    List<String> list = [
      "Shafi",
      "Hanafi",
    ];

    var state = Provider.of<SettingsProvider>(context, listen: false);

    showDialog<void>(
      context: context,
      builder: (BuildContext context) {
        int selectedRadio = state.madhab;
        return AlertDialog(
          title: Text("Select Madhab"),
          actions: [
            FlatButton(
              child: Text("OK"),
              onPressed: () {
                state.setMadhab(selectedRadio);
                Navigator.pop(context);
              },
            )
          ],
          content: StatefulBuilder(
            builder: (BuildContext context, StateSetter setState) {
              return Container(
                width: MediaQuery.of(context).size.width,
                child: ListView(
                  shrinkWrap: true,
                  children: List<Widget>.generate(list.length, (int index) {
                    return InkWell(
                      onTap: () {
                        setState(() => {selectedRadio = index});
                      },
                      child: Row(
                        children: [
                          Radio<int>(
                            value: index,
                            groupValue: selectedRadio,
                            onChanged: (value) => {
                              setState(() => {selectedRadio = value})
                            },
                          ),
                          Expanded(child: Text("${list[index].toString()}"))
                        ],
                      ),
                    );
                  }),
                ),
              );
            },
          ),
        );
      },
    );
  }
}

class NotificationSounds {
  final String title;
  final String url;
  bool playable = true;
  int playingStatus;

  NotificationSounds(
      {this.title, this.url, this.playable = true, this.playingStatus = 0});
}

List<NotificationSounds> notificationModeList = [
  NotificationSounds(
      title: "Salah sound",
      url: "audio/hayya_alassallah_azan.mp3",
      playingStatus: 0),
  NotificationSounds(
      title: "Beep once sound", url: "audio/beep_once.mp3", playingStatus: 0),
  NotificationSounds(
      title: "Vibration", url: "", playingStatus: 0, playable: false),
  NotificationSounds(title: "Mute", url: "", playingStatus: 0, playable: false),
  NotificationSounds(
      title: "Ahmad Al Nafees",
      url: "audio/ahmad_al_nafees.mp3",
      playingStatus: 0),
  NotificationSounds(
      title: "Another Mishary Rashid Alafasy Adhan",
      url: "audio/another_mishary_rashid_alafasy_adhan.mp3",
      playingStatus: 0),
  NotificationSounds(
      title: "Dubai_s One TV by Mishary Rashid Alafasy",
      url: "audio/dubai_s_one_tv_by_mishary_rashid_alafasy.mp3",
      playingStatus: 0),
  NotificationSounds(
      title: "Hafiz Mustafa Özcan from Turkey",
      url: "audio/hafiz_mustafa_ozcan_from_turkey.mp3",
      playingStatus: 0),
  NotificationSounds(
      title: "Karl Jenkins_ The Armed Man (Mass for Peace)",
      url: "audio/karl_jenkins_the_armed_man_mass_for_peace.mp3",
      playingStatus: 0),
  NotificationSounds(
      title: "Masjid Al-Haram in Mecca",
      url: "audio/masjid_al_haram_in_mecca.mp3",
      playingStatus: 0),
  NotificationSounds(
      title: "Mishary Rashid Alafasy",
      url: "audio/mishary_rashid_alafasy.mp3",
      playingStatus: 0),
  NotificationSounds(
      title: "Qari Abdul Kareem",
      url: "audio/qari_abdul_kareem.mp3",
      playingStatus: 0),
  NotificationSounds(
      title: "Salah Mansoor Az-Zahrani",
      url: "audio/salah_mansoor_az_ahrani.mp3",
      playingStatus: 0),
  NotificationSounds(
      title: "Sheikh Jamac Hareed",
      url: "audio/sheikh_jamac_hareed.mp3",
      playingStatus: 0),
];

class ZakatScreen extends StatefulWidget {
  @override
  _ZakatScreenState createState() => _ZakatScreenState();
}

class _ZakatScreenState extends State<ZakatScreen> {
  String zakatValue = "";
  var _totalAmountController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white70,
      appBar: AppBar(
        title: Text("Zakat Calculator"),
        brightness: Brightness.dark,
      ),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            "Zakat $zakatValue",
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
          Container(
            padding: EdgeInsets.symmetric(horizontal: 10),
            margin: EdgeInsets.all(20),
            decoration: BoxDecoration(color: Colors.white),
            child: TextField(
              textInputAction: TextInputAction.search,
              keyboardType: TextInputType.number,
              controller: _totalAmountController,
              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
              decoration: InputDecoration(
                  border: InputBorder.none,
                  hintText: "Enter Your Total Amount"),
            ),
          ),
          RaisedButton(
            onPressed: () {
              double val = double.parse(_totalAmountController.text) * 2.5;
              double zakat = val / 100;

              setState(() {
                zakatValue = zakat.toString();
              });
            },
            color: Colors.blue,
            child: new Text(
              'Calculate',
              style: TextStyle(color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }
}
