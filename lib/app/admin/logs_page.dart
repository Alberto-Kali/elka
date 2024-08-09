import 'dart:ffi';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:flutter/widgets.dart';
import '../../main.dart';

class MarkerPage extends StatefulWidget {
  const MarkerPage({super.key});

  @override
  State<MarkerPage> createState() => _MarkerPageState();
}

class _MarkerPageState extends State<MarkerPage> {
  List<Marker> customMarkers = [];
  Alignment selectedAlignment = Alignment.topCenter;
  bool counterRotate = false;

  static const alignments = {
    315: Alignment.topLeft,
    0: Alignment.topCenter,
    45: Alignment.topRight,
    270: Alignment.centerLeft,
    null: Alignment.center,
    90: Alignment.centerRight,
    225: Alignment.bottomLeft,
    180: Alignment.bottomCenter,
    135: Alignment.bottomRight,
  };

  //late final customMarkers = <Marker>[
  //  buildPin(const LatLng(51.51868093513547, -0.12835376940892318)),
  //  buildPin(const LatLng(53.33360293799854, -6.284001062079881)),
  //];

  Marker buildPin(LatLng point, int id) => Marker(
    id: id,
    point: point,
    width: 60,
    height: 60,
    child: GestureDetector(
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => MarkerLogs(id)),
      ),
      child: Icon(Icons.location_pin, size: 60, color: Colors.black54),
    ),
  );

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
        future: supabaseHelper.fetchData('Markers'),
        builder: (BuildContext context, AsyncSnapshot<dynamic> snapshot) {
          print('snapshot: $snapshot');
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            print('error: ${snapshot.error}');
            return Text('Error: ${snapshot.error}');
          } else {
            List<Marker> customMarkers = snapshot.data.map<Marker>((markerData) {
              return buildPin(LatLng(markerData['lat'], markerData['lng']),markerData['id']);
            }).toList();
            print('data: ${snapshot.data}');
            return Scaffold(
              //drawer: const MenuDrawer(MarkerPage.route),
              body: Column(
                children: [
                  Flexible(
                    child: FlutterMap(
                      options: MapOptions(
                        initialCenter: const LatLng(54.42412, 20.30335),
                        initialZoom: 9.2,
                        onTap: (_, p) =>
                            setState(() =>
                                _handleTapOnMap(context, p)),
                        //customMarkers.add(buildPin(p))),
                        interactionOptions: const InteractionOptions(
                          flags: ~InteractiveFlag.doubleTapZoom,
                        ),
                      ),
                      children: [
                        TileLayer(
                          urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                          userAgentPackageName: 'com.example.app',
                          maxNativeZoom: 19,
                        ),
                        MarkerLayer(
                          markers: customMarkers,
                          rotate: true,
                          alignment: selectedAlignment,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            );
          }
        }
    );
  }
  void _handleTapOnMap(BuildContext context, LatLng position) {
    // Show a menu to add a marker
    showModalBottomSheet(
      context: context,
      builder: (context) => _AddMarkerMenu(position, (latLng, markerId) {
        setState(() {
          customMarkers.add(buildPin(latLng, markerId));
        });
      }),
    );
  }

}



class _AddMarkerMenu extends StatelessWidget {
  final LatLng _position;
  final Function(LatLng, int) onAddMarker;


  _AddMarkerMenu(this._position, this.onAddMarker);

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 200,
      child: Column(
        children: [
          Text('Add Marker'),
          TextField(
            decoration: InputDecoration(
              labelText: 'Marker Title',
            ),
          ),
          TextField(
            decoration: InputDecoration(
              labelText: 'Marker Description',
            ),
          ),
          ElevatedButton(
            onPressed: () async {
              final markerId = await supabaseHelper.insertMarker('Markers', 'x', 'desc', this._position.latitude, this._position.longitude);
              onAddMarker(_position, markerId);
            },
            child: Text('Add Marker'),
          ),
        ],
      ),
    );
  }
}


class MarkerLogs extends StatelessWidget {
  final int position;
  const MarkerLogs(this.position, {super.key});

  @override
  Widget build(BuildContext context) {
    const numItems = 20;
    const _biggerFont = TextStyle(fontSize: 18.0);

    Widget _buildRow(int idx, String name, String date) {
      return ListTile(
        leading: CircleAvatar(
          child: Text('$idx'),
        ),
        title: Text(
          'Item $name',
          style: _biggerFont,
        ),
        subtitle: Text(date),
        trailing: const Icon(Icons.dashboard),
      );
    }

    return Scaffold(extendBodyBehindAppBar: true, body:  FutureBuilder(
      future: supabaseHelper.findMarkerbyID('Markers', position),
      builder: (BuildContext context, AsyncSnapshot<dynamic> snapshot) {
        print('snapshot: $snapshot');
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(child: CircularProgressIndicator());
        } else if (snapshot.hasError) {
          print('error: ${snapshot.error}');
          return Text('Error: ${snapshot.error}');
        } else {
          //print('data: ${snapshot.data}');
          final logs = snapshot.data[0]['content']['logs'];
          print(logs);
          return ListView.builder(
            itemCount: logs.length + 1,
            padding: const EdgeInsets.all(16.0),
            itemBuilder: (BuildContext context, int i) {
              if (i.isOdd) return const Divider();
              final index = i ~/ 2 + 1;
              return _buildRow(index, logs[index-1]['name'], logs[index-1]['date']);
            },
          );
        }
      },
    ),);
  }
}


@immutable
class Marker {
  /// Provide an optional [Key] for the [Marker].
  /// This key will get passed through to the created marker widget.
  final Key? key;
  final int id;
  /// Coordinates of the marker
  ///
  /// This will be the center of the marker, assuming that [alignment] is
  /// [Alignment.center] (default).
  final LatLng point;

  /// Widget tree of the marker, sized by [width] & [height]
  ///
  /// The [Marker] itself is not a widget.
  final Widget child;

  /// Width of [child]
  final double width;

  /// Height of [child]
  final double height;

  /// Alignment of the marker relative to the normal center at [point]
  ///
  /// For example, [Alignment.topCenter] will mean the entire marker widget is
  /// located above the [point].
  ///
  /// The center of rotation (anchor) will be opposite this.
  ///
  /// Defaults to [Alignment.center] if also unset by [MarkerLayer].
  final Alignment? alignment;

  /// Whether to counter rotate this marker to the map's rotation, to keep a
  /// fixed orientation
  ///
  /// When `true`, this marker will always appear upright and vertical from the
  /// user's perspective. Defaults to `false` if also unset by [MarkerLayer].
  ///
  /// Note that this is not used to apply a custom rotation in degrees to the
  /// marker. Use a widget inside [child] to perform this.
  final bool? rotate;

  /// Creates a container for a [child] widget located at a geographic coordinate
  /// [point]
  ///
  /// Some properties defaults will absorb the values from the parent
  /// [MarkerLayer], if the reflected properties are defined there.
  const Marker({
    this.key,
    required this.id,
    required this.point,
    required this.child,
    this.width = 30,
    this.height = 30,
    this.alignment,
    this.rotate,
  });

  /// Returns the alignment of a [width]x[height] rectangle by [left]x[top] pixels.
  static Alignment computePixelAlignment({
    required final double width,
    required final double height,
    required final double left,
    required final double top,
  }) =>
      Alignment(
        1.0 - 2 * left / width,
        1.0 - 2 * top / height,
      );
}

@immutable
class MarkerLayer extends StatelessWidget {
  /// The list of [Marker]s.
  final List<Marker> markers;

  /// Alignment of each marker relative to its normal center at [Marker.point]
  ///
  /// For example, [Alignment.topCenter] will mean the entire marker widget is
  /// located above the [Marker.point].
  ///
  /// The center of rotation (anchor) will be opposite this.
  ///
  /// Defaults to [Alignment.center]. Overriden by [Marker.alignment] if set.
  final Alignment alignment;

  /// Whether to counter rotate markers to the map's rotation, to keep a fixed
  /// orientation
  ///
  /// When `true`, markers will always appear upright and vertical from the
  /// user's perspective. Defaults to `false`. Overriden by [Marker.rotate].
  ///
  /// Note that this is not used to apply a custom rotation in degrees to the
  /// markers. Use a widget inside [Marker.child] to perform this.
  final bool rotate;

  /// Create a new [MarkerLayer] to use inside of [FlutterMap.children].
  const MarkerLayer({
    super.key,
    required this.markers,
    this.alignment = Alignment.center,
    this.rotate = false,
  });

  @override
  Widget build(BuildContext context) {
    final map = MapCamera.of(context);

    return MobileLayerTransformer(
      child: Stack(
        children: (List<Marker> markers) sync* {
          for (final m in markers) {
            // Resolve real alignment
            final left = 0.5 * m.width * ((m.alignment ?? alignment).x + 1);
            final top = 0.5 * m.height * ((m.alignment ?? alignment).y + 1);
            final right = m.width - left;
            final bottom = m.height - top;

            // Perform projection
            final pxPoint = map.project(m.point);

            // Cull if out of bounds
            if (!map.pixelBounds.containsPartialBounds(
              Bounds(
                Point(pxPoint.x + left, pxPoint.y - bottom),
                Point(pxPoint.x - right, pxPoint.y + top),
              ),
            )) continue;

            // Apply map camera to marker position
            final pos = pxPoint - map.pixelOrigin;

            yield Positioned(
              key: m.key,
              width: m.width,
              height: m.height,
              left: pos.x - right,
              top: pos.y - bottom,
              child: (m.rotate ?? rotate)
                  ? Transform.rotate(
                angle: -map.rotationRad,
                alignment: (m.alignment ?? alignment) * -1,
                child: m.child,
              )
                  : m.child,
            );
          }
        }(markers)
            .toList(),
      ),
    );
  }
}