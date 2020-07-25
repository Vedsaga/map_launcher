import 'dart:io';

import 'package:flutter/material.dart';
import 'package:map_launcher/src/models.dart';
import 'package:map_launcher/src/utils.dart';

String getMapDirectionsUrl({
  @required MapType mapType,
  @required Coords destination,
  @required String destinationTitle,
  @required Coords origin,
  @required String originTitle,
  @required DirectionsMode directionsMode,
}) {
  switch (mapType) {
    case MapType.google:
      if (Platform.isIOS) {
        return Utils.buildUrl(
          url: 'comgooglemaps://',
          queryParams: {
            'daddr': '${destination.latitude},${destination.longitude}',
            'saddr': Utils.nullOrValue(
              origin,
              '${origin?.latitude},${origin?.longitude}',
            ),
            // google maps is very inconsistent about their default
            // between platforms so fallback to .driving
            'directionsmode': Utils.enumToString(directionsMode),
          },
        );
      }

      return Utils.buildUrl(
        url: 'https://www.google.com/maps/dir/',
        queryParams: {
          'api': '1',
          'destination': '${destination.latitude},${destination.longitude}',
          'origin': Utils.nullOrValue(
            origin,
            '${origin?.latitude},${origin?.longitude}',
          ),
          // google maps is very inconsistent about their default
          // between platforms so fallback to .driving
          'travelmode': Utils.enumToString(directionsMode),
        },
      );

    case MapType.apple:
      return 'http://maps.apple.com/maps?saddr=${destination.latitude},${destination.longitude}';
    case MapType.amap:
      return Utils.buildUrl(
        url: Platform.isIOS ? 'iosamap://path' : 'amapuri://route/plan/',
        queryParams: {
          'sourceApplication': 'applicationName',
          'dlat': '${destination.latitude}',
          'dlon': '${destination.longitude}',
          'dname': destinationTitle,
          'slat': Utils.nullOrValue(origin, '${origin?.latitude}'),
          'slon': Utils.nullOrValue(origin, '${origin?.longitude}'),
          'sname': originTitle,
          't': Utils.getAmapDirectionsMode(directionsMode),
          'dev': '0',
        },
      );

    case MapType.baidu:
      return Utils.buildUrl(
        url: 'baidumap://map/direction',
        queryParams: {
          'destination':
              'name: ${destinationTitle ?? 'Destination'}|latlng:${destination.latitude},${destination.longitude}',
          'origin': Utils.nullOrValue(
            origin,
            'name: ${originTitle ?? 'Origin'}|latlng:${origin?.latitude},${origin?.longitude}',
          ),
          'coord_type': 'gcj02',
          'mode': Utils.getBaiduDirectionsMode(directionsMode),
          'src': 'com.map_launcher',
        },
      );

    case MapType.waze:
      return Utils.buildUrl(
        url: 'waze://',
        queryParams: {
          'll': '${destination.latitude},${destination.longitude}',
          'z': '10',
          'navigate': 'yes',
        },
      );

    case MapType.citymapper:
      return Utils.buildUrl(url: 'citymapper://directions', queryParams: {
        'endcoord': '${destination.latitude},${destination.longitude}',
        'endname': destinationTitle,
        'startcoord': Utils.nullOrValue(
          origin,
          '${origin?.latitude},${origin?.longitude}',
        ),
        'startname': originTitle,
      });

    case MapType.osmand:
      if (Platform.isIOS) {
        return Utils.buildUrl(
          url: 'osmandmaps://navigate',
          queryParams: {
            'lat': '${destination.latitude}',
            'lon': '${destination.longitude}',
            'title': destinationTitle,
          },
        );
      }
      return 'osmand.navigation:q=${destination.latitude},${destination.longitude}';
    default:
      return null;
  }
}
