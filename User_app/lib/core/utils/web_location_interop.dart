@JS()
library google_maps_interop;

import 'package:js/js.dart';
import 'dart:async';

@JS('google.maps.places.AutocompleteService')
class AutocompleteService {
  external AutocompleteService();
  external void getPlacePredictions(
      AutocompleteQuery query, Function callback);
}

@JS()
@anonymous
class AutocompleteQuery {
  external String get input;
  external factory AutocompleteQuery({String input});
}

@JS()
@anonymous
class AutocompletePrediction {
  external String get description;
  external String get place_id;
}

@JS('google.maps.Geocoder')
class Geocoder {
  external Geocoder();
  external void geocode(GeocodingRequest request, Function callback);
}

@JS()
@anonymous
class LatLngLiteral {
  external double get lat;
  external double get lng;
  external factory LatLngLiteral({double lat, double lng});
}

@JS()
@anonymous
class GeocodingRequest {
  external dynamic get location;
  external String? get placeId;
  external set placeId(String? value);
  external factory GeocodingRequest({dynamic location, String? placeId});
}

@JS()
@anonymous
class GeocoderResult {
  external String get formatted_address;
  external GeocoderGeometry get geometry;
}

@JS()
@anonymous
class GeocoderGeometry {
  external LatLngContent get location;
}

@JS()
@anonymous
class LatLngContent {
  external double lat();
  external double lng();
}

// Helper class to bridge to LocationService
class WebLocationHelper {
  static Future<List<Map<String, dynamic>>> searchPlaces(String query) {
    final completer = Completer<List<Map<String, dynamic>>>();
    try {
      final service = AutocompleteService();
      
      service.getPlacePredictions(
        AutocompleteQuery(input: query),
        allowInterop((List<dynamic>? predictions, String status) {
          if (status == 'OK' && predictions != null) {
            final results = <Map<String, dynamic>>[];
            for (var i = 0; i < predictions.length; i++) {
              final p = predictions[i] as AutocompletePrediction;
              results.add({
                'description': p.description,
                'place_id': p.place_id,
              });
            }
            completer.complete(results);
          } else {
            completer.complete([]);
          }
        }),
      );
    } catch(e) {
      completer.complete([]);
    }
    return completer.future;
  }

  static Future<String> getAddressFromLatLng(double lat, double lng) {
    final completer = Completer<String>();
    try {
      final geocoder = Geocoder();
      
      geocoder.geocode(
        GeocodingRequest(location: LatLngLiteral(lat: lat, lng: lng)),
        allowInterop((List<dynamic>? results, String status) {
          if (status == 'OK' && results != null && results.isNotEmpty) {
            final first = results[0] as GeocoderResult;
            completer.complete(first.formatted_address);
          } else {
            completer.complete("Unknown Location");
          }
        }),
      );
    } catch(e) {
      completer.complete("Unknown Location");
    }
    return completer.future;
  }

  static Future<Map<String, double>?> getPlaceDetails(String placeId) {
    final completer = Completer<Map<String, double>?>();
    try {
      final geocoder = Geocoder();
      geocoder.geocode(
        GeocodingRequest(location: null)..placeId = placeId,
        allowInterop((List<dynamic>? results, String status) {
           if (status == 'OK' && results != null && results.isNotEmpty) {
              final first = results[0] as GeocoderResult;
              final loc = first.geometry.location;
              completer.complete({'lat': loc.lat(), 'lng': loc.lng()});
           } else {
              completer.complete(null);
           }
        })
      );
    } catch(e) {
      completer.complete(null);
    }
    return completer.future;
  }
}
