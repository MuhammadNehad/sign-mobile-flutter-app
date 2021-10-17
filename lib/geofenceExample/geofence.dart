import 'dart:io';
import 'dart:ui';

import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
// ignore: import_of_legacy_library_into_null_safe
// import 'package:geofencing/geofencing.dart';

// /// A circular region which represents a geofence.
// abstract class GeofenceRegion {
//   /// The ID associated with the geofence.
//   ///
//   /// This ID identifies the geofence and is required to delete a
//   /// specific geofence.
//   final String id;

//   /// The location (center point) of the geofence.
//   final Location location;

//   /// The radius around `location` that is part of the geofence.
//   final double radius;

//   /// Listen to these geofence events.
//   final List<GeofenceEvent> triggers;

//   /// Android-specific settings for a geofence.
//   final AndroidGeofencingSettings androidSettings;

//   GeofenceRegion(this.id, double latitude, double longitude, this.radius,
//       this.triggers, this.location, this.androidSettings,
//       {AndroidGeofencingSettings? androidSettingss});

//   Iterable? _toArgs() {}
// }

// // abstract class GeofencingPlugin  {
// //   /// Initialize the plugin and request relevant permissions from the user.
// //   static Future<bool> initialize() async;

// //   /// Register for geofence events for a [GeofenceRegion].
// //   ///
// //   /// `region` is the geofence region to register with the system.
// //   /// `callback` is the method to be called when a geofence event associated
// //   /// with `region` occurs.
// //   static Future<bool> registerGeofence(
// //     GeofenceRegion region,
// //     void Function(List<String> id, Location location, GeofenceEvent event) callback);

// //   /// Stop receiving geofence events for a given [GeofenceRegion].
// //   static Future<bool> removeGeofence(GeofenceRegion region);

// //   /// Stop receiving geofence events for an identifier associated with a
// //   /// geofence region.
// //   static Future<bool> removeGeofenceById(String id) async;
// // }

// abstract class GeofencingPlugin {
//   static const MethodChannel _channel =
//       const MethodChannel('plugins.flutter.io/geofencing_plugin');

//   static Future<bool?> initialize() async {
//     try {
//       final callback = PluginUtilities.getCallbackHandle(callbackDispatcher);
//       await _channel.invokeMethod('GeofencingPlugin.initializeService',
//           <dynamic>[callback!.toRawHandle()]);
//     } catch (e) {}
//   }

//   static Future<bool?> registerGeofence(
//       GeofenceRegion region,
//       void Function(List<String> id, Location location, GeofenceEvent event)
//           callback) async {
//     if (Platform.isIOS &&
//         region.triggers.contains(GeofenceEvent.dwell) &&
//         (region.triggers.length == 1)) {
//       throw UnsupportedError("iOS does not support 'GeofenceEvent.dwell'");
//     }
//     final args = <dynamic>[
//       PluginUtilities.getCallbackHandle(callback)!.toRawHandle()
//     ];
//     args.addAll(region._toArgs()!);
//     await _channel.invokeMethod('GeofencingPlugin.registerGeofence', args);
//   }

//   /*
//   * … `removeGeofence` methods here …
//   */
// }

// void callbackDispatcher() {
//   // 1. Initialize MethodChannel used to communicate with the platform portion of the plugin.
//   const MethodChannel _backgroundChannel =
//       MethodChannel('plugins.flutter.io/geofencing_plugin_background');

//   print("callbackDispatcher called");
//   // 2. Setup internal state needed for MethodChannels.
//   WidgetsFlutterBinding.ensureInitialized();

//   // 3. Listen for background events from the platform portion of the plugin.
//   _backgroundChannel.setMethodCallHandler((MethodCall call) async {
//     final args = call.arguments;

//     // 3.1. Retrieve callback instance for handle.
//     final Function? callback = PluginUtilities.getCallbackFromHandle(
//         CallbackHandle.fromRawHandle(args[0]));
//     assert(callback != null);

//     // 3.2. Preprocess arguments.
//     final triggeringGeofences = args[1].cast<String>();
//     final locationList = args[2].cast<double>();
//     final triggeringLocation = locationFromList(locationList);
//     final GeofenceEvent event = intToGeofenceEvent(args[3]) as GeofenceEvent;

//     // 3.3. Invoke callback.
//     callback!(triggeringGeofences, triggeringLocation, event);
//   });

//   // 4. Alert plugin that the callback handler is ready for events.
//   _backgroundChannel.invokeMethod('GeofencingService.initialized');
// }

// locationFromList(locationList) {}

// Future<GeofenceEvent> intToGeofenceEvent(arg) async {
//   return GeofenceEvent.enter;
// }
