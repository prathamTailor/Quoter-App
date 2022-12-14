import 'dart:ffi';
import 'dart:math';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';
import 'package:quoter/screens/text_recognition_screen/text_recognition_screen.dart';
import 'package:quoter/services/auth.dart';
import 'package:screenshot/screenshot.dart';
import 'dart:typed_data';
import 'package:material_dialogs/material_dialogs.dart';
import 'package:material_dialogs/widgets/buttons/icon_button.dart';
import 'package:share_plus/share_plus.dart';
import 'package:image_gallery_saver/image_gallery_saver.dart';
import 'package:wallpaper_manager_flutter/wallpaper_manager_flutter.dart';
import 'package:path_provider/path_provider.dart';
import 'package:quoter/screens/quotes_screen/quotes_screen.dart';
import 'dart:io' show File, Platform;
import 'dart:io' as IO;

class Home extends StatefulWidget {
  final AuthBase auth;

  final String quoteText;
  const Home({Key? key, required this.auth, required this.quoteText})
      : super(key: key);

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> with TickerProviderStateMixin {
  bool _isEditingText = false;
  TextEditingController _editingController = new TextEditingController();
  String initialText = "Initial Text";

  List<Color> paletteColors = [
    Colors.black,
    Colors.white,
    Color(int.parse('0xffEA2027')),
    Color(int.parse('0xff006266')),
    Color(int.parse('0xff1B1464')),
    Color(int.parse('0xff5758BB')),
    Color(int.parse('0xff6F1E51')),
    Color(int.parse('0xffB53471')),
    Color(int.parse('0xffEE5A24')),
    Color(int.parse('0xff009432')),
    Color(int.parse('0xff0652DD')),
    Color(int.parse('0xff9980FA')),
    Color(int.parse('0xff833471')),
    Color(int.parse('0xff112CBC4')),
    Color(int.parse('0xffFDA7DF')),
    Color(int.parse('0xffED4C67')),
    Color(int.parse('0xffF79F1F')),
    Color(int.parse('0xffA3CB38')),
    Color(int.parse('0xff1289A7')),
    Color(int.parse('0xffD980FA'))
  ];

  Random rand = new Random();
  int randomNumber = 0;

  TextStyle textStyle = new TextStyle();
  TextAlign textAlign = TextAlign.center;
  late TabController _tabController;
  double _currentSliderValue = 20;
  Color currColor = Colors.red;
  Color backColor = Colors.black;
  double top = 400.0, left = 150.0;
  bool isBold = false, isItalic = false;

  Uint8List? bytes;

  @override
  void initState() {
    super.initState();
    _editingController = TextEditingController(text: initialText);
    textAlign = TextAlign.start;
    textStyle = TextStyle(
      fontSize: 15,
      color: Colors.white,
    );
    _tabController = TabController(length: 6, vsync: this);
    _currentSliderValue = 15;
    currColor = Colors.red;
    randomNumber = rand.nextInt(paletteColors.length);
    backColor = paletteColors[randomNumber];
    if (randomNumber == 1) {
      textStyle = TextStyle(
        fontSize: 15,
        color: Colors.black,
      );
    }
    initialText = widget.quoteText;
    _editingController.text = widget.quoteText;
  }

  @override
  void dispose() {
    _editingController.dispose();
    super.dispose();
  }

  Widget _editTitleTextField() {
    if (_isEditingText)
      return Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Padding(
            padding: const EdgeInsets.all(10.0),
            child: Center(
              child: TextField(
                keyboardType: TextInputType.multiline,
                maxLines: null,
                autofocus: true,
                controller: _editingController,
              ),
            ),
          ),
          SizedBox(
            height: 30,
          ),
          // ElevatedButton(onPressed: onPressed, child: child),
          ElevatedButton(
              onPressed: () {
                setState(() {
                  initialText = _editingController.text;
                  _isEditingText = false;
                });
              },
              child: Text("Done"))
        ],
      );

    return Container(
      color: backColor,
      child: GestureDetector(
        child: Stack(
          children: <Widget>[
            Positioned(
              left: left,
              top: top,
              child: InkWell(
                onTap: () {
                  setState(() {
                    _isEditingText = true;
                  });
                },
                child: Text(
                  initialText,
                  style: textStyle,
                  textAlign: textAlign,
                ),
              ),
            ),
          ],
        ),
        onVerticalDragUpdate: (DragUpdateDetails dd) {
          setState(() {
            top = dd.localPosition.dy;
            left = dd.localPosition.dx;
          });
        },
      ),
    );
  }

  Future<void> _setwallpaper(location, Uint8List? bytes) async {
    // var file = await DefaultCacheManager().getSingleFile(imageurl);
    // print("Set wallpaper method...");
    String tempPath = (await getTemporaryDirectory()).path;
    File file = File('$tempPath/wallpaper.png');
    if (bytes != null) {
      await file.writeAsBytes(
          bytes.buffer.asUint8List(bytes.offsetInBytes, bytes.lengthInBytes));
    }
    try {
      WallpaperManagerFlutter().setwallpaperfromFile(file, location);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Wallpaper updated'),
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error Setting Wallpaper'),
        ),
      );
      print(e);
    }
  }

  _save(bytes) async {
    final result = await ImageGallerySaver.saveImage(Uint8List.fromList(bytes));
    // print(result);
  }

  Future<void> shareWallpaper(Uint8List? bytes) async {
    final temp = await getTemporaryDirectory();
    final path = '${temp.path}/image.jpg';
    if (bytes != null) {
      File(path).writeAsBytesSync(bytes);
    }
    await Share.shareFiles([path]);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Center(
            child: _editTitleTextField(),
          ),
          Container(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.end,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Container(
                    margin: EdgeInsets.only(
                        bottom: 8.0,
                        left: (MediaQuery.of(context).size.width / 2) * 0.8,
                        right: (MediaQuery.of(context).size.width / 2) * 0.8),
                    child: ClipRRect(
                      borderRadius: BorderRadius.all(Radius.circular(10)),
                      child: BackdropFilter(
                        filter: ImageFilter.blur(
                          sigmaX: 20.0,
                          sigmaY: 20.0,
                        ),
                        child: Container(
                          decoration: BoxDecoration(
                            color: Colors.white12,
                            borderRadius: BorderRadius.all(Radius.circular(10)),
                            border: Border.all(
                              color: Colors.black26,
                              width: 0.5,
                            ),
                          ),
                          child: Center(
                            child: Padding(
                              padding: const EdgeInsets.all(10.0),
                              child: TextButton(
                                style: TextButton.styleFrom(
                                  primary: textStyle.color,
                                ),
                                onPressed: () {
                                  showModalBottomSheet<void>(
                                    backgroundColor: Colors.transparent,
                                    barrierColor: Colors.transparent,
                                    // shape: RoundedRectangleBorder(
                                    //   borderRadius: BorderRadius.only(topLeft: Radius.circular(30.0),topRight: Radius.circular(30.0)),
                                    // ),
                                    context: context,
                                    builder: (BuildContext context) {
                                      return Container(
                                        margin: EdgeInsets.only(
                                            left: 5.0, right: 5.0, bottom: 5.0),
                                        child: ClipRRect(
                                          borderRadius: BorderRadius.all(
                                              Radius.circular(20.0)),
                                          // borderRadius: BorderRadius.only(topLeft: Radius.circular(30.0),topRight: Radius.circular(30.0)),
                                          child: BackdropFilter(
                                            filter: ImageFilter.blur(
                                              sigmaX: 20.0,
                                              sigmaY: 20.0,
                                            ),
                                            child: Container(
                                              decoration: BoxDecoration(
                                                color: Colors.white12,
                                                borderRadius: BorderRadius.all(
                                                    Radius.circular(20.0)),
                                                // borderRadius: BorderRadius.only(topLeft: Radius.circular(30.0),topRight: Radius.circular(30.0)),
                                                border: Border.all(
                                                  color: Colors.black26,
                                                  width: 0.5,
                                                ),
                                              ),
                                              child: SizedBox(
                                                height: 300,
                                                child: Container(
                                                  child: Column(
                                                    mainAxisAlignment:
                                                        MainAxisAlignment
                                                            .center,
                                                    crossAxisAlignment:
                                                        CrossAxisAlignment
                                                            .start,
                                                    children: <Widget>[
                                                      TabBar(
                                                        controller:
                                                            _tabController,
                                                        tabs: <Widget>[
                                                          Tab(
                                                            icon: Icon(
                                                              Icons
                                                                  .text_increase_sharp,
                                                              color: textStyle
                                                                  .color,
                                                            ),
                                                          ),
                                                          Tab(
                                                            icon: Icon(
                                                              Icons.color_lens,
                                                              color: textStyle
                                                                  .color,
                                                            ),
                                                          ),
                                                          Tab(
                                                            icon: Icon(
                                                              Icons
                                                                  .format_color_fill,
                                                              color: textStyle
                                                                  .color,
                                                            ),
                                                          ),
                                                          Tab(
                                                            icon: Icon(
                                                              Icons.text_fields,
                                                              color: textStyle
                                                                  .color,
                                                            ),
                                                          ),
                                                          Tab(
                                                            icon: Icon(
                                                              Icons.text_format,
                                                              color: textStyle
                                                                  .color,
                                                            ),
                                                          ),
                                                          Tab(
                                                            icon: Icon(
                                                              Icons.menu,
                                                              color: textStyle
                                                                  .color,
                                                            ),
                                                          ),
                                                        ],
                                                      ),
                                                      Expanded(
                                                        child: TabBarView(
                                                          controller:
                                                              _tabController,
                                                          children: <Widget>[
                                                            Center(
                                                              child:
                                                                  StatefulBuilder(
                                                                builder:
                                                                    (context,
                                                                        state) {
                                                                  return Slider(
                                                                    value:
                                                                        _currentSliderValue,
                                                                    min: 10,
                                                                    max: 100,
                                                                    divisions:
                                                                        100,
                                                                    label: _currentSliderValue
                                                                        .round()
                                                                        .toString(),
                                                                    onChanged:
                                                                        (double
                                                                            value) {
                                                                      state(() {
                                                                        _currentSliderValue =
                                                                            value.roundToDouble();
                                                                      });
                                                                      setState(
                                                                          () {
                                                                        _currentSliderValue =
                                                                            value.roundToDouble();
                                                                        textStyle =
                                                                            textStyle.copyWith(fontSize: _currentSliderValue);
                                                                      });
                                                                    },
                                                                  );
                                                                },
                                                              ),
                                                            ),
                                                            Center(
                                                              child: StatefulBuilder(
                                                                  builder:
                                                                      (context,
                                                                          state) {
                                                                return BlockPicker(
                                                                  pickerColor:
                                                                      currColor,
                                                                  availableColors:
                                                                      paletteColors,
                                                                  onColorChanged:
                                                                      (color) =>
                                                                          setState(
                                                                    () => {
                                                                      this.currColor =
                                                                          color,
                                                                      textStyle =
                                                                          textStyle
                                                                              .copyWith(
                                                                        color:
                                                                            color,
                                                                      ),
                                                                    },
                                                                  ),
                                                                );
                                                              }),
                                                            ),
                                                            Center(
                                                              child: StatefulBuilder(
                                                                  builder:
                                                                      (context,
                                                                          state) {
                                                                return BlockPicker(
                                                                  pickerColor:
                                                                      backColor,
                                                                  availableColors:
                                                                      paletteColors,
                                                                  onColorChanged:
                                                                      (color) =>
                                                                          setState(
                                                                    () => {
                                                                      this.backColor =
                                                                          color,
                                                                    },
                                                                  ),
                                                                );
                                                              }),
                                                            ),
                                                            Center(
                                                              child:
                                                                  SingleChildScrollView(
                                                                child: Column(
                                                                  children: [
                                                                    ListTile(
                                                                      title:
                                                                          new Text(
                                                                        'DancingScript',
                                                                        style:
                                                                            TextStyle(
                                                                          fontSize:
                                                                              25,
                                                                          fontFamily:
                                                                              'DancingScript',
                                                                          color:
                                                                              textStyle.color,
                                                                        ),
                                                                      ),
                                                                      onTap:
                                                                          () {
                                                                        setState(
                                                                            () {
                                                                          textStyle =
                                                                              textStyle.copyWith(
                                                                            fontFamily:
                                                                                'DancingScript',
                                                                          );
                                                                        });
                                                                      },
                                                                    ),
                                                                    ListTile(
                                                                      title:
                                                                          new Text(
                                                                        'FuzzyBubbles',
                                                                        style:
                                                                            TextStyle(
                                                                          fontSize:
                                                                              25,
                                                                          fontFamily:
                                                                              'FuzzyBubbles',
                                                                          color:
                                                                              textStyle.color,
                                                                        ),
                                                                      ),
                                                                      onTap:
                                                                          () {
                                                                        setState(
                                                                            () {
                                                                          textStyle =
                                                                              textStyle.copyWith(
                                                                            fontFamily:
                                                                                'FuzzyBubbles',
                                                                          );
                                                                        });
                                                                      },
                                                                    ),
                                                                    ListTile(
                                                                      title:
                                                                          new Text(
                                                                        'BebasNeue',
                                                                        style:
                                                                            TextStyle(
                                                                          fontSize:
                                                                              25,
                                                                          fontFamily:
                                                                              'BebasNeue',
                                                                          color:
                                                                              textStyle.color,
                                                                        ),
                                                                      ),
                                                                      onTap:
                                                                          () {
                                                                        setState(
                                                                            () {
                                                                          textStyle =
                                                                              textStyle.copyWith(
                                                                            fontFamily:
                                                                                'BebasNeue',
                                                                          );
                                                                        });
                                                                      },
                                                                    ),
                                                                    ListTile(
                                                                      title:
                                                                          new Text(
                                                                        'Lobster',
                                                                        style:
                                                                            TextStyle(
                                                                          fontSize:
                                                                              25,
                                                                          fontFamily:
                                                                              'Lobster',
                                                                          color:
                                                                              textStyle.color,
                                                                        ),
                                                                      ),
                                                                      onTap:
                                                                          () {
                                                                        setState(
                                                                            () {
                                                                          textStyle =
                                                                              textStyle.copyWith(
                                                                            fontFamily:
                                                                                'Lobster',
                                                                          );
                                                                        });
                                                                      },
                                                                    ),
                                                                    ListTile(
                                                                      title:
                                                                          new Text(
                                                                        'PermanentMarker',
                                                                        style:
                                                                            TextStyle(
                                                                          fontSize:
                                                                              25,
                                                                          fontFamily:
                                                                              'PermanentMarker',
                                                                          color:
                                                                              textStyle.color,
                                                                        ),
                                                                      ),
                                                                      onTap:
                                                                          () {
                                                                        setState(
                                                                            () {
                                                                          textStyle =
                                                                              textStyle.copyWith(
                                                                            fontFamily:
                                                                                'PermanentMarker',
                                                                          );
                                                                        });
                                                                      },
                                                                    ),
                                                                    ListTile(
                                                                      title:
                                                                          new Text(
                                                                        'RobotoMono',
                                                                        style:
                                                                            TextStyle(
                                                                          fontSize:
                                                                              25,
                                                                          fontFamily:
                                                                              'RobotoMono',
                                                                          color:
                                                                              textStyle.color,
                                                                        ),
                                                                      ),
                                                                      onTap:
                                                                          () {
                                                                        setState(
                                                                            () {
                                                                          textStyle =
                                                                              textStyle.copyWith(
                                                                            fontFamily:
                                                                                'RobotoMono',
                                                                          );
                                                                        });
                                                                      },
                                                                    ),
                                                                    ListTile(
                                                                      title:
                                                                          new Text(
                                                                        'Silkscreen',
                                                                        style:
                                                                            TextStyle(
                                                                          fontSize:
                                                                              25,
                                                                          fontFamily:
                                                                              'Silkscreen',
                                                                          color:
                                                                              textStyle.color,
                                                                        ),
                                                                      ),
                                                                      onTap:
                                                                          () {
                                                                        setState(
                                                                            () {
                                                                          textStyle =
                                                                              textStyle.copyWith(
                                                                            fontFamily:
                                                                                'Silkscreen',
                                                                          );
                                                                        });
                                                                      },
                                                                    ),
                                                                  ],
                                                                ),
                                                              ),
                                                            ),
                                                            Center(
                                                              child: Column(
                                                                  children: [
                                                                    SizedBox(
                                                                      height:
                                                                          95,
                                                                    ),
                                                                    Row(
                                                                      mainAxisAlignment:
                                                                          MainAxisAlignment
                                                                              .spaceEvenly,
                                                                      children: [
                                                                        OutlinedButton(
                                                                          onPressed:
                                                                              () {
                                                                            setState(() {
                                                                              if (isBold) {
                                                                                textStyle = textStyle.copyWith(
                                                                                  fontWeight: FontWeight.normal,
                                                                                );
                                                                                isBold = false;
                                                                              } else {
                                                                                textStyle = textStyle.copyWith(
                                                                                  fontWeight: FontWeight.bold,
                                                                                );
                                                                                isBold = true;
                                                                              }
                                                                            });
                                                                          },
                                                                          child:
                                                                              Icon(
                                                                            Icons.format_bold,
                                                                            color:
                                                                                textStyle.color,
                                                                          ),
                                                                        ),
                                                                        OutlinedButton(
                                                                          onPressed:
                                                                              () {
                                                                            setState(() {
                                                                              if (isItalic) {
                                                                                textStyle = textStyle.copyWith(
                                                                                  fontStyle: FontStyle.normal,
                                                                                );
                                                                                isItalic = false;
                                                                              } else {
                                                                                textStyle = textStyle.copyWith(
                                                                                  fontStyle: FontStyle.italic,
                                                                                );
                                                                                isItalic = true;
                                                                              }
                                                                            });
                                                                          },
                                                                          child:
                                                                              Icon(
                                                                            Icons.format_italic,
                                                                            color:
                                                                                textStyle.color,
                                                                          ),
                                                                        ),
                                                                      ],
                                                                    ),
                                                                  ]),
                                                            ),
                                                            Center(
                                                              child:
                                                                  SingleChildScrollView(
                                                                child: Column(
                                                                  mainAxisAlignment:
                                                                      MainAxisAlignment
                                                                          .center,
                                                                  crossAxisAlignment:
                                                                      CrossAxisAlignment
                                                                          .center,
                                                                  children: [
                                                                    ListTile(
                                                                      leading:
                                                                          Icon(
                                                                        Icons
                                                                            .wallpaper,
                                                                        color: textStyle
                                                                            .color,
                                                                      ),
                                                                      title:
                                                                          new Text(
                                                                        'Set As Wallpaper',
                                                                        style:
                                                                            TextStyle(
                                                                          fontSize:
                                                                              20,
                                                                          color:
                                                                              textStyle.color,
                                                                        ),
                                                                      ),
                                                                      onTap:
                                                                          () {
                                                                        Navigator.pop(
                                                                            context);
                                                                        showModalBottomSheet(
                                                                            backgroundColor:
                                                                                Colors.transparent,
                                                                            shape: const RoundedRectangleBorder(
                                                                                borderRadius: BorderRadius.vertical(
                                                                              top: Radius.circular(30),
                                                                            )),
                                                                            context: context,
                                                                            builder: (BuildContext context) {
                                                                              return SizedBox(
                                                                                height: 250,
                                                                                child: SizedBox(
                                                                                  height: 200.0,
                                                                                  child: Column(
                                                                                    children: [
                                                                                      const SizedBox(
                                                                                        height: 30.0,
                                                                                      ),
                                                                                      ElevatedButton.icon(
                                                                                        style: ElevatedButton.styleFrom(
                                                                                          shape: RoundedRectangleBorder(
                                                                                            borderRadius: BorderRadius.circular(12), // <-- Radius
                                                                                          ), // NEW
                                                                                        ),
                                                                                        onPressed: () async {
                                                                                          Navigator.pop(context);
                                                                                          final controller = ScreenshotController();
                                                                                          final bytes = await controller.captureFromWidget(
                                                                                            Material(child: _editTitleTextField()),
                                                                                          );
                                                                                          setState(() {
                                                                                            this.bytes = bytes;
                                                                                          });
                                                                                          _setwallpaper(WallpaperManagerFlutter.HOME_SCREEN, bytes);
                                                                                        },
                                                                                        icon: Icon(
                                                                                          Icons.home_outlined,
                                                                                          size: 30.0,
                                                                                        ),
                                                                                        label: Text('Set As Home Screen'),
                                                                                      ),
                                                                                      const SizedBox(
                                                                                        height: 30.0,
                                                                                      ),
                                                                                      ElevatedButton.icon(
                                                                                        style: ElevatedButton.styleFrom(
                                                                                          shape: RoundedRectangleBorder(
                                                                                            borderRadius: BorderRadius.circular(12), // <-- Radius
                                                                                          ), // NEW
                                                                                        ),
                                                                                        onPressed: () async {
                                                                                          Navigator.pop(context);
                                                                                          final controller = ScreenshotController();
                                                                                          final bytes = await controller.captureFromWidget(
                                                                                            Material(child: _editTitleTextField()),
                                                                                          );
                                                                                          setState(() {
                                                                                            this.bytes = bytes;
                                                                                          });
                                                                                          _setwallpaper(WallpaperManagerFlutter.LOCK_SCREEN, bytes);
                                                                                        },
                                                                                        icon: Icon(
                                                                                          Icons.lock_outline,
                                                                                          size: 30.0,
                                                                                        ),
                                                                                        label: Padding(padding: EdgeInsets.only(left: 5.0, right: 5.0), child: Text('Set As Lock Screen')),
                                                                                      ),
                                                                                      const SizedBox(
                                                                                        height: 30.0,
                                                                                      ),
                                                                                      ElevatedButton(
                                                                                        style: ElevatedButton.styleFrom(
                                                                                          shape: RoundedRectangleBorder(
                                                                                            borderRadius: BorderRadius.circular(12), // <-- Radius
                                                                                          ),
                                                                                        ),
                                                                                        onPressed: () async {
                                                                                          Navigator.pop(context);
                                                                                          final controller = ScreenshotController();
                                                                                          final bytes = await controller.captureFromWidget(
                                                                                            Material(child: _editTitleTextField()),
                                                                                          );
                                                                                          setState(() {
                                                                                            this.bytes = bytes;
                                                                                          });
                                                                                          _setwallpaper(WallpaperManagerFlutter.BOTH_SCREENS, bytes);
                                                                                        },
                                                                                        child: Padding(
                                                                                          padding: EdgeInsets.only(left: 23.0, right: 23.0),
                                                                                          child: const Text(
                                                                                            'Set As Both Screen',
                                                                                            // style: TextStyle(fontSize: 24),
                                                                                          ),
                                                                                        ),
                                                                                      ),
                                                                                    ],
                                                                                  ),
                                                                                ),
                                                                              );
                                                                            });
                                                                      },
                                                                    ),
                                                                    ListTile(
                                                                      leading:
                                                                          Icon(
                                                                        Icons
                                                                            .save,
                                                                        color: textStyle
                                                                            .color,
                                                                      ),
                                                                      title:
                                                                          new Text(
                                                                        'Save to gallary',
                                                                        style:
                                                                            TextStyle(
                                                                          fontSize:
                                                                              20,
                                                                          color:
                                                                              textStyle.color,
                                                                        ),
                                                                      ),
                                                                      onTap:
                                                                          () {
                                                                        Dialogs
                                                                            .materialDialog(
                                                                          color:
                                                                              Colors.white,
                                                                          msg:
                                                                              'Do you want to download the wallpaper ?',
                                                                          title:
                                                                              'Download',
                                                                          context:
                                                                              context,
                                                                          actions: [
                                                                            IconsButton(
                                                                              onPressed: () {
                                                                                Navigator.pop(context);
                                                                              },
                                                                              text: 'Cancel',
                                                                              iconData: Icons.cancel,
                                                                              color: Colors.red,
                                                                              textStyle: TextStyle(color: Colors.white),
                                                                              iconColor: Colors.white,
                                                                            ),
                                                                            IconsButton(
                                                                              onPressed: () async {
                                                                                Navigator.pop(context);
                                                                                final controller = ScreenshotController();
                                                                                final bytes = await controller.captureFromWidget(
                                                                                  Material(child: _editTitleTextField()),
                                                                                );
                                                                                setState(() {
                                                                                  this.bytes = bytes;
                                                                                });
                                                                                _save(bytes);
                                                                                ScaffoldMessenger.of(context).showSnackBar(
                                                                                  SnackBar(
                                                                                    action: SnackBarAction(
                                                                                      label: '',
                                                                                      onPressed: () {
                                                                                        // Code to execute.
                                                                                      },
                                                                                    ),
                                                                                    content: const Text('Wallpaper Downloaded Successfully.'),
                                                                                    duration: const Duration(milliseconds: 2500),
                                                                                    behavior: SnackBarBehavior.floating,
                                                                                    shape: RoundedRectangleBorder(
                                                                                      borderRadius: BorderRadius.circular(20.0),
                                                                                    ),
                                                                                    margin: EdgeInsets.only(bottom: MediaQuery.of(context).size.height - 170, right: 20, left: 20),
                                                                                  ),
                                                                                );
                                                                              },
                                                                              text: 'Yes',
                                                                              iconData: Icons.done,
                                                                              color: Colors.green,
                                                                              textStyle: TextStyle(color: Colors.white),
                                                                              iconColor: Colors.white,
                                                                            ),
                                                                          ],
                                                                        );
                                                                      },
                                                                    ),
                                                                    ListTile(
                                                                      leading:
                                                                          Icon(
                                                                        Icons
                                                                            .share,
                                                                        color: textStyle
                                                                            .color,
                                                                      ),
                                                                      title:
                                                                          new Text(
                                                                        'Share Imaage',
                                                                        style:
                                                                            TextStyle(
                                                                          fontSize:
                                                                              20,
                                                                          color:
                                                                              textStyle.color,
                                                                        ),
                                                                      ),
                                                                      onTap:
                                                                          () async {
                                                                        Navigator.pop(
                                                                            context);
                                                                        final controller =
                                                                            ScreenshotController();
                                                                        final bytes =
                                                                            await controller.captureFromWidget(
                                                                          Material(
                                                                              child: _editTitleTextField()),
                                                                        );
                                                                        setState(
                                                                            () {
                                                                          this.bytes =
                                                                              bytes;
                                                                        });
                                                                        shareWallpaper(
                                                                            bytes);
                                                                      },
                                                                    ),
                                                                    ListTile(
                                                                      leading:
                                                                          Icon(
                                                                        Icons
                                                                            .add_rounded,
                                                                        color: textStyle
                                                                            .color,
                                                                      ),
                                                                      title:
                                                                          new Text(
                                                                        'Add Quote',
                                                                        style:
                                                                            TextStyle(
                                                                          fontSize:
                                                                              20,
                                                                          color:
                                                                              textStyle.color,
                                                                        ),
                                                                      ),
                                                                      onTap:
                                                                          () async {
                                                                        Navigator.push(
                                                                            context,
                                                                            MaterialPageRoute(builder: (context) => TextRecognition(auth: Auth())));
                                                                      },
                                                                    ),
                                                                    ListTile(
                                                                      leading:
                                                                          Icon(
                                                                        Icons
                                                                            .format_quote,
                                                                        color: textStyle
                                                                            .color,
                                                                      ),
                                                                      title:
                                                                          new Text(
                                                                        'Quotes',
                                                                        style:
                                                                            TextStyle(
                                                                          fontSize:
                                                                              20,
                                                                          color:
                                                                              textStyle.color,
                                                                        ),
                                                                      ),
                                                                      onTap:
                                                                          () async {
                                                                        // Navigator.push(
                                                                        //     context,
                                                                        //     MaterialPageRoute(builder: (context) => QuoteScreen(auth: Auth())));

                                                                        Navigator.pop(
                                                                            context);
                                                                        Navigator.pop(
                                                                            context);
                                                                      },
                                                                    ),
                                                                  ],
                                                                ),
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
                                    },
                                  );
                                },
                                child: Icon(Icons.menu),
                                // padding: EdgeInsets.all(20.0),
                                // color: Colors.transparent,
                              ),
                            ),
                            // OutlinedButton(
                            //     onPressed: (){},
                            //     child: Text("Edit")
                            // ),
                          ),
                        ),
                      ),
                    )),
              ],
            ),
          ),
          // OutlinedButton(
          //     onPressed: (){},
          //     child: Text("Edit")
          // )
        ],
      ),
    );
  }
}
